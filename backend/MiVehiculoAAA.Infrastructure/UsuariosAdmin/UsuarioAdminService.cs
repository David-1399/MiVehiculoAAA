using Microsoft.EntityFrameworkCore;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.UsuariosAdmin;
using MiVehiculoAAA.Application.Features.UsuariosAdmin.Dtos;
using MiVehiculoAAA.Domain.Entities;
using MiVehiculoAAA.Infrastructure.Data;

namespace MiVehiculoAAA.Infrastructure.UsuariosAdmin;

public class UsuarioAdminService : IUsuarioAdminService
{
    private const string RolAdministrador = "ADMINISTRADOR";
    private const string RolPropietario = "PROPIETARIO";

    private static readonly string[] RolesPermitidos =
    {
        RolAdministrador,
        RolPropietario
    };

    private readonly MiVehiculoDbContext _dbContext;

    public UsuarioAdminService(
        MiVehiculoDbContext dbContext
    )
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<UsuarioAdminDto>> ObtenerTodosAsync(
        CancellationToken cancellationToken = default
    )
    {
        return await _dbContext.Usuarios
            .AsNoTracking()
            .OrderBy(x => x.Nombres)
            .ThenBy(x => x.Apellidos)
            .Select(x => new UsuarioAdminDto
            {
                Id = x.Id,
                RolId = x.RolId,
                Rol = x.Rol.Nombre,
                Nombres = x.Nombres,
                Apellidos = x.Apellidos,
                Telefono = x.Telefono,
                Correo = x.Correo,
                Activo = x.Activo,
                FechaCreacion = x.FechaCreacion,
                FechaActualizacion = x.FechaActualizacion
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<UsuarioAdminDto?> ObtenerPorIdAsync(
        Guid usuarioId,
        CancellationToken cancellationToken = default
    )
    {
        return await _dbContext.Usuarios
            .AsNoTracking()
            .Where(x => x.Id == usuarioId)
            .Select(x => new UsuarioAdminDto
            {
                Id = x.Id,
                RolId = x.RolId,
                Rol = x.Rol.Nombre,
                Nombres = x.Nombres,
                Apellidos = x.Apellidos,
                Telefono = x.Telefono,
                Correo = x.Correo,
                Activo = x.Activo,
                FechaCreacion = x.FechaCreacion,
                FechaActualizacion = x.FechaActualizacion
            })
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<UsuarioAdminDto> CrearAsync(
        CrearUsuarioAdminRequest request,
        CancellationToken cancellationToken = default
    )
    {
        var correo = NormalizarCorreo(request.Correo);
        var rolNombre = NormalizarRol(request.Rol);

        await ValidarCorreoDisponibleAsync(
            correo,
            null,
            cancellationToken
        );

        var rol = await ObtenerRolAsync(
            rolNombre,
            cancellationToken
        );

        var usuario = new Usuario
        {
            Id = Guid.NewGuid(),
            RolId = rol.Id,
            Nombres = request.Nombres.Trim(),
            Apellidos = request.Apellidos.Trim(),
            Telefono = NormalizarOpcional(request.Telefono),
            Correo = correo,
            PasswordHash =
                BCrypt.Net.BCrypt.HashPassword(request.Password),
            Activo = true,
            FechaCreacion = DateTime.UtcNow
        };

        _dbContext.Usuarios.Add(usuario);
        await _dbContext.SaveChangesAsync(cancellationToken);

        usuario.Rol = rol;

        return Mapear(usuario);
    }

    public async Task<UsuarioAdminDto> ActualizarAsync(
        Guid usuarioId,
        ActualizarUsuarioAdminRequest request,
        CancellationToken cancellationToken = default
    )
    {
        var usuario = await _dbContext.Usuarios
            .Include(x => x.Rol)
            .FirstOrDefaultAsync(
                x => x.Id == usuarioId,
                cancellationToken
            );

        if (usuario is null)
        {
            throw new AppException(
                "Usuario no encontrado.",
                404
            );
        }

        var correo = NormalizarCorreo(request.Correo);
        var rolNombre = NormalizarRol(request.Rol);

        await ValidarCorreoDisponibleAsync(
            correo,
            usuarioId,
            cancellationToken
        );

        var rol = await ObtenerRolAsync(
            rolNombre,
            cancellationToken
        );

        if (usuario.Rol.Nombre == RolAdministrador &&
            rol.Nombre != RolAdministrador)
        {
            await ValidarNoEsUltimoAdministradorAsync(
                usuario.Id,
                cancellationToken
            );
        }

        usuario.RolId = rol.Id;
        usuario.Rol = rol;
        usuario.Nombres = request.Nombres.Trim();
        usuario.Apellidos = request.Apellidos.Trim();
        usuario.Telefono = NormalizarOpcional(request.Telefono);
        usuario.Correo = correo;
        usuario.FechaActualizacion = DateTime.UtcNow;

        if (!string.IsNullOrWhiteSpace(request.Password))
        {
            usuario.PasswordHash =
                BCrypt.Net.BCrypt.HashPassword(request.Password);
        }

        await _dbContext.SaveChangesAsync(cancellationToken);

        return Mapear(usuario);
    }

    public async Task DesactivarAsync(
        Guid usuarioId,
        Guid administradorEjecutorId,
        CancellationToken cancellationToken = default
    )
    {
        if (usuarioId == administradorEjecutorId)
        {
            throw new AppException(
                "No puedes desactivar tu propio usuario administrador.",
                400
            );
        }

        var usuario = await _dbContext.Usuarios
            .Include(x => x.Rol)
            .FirstOrDefaultAsync(
                x => x.Id == usuarioId,
                cancellationToken
            );

        if (usuario is null)
        {
            throw new AppException(
                "Usuario no encontrado.",
                404
            );
        }

        if (!usuario.Activo)
        {
            return;
        }

        if (usuario.Rol.Nombre == RolAdministrador)
        {
            await ValidarNoEsUltimoAdministradorAsync(
                usuario.Id,
                cancellationToken
            );
        }

        usuario.Activo = false;
        usuario.FechaActualizacion = DateTime.UtcNow;

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task ValidarCorreoDisponibleAsync(
        string correo,
        Guid? usuarioActualId,
        CancellationToken cancellationToken
    )
    {
        var existe = await _dbContext.Usuarios
            .AnyAsync(
                x =>
                    x.Correo.ToLower() == correo &&
                    (!usuarioActualId.HasValue ||
                     x.Id != usuarioActualId.Value),
                cancellationToken
            );

        if (existe)
        {
            throw new AppException(
                "Ya existe un usuario registrado con este correo.",
                409
            );
        }
    }

    private async Task<Rol> ObtenerRolAsync(
        string rolNombre,
        CancellationToken cancellationToken
    )
    {
        if (!RolesPermitidos.Contains(rolNombre))
        {
            throw new AppException(
                "El rol debe ser ADMINISTRADOR o PROPIETARIO.",
                400
            );
        }

        var rol = await _dbContext.Roles
            .FirstOrDefaultAsync(
                x => x.Nombre == rolNombre && x.Activo,
                cancellationToken
            );

        if (rol is null)
        {
            throw new AppException(
                $"No se encontro el rol {rolNombre}.",
                500
            );
        }

        return rol;
    }

    private async Task ValidarNoEsUltimoAdministradorAsync(
        Guid usuarioId,
        CancellationToken cancellationToken
    )
    {
        var otrosAdministradores = await _dbContext.Usuarios
            .CountAsync(
                x =>
                    x.Id != usuarioId &&
                    x.Activo &&
                    x.Rol.Nombre == RolAdministrador,
                cancellationToken
            );

        if (otrosAdministradores == 0)
        {
            throw new AppException(
                "No se puede desactivar o cambiar el rol del ultimo administrador activo.",
                409
            );
        }
    }

    private static string NormalizarCorreo(string correo)
    {
        return correo.Trim().ToLowerInvariant();
    }

    private static string NormalizarRol(string rol)
    {
        return rol.Trim().ToUpperInvariant();
    }

    private static string? NormalizarOpcional(string? value)
    {
        return string.IsNullOrWhiteSpace(value)
            ? null
            : value.Trim();
    }

    private static UsuarioAdminDto Mapear(Usuario usuario)
    {
        return new UsuarioAdminDto
        {
            Id = usuario.Id,
            RolId = usuario.RolId,
            Rol = usuario.Rol.Nombre,
            Nombres = usuario.Nombres,
            Apellidos = usuario.Apellidos,
            Telefono = usuario.Telefono,
            Correo = usuario.Correo,
            Activo = usuario.Activo,
            FechaCreacion = usuario.FechaCreacion,
            FechaActualizacion = usuario.FechaActualizacion
        };
    }
}