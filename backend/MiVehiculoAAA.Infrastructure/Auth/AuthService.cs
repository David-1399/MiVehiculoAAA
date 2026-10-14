using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Common.Settings;
using MiVehiculoAAA.Application.Features.Auth;
using MiVehiculoAAA.Application.Features.Auth.Dtos;
using MiVehiculoAAA.Domain.Entities;
using MiVehiculoAAA.Infrastructure.Data;

namespace MiVehiculoAAA.Infrastructure.Auth;

public class AuthService : IAuthService
{
    private const string RolPropietario = "PROPIETARIO";

    private readonly MiVehiculoDbContext _dbContext;
    private readonly JwtSettings _jwtSettings;

    public AuthService(
        MiVehiculoDbContext dbContext,
        IOptions<JwtSettings> jwtOptions
    )
    {
        _dbContext = dbContext;
        _jwtSettings = jwtOptions.Value;
    }

    public async Task<AuthResponse> RegistrarAsync(
        RegistroUsuarioRequest request,
        CancellationToken cancellationToken = default
    )
    {
        var correo = request.Correo.Trim().ToLowerInvariant();

        var correoExiste = await _dbContext.Usuarios
            .AnyAsync(
                x => x.Correo.ToLower() == correo,
                cancellationToken
            );

        if (correoExiste)
        {
            throw new AppException(
                "Ya existe un usuario registrado con este correo.",
                409
            );
        }

        var rol = await _dbContext.Roles
            .FirstOrDefaultAsync(
                x => x.Nombre == RolPropietario && x.Activo,
                cancellationToken
            );

        if (rol is null)
        {
            throw new AppException(
                "No se encontro el rol PROPIETARIO.",
                500
            );
        }

        var usuario = new Usuario
        {
            Id = Guid.NewGuid(),
            RolId = rol.Id,
            Nombres = request.Nombres.Trim(),
            Apellidos = request.Apellidos.Trim(),
            Telefono = string.IsNullOrWhiteSpace(request.Telefono)
                ? null
                : request.Telefono.Trim(),
            Correo = correo,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Activo = true,
            FechaCreacion = DateTime.UtcNow
        };

        _dbContext.Usuarios.Add(usuario);
        await _dbContext.SaveChangesAsync(cancellationToken);

        usuario.Rol = rol;

        return CrearRespuesta(usuario);
    }

    public async Task<AuthResponse> LoginAsync(
        LoginRequest request,
        CancellationToken cancellationToken = default
    )
    {
        var correo = request.Correo.Trim().ToLowerInvariant();

        var usuario = await _dbContext.Usuarios
            .Include(x => x.Rol)
            .FirstOrDefaultAsync(
                x => x.Correo.ToLower() == correo,
                cancellationToken
            );

        if (usuario is null ||
            !usuario.Activo ||
            !BCrypt.Net.BCrypt.Verify(
                request.Password,
                usuario.PasswordHash
            ))
        {
            throw new AppException(
                "Correo o contrasena incorrectos.",
                401
            );
        }

        return CrearRespuesta(usuario);
    }

    public async Task<PerfilResponse?> ObtenerPerfilAsync(
        Guid usuarioId,
        CancellationToken cancellationToken = default
    )
    {
        return await _dbContext.Usuarios
            .AsNoTracking()
            .Where(x => x.Id == usuarioId && x.Activo)
            .Select(x => new PerfilResponse
            {
                Id = x.Id,
                Nombres = x.Nombres,
                Apellidos = x.Apellidos,
                Telefono = x.Telefono,
                Correo = x.Correo,
                Rol = x.Rol.Nombre
            })
            .FirstOrDefaultAsync(cancellationToken);
    }

    private AuthResponse CrearRespuesta(Usuario usuario)
    {
        var expiraEn =
            DateTime.UtcNow.AddMinutes(
                _jwtSettings.ExpirationMinutes
            );

        var claims = new List<Claim>
        {
            new(
                ClaimTypes.NameIdentifier,
                usuario.Id.ToString()
            ),
            new(
                ClaimTypes.Email,
                usuario.Correo
            ),
            new(
                ClaimTypes.Name,
                $"{usuario.Nombres} {usuario.Apellidos}".Trim()
            ),
            new(
                ClaimTypes.Role,
                usuario.Rol.Nombre
            )
        };

        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_jwtSettings.Key)
        );

        var credentials = new SigningCredentials(
            key,
            SecurityAlgorithms.HmacSha256
        );

        var token = new JwtSecurityToken(
            issuer: _jwtSettings.Issuer,
            audience: _jwtSettings.Audience,
            claims: claims,
            expires: expiraEn,
            signingCredentials: credentials
        );

        return new AuthResponse
        {
            Usuario = new UsuarioSesionDto
            {
                Id = usuario.Id,
                Nombres = usuario.Nombres,
                Apellidos = usuario.Apellidos,
                Telefono = usuario.Telefono,
                Correo = usuario.Correo,
                Rol = usuario.Rol.Nombre
            },
            Token = new JwtSecurityTokenHandler()
                .WriteToken(token),
            ExpiraEn = expiraEn
        };
    }
}