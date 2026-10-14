using Microsoft.EntityFrameworkCore;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.Mantenimientos;
using MiVehiculoAAA.Application.Features.Mantenimientos.Dtos;
using MiVehiculoAAA.Domain.Entities;
using MiVehiculoAAA.Infrastructure.Data;

namespace MiVehiculoAAA.Infrastructure.Mantenimientos;

public class MantenimientoService : IMantenimientoService
{
    private readonly MiVehiculoDbContext _dbContext;

    public MantenimientoService(MiVehiculoDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<MantenimientoDto>> ObtenerPorVehiculoAsync(
        Guid usuarioId,
        Guid vehiculoId,
        CancellationToken cancellationToken = default
    )
    {
        await ValidarVehiculoAsync(
            usuarioId,
            vehiculoId,
            cancellationToken
        );

        return await Query(usuarioId)
            .Where(x => x.VehiculoId == vehiculoId)
            .OrderByDescending(x => x.Fecha)
            .Select(x => new MantenimientoDto
            {
                Id = x.Id,
                VehiculoId = x.VehiculoId,
                TipoMantenimientoId = x.TipoMantenimientoId,
                TipoMantenimiento =
                    x.TipoMantenimiento.Nombre ?? string.Empty,
                Categoria =
                    x.TipoMantenimiento.Categoria ?? string.Empty,
                Descripcion = x.Descripcion,
                Fecha = x.Fecha,
                Kilometraje = x.Kilometraje,
                Costo = x.Costo ?? 0m,
                Taller = x.Taller,
                ProximoKilometraje = x.ProximoKilometraje,
                ProximaFecha = x.ProximaFecha,
                Observaciones = x.Observaciones,
                FechaCreacion = x.FechaCreacion,
                FechaActualizacion = x.FechaActualizacion
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<MantenimientoDto?> ObtenerPorIdAsync(
        Guid usuarioId,
        Guid id,
        CancellationToken cancellationToken = default
    )
    {
        return await Query(usuarioId)
            .Where(x => x.Id == id)
            .Select(x => new MantenimientoDto
            {
                Id = x.Id,
                VehiculoId = x.VehiculoId,
                TipoMantenimientoId = x.TipoMantenimientoId,
                TipoMantenimiento =
                    x.TipoMantenimiento.Nombre ?? string.Empty,
                Categoria =
                    x.TipoMantenimiento.Categoria ?? string.Empty,
                Descripcion = x.Descripcion,
                Fecha = x.Fecha,
                Kilometraje = x.Kilometraje,
                Costo = x.Costo ?? 0m,
                Taller = x.Taller,
                ProximoKilometraje = x.ProximoKilometraje,
                ProximaFecha = x.ProximaFecha,
                Observaciones = x.Observaciones,
                FechaCreacion = x.FechaCreacion,
                FechaActualizacion = x.FechaActualizacion
            })
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<MantenimientoDto> CrearAsync(
        Guid usuarioId,
        Guid vehiculoId,
        MantenimientoRequest request,
        CancellationToken cancellationToken = default
    )
    {
        await ValidarVehiculoAsync(
            usuarioId,
            vehiculoId,
            cancellationToken
        );

        ValidarRequest(request);

        await ValidarTipoAsync(
            request.TipoMantenimientoId,
            cancellationToken
        );

        var item = new Mantenimiento
        {
            Id = Guid.NewGuid(),
            VehiculoId = vehiculoId,
            TipoMantenimientoId = request.TipoMantenimientoId,
            Descripcion = request.Descripcion.Trim(),
            Fecha = request.Fecha,
            Kilometraje = request.Kilometraje,
            Costo = request.Costo,
            Taller = Normalizar(request.Taller),
            ProximoKilometraje = request.ProximoKilometraje,
            ProximaFecha = request.ProximaFecha,
            Observaciones = Normalizar(request.Observaciones),
            FechaCreacion = DateTime.UtcNow
        };

        _dbContext.Mantenimientos.Add(item);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return await ObtenerPorIdAsync(
            usuarioId,
            item.Id,
            cancellationToken
        ) ?? throw new AppException(
            "No fue posible obtener el mantenimiento.",
            500
        );
    }

    public async Task<MantenimientoDto> ActualizarAsync(
        Guid usuarioId,
        Guid id,
        MantenimientoRequest request,
        CancellationToken cancellationToken = default
    )
    {
        var item = await _dbContext.Mantenimientos
            .Include(x => x.Vehiculo)
            .FirstOrDefaultAsync(
                x => x.Id == id &&
                     x.Vehiculo.UsuarioId == usuarioId &&
                     x.Vehiculo.Activo,
                cancellationToken
            );

        if (item is null)
        {
            throw new AppException(
                "Mantenimiento no encontrado.",
                404
            );
        }

        ValidarRequest(request);

        await ValidarTipoAsync(
            request.TipoMantenimientoId,
            cancellationToken
        );

        item.TipoMantenimientoId =
            request.TipoMantenimientoId;
        item.Descripcion = request.Descripcion.Trim();
        item.Fecha = request.Fecha;
        item.Kilometraje = request.Kilometraje;
        item.Costo = request.Costo;
        item.Taller = Normalizar(request.Taller);
        item.ProximoKilometraje =
            request.ProximoKilometraje;
        item.ProximaFecha = request.ProximaFecha;
        item.Observaciones =
            Normalizar(request.Observaciones);
        item.FechaActualizacion = DateTime.UtcNow;

        await _dbContext.SaveChangesAsync(cancellationToken);

        return await ObtenerPorIdAsync(
            usuarioId,
            id,
            cancellationToken
        ) ?? throw new AppException(
            "No fue posible obtener el mantenimiento.",
            500
        );
    }

    public async Task EliminarAsync(
        Guid usuarioId,
        Guid id,
        CancellationToken cancellationToken = default
    )
    {
        var item = await _dbContext.Mantenimientos
            .Include(x => x.Vehiculo)
            .FirstOrDefaultAsync(
                x => x.Id == id &&
                     x.Vehiculo.UsuarioId == usuarioId &&
                     x.Vehiculo.Activo,
                cancellationToken
            );

        if (item is null)
        {
            throw new AppException(
                "Mantenimiento no encontrado.",
                404
            );
        }

        _dbContext.Mantenimientos.Remove(item);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private IQueryable<Mantenimiento> Query(Guid usuarioId)
    {
        return _dbContext.Mantenimientos
            .AsNoTracking()
            .Where(
                x => x.Vehiculo.UsuarioId == usuarioId &&
                     x.Vehiculo.Activo
            );
    }

    private async Task ValidarVehiculoAsync(
        Guid usuarioId,
        Guid vehiculoId,
        CancellationToken cancellationToken
    )
    {
        var existe = await _dbContext.Vehiculos.AnyAsync(
            x => x.Id == vehiculoId &&
                 x.UsuarioId == usuarioId &&
                 x.Activo,
            cancellationToken
        );

        if (!existe)
        {
            throw new AppException(
                "Vehiculo no encontrado.",
                404
            );
        }
    }

    private async Task ValidarTipoAsync(
        Guid id,
        CancellationToken cancellationToken
    )
    {
        var existe =
            await _dbContext.TiposMantenimiento.AnyAsync(
                x => x.Id == id && x.Activo,
                cancellationToken
            );

        if (!existe)
        {
            throw new AppException(
                "Tipo de mantenimiento no valido.",
                400
            );
        }
    }

    private static void ValidarRequest(
        MantenimientoRequest request
    )
    {
        if (request.Costo < 0)
        {
            throw new AppException(
                "El costo del mantenimiento no puede ser negativo.",
                400
            );
        }
    }

    private static string? Normalizar(string? value)
    {
        return string.IsNullOrWhiteSpace(value)
            ? null
            : value.Trim();
    }
}