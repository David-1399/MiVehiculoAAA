using Microsoft.EntityFrameworkCore;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.Gastos;
using MiVehiculoAAA.Application.Features.Gastos.Dtos;
using MiVehiculoAAA.Domain.Entities;
using MiVehiculoAAA.Infrastructure.Data;

namespace MiVehiculoAAA.Infrastructure.Gastos;

public class GastoService : IGastoService
{
    private readonly MiVehiculoDbContext _dbContext;

    public GastoService(MiVehiculoDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<GastoDto>> ObtenerPorVehiculoAsync(
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
            .Select(x => new GastoDto
            {
                Id = x.Id,
                VehiculoId = x.VehiculoId,
                CategoriaGastoId = x.CategoriaGastoId,
                CategoriaGasto =
                    x.CategoriaGasto.Nombre ?? string.Empty,
                Descripcion = x.Descripcion,
                Valor = x.Valor,
                Fecha = x.Fecha,
                RutaSoporte = x.RutaSoporte,
                Observaciones = x.Observaciones,
                FechaCreacion = x.FechaCreacion
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<GastoDto> CrearAsync(
        Guid usuarioId,
        Guid vehiculoId,
        GastoRequest request,
        CancellationToken cancellationToken = default
    )
    {
        await ValidarVehiculoAsync(
            usuarioId,
            vehiculoId,
            cancellationToken
        );

        ValidarRequest(request);

        await ValidarCategoriaAsync(
            request.CategoriaGastoId,
            cancellationToken
        );

        var item = new Gasto
        {
            Id = Guid.NewGuid(),
            VehiculoId = vehiculoId,
            CategoriaGastoId = request.CategoriaGastoId,
            Descripcion = request.Descripcion.Trim(),
            Valor = request.Valor,
            Fecha = request.Fecha,
            RutaSoporte = Normalizar(request.RutaSoporte),
            Observaciones = Normalizar(request.Observaciones),
            FechaCreacion = DateTime.UtcNow
        };

        _dbContext.Gastos.Add(item);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return await ObtenerUnoAsync(
            usuarioId,
            item.Id,
            cancellationToken
        ) ?? throw new AppException(
            "No fue posible obtener el gasto.",
            500
        );
    }

    public async Task<GastoDto> ActualizarAsync(
        Guid usuarioId,
        Guid id,
        GastoRequest request,
        CancellationToken cancellationToken = default
    )
    {
        var item = await _dbContext.Gastos
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
                "Gasto no encontrado.",
                404
            );
        }

        ValidarRequest(request);

        await ValidarCategoriaAsync(
            request.CategoriaGastoId,
            cancellationToken
        );

        item.CategoriaGastoId = request.CategoriaGastoId;
        item.Descripcion = request.Descripcion.Trim();
        item.Valor = request.Valor;
        item.Fecha = request.Fecha;
        item.RutaSoporte = Normalizar(request.RutaSoporte);
        item.Observaciones = Normalizar(request.Observaciones);

        await _dbContext.SaveChangesAsync(cancellationToken);

        return await ObtenerUnoAsync(
            usuarioId,
            id,
            cancellationToken
        ) ?? throw new AppException(
            "No fue posible obtener el gasto.",
            500
        );
    }

    public async Task EliminarAsync(
        Guid usuarioId,
        Guid id,
        CancellationToken cancellationToken = default
    )
    {
        var item = await _dbContext.Gastos
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
                "Gasto no encontrado.",
                404
            );
        }

        _dbContext.Gastos.Remove(item);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private IQueryable<Gasto> Query(Guid usuarioId)
    {
        return _dbContext.Gastos
            .AsNoTracking()
            .Where(
                x => x.Vehiculo.UsuarioId == usuarioId &&
                     x.Vehiculo.Activo
            );
    }

    private async Task<GastoDto?> ObtenerUnoAsync(
        Guid usuarioId,
        Guid id,
        CancellationToken cancellationToken
    )
    {
        return await Query(usuarioId)
            .Where(x => x.Id == id)
            .Select(x => new GastoDto
            {
                Id = x.Id,
                VehiculoId = x.VehiculoId,
                CategoriaGastoId = x.CategoriaGastoId,
                CategoriaGasto =
                    x.CategoriaGasto.Nombre ?? string.Empty,
                Descripcion = x.Descripcion,
                Valor = x.Valor,
                Fecha = x.Fecha,
                RutaSoporte = x.RutaSoporte,
                Observaciones = x.Observaciones,
                FechaCreacion = x.FechaCreacion
            })
            .FirstOrDefaultAsync(cancellationToken);
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

    private async Task ValidarCategoriaAsync(
        Guid id,
        CancellationToken cancellationToken
    )
    {
        var existe = await _dbContext.CategoriasGasto.AnyAsync(
            x => x.Id == id && x.Activo,
            cancellationToken
        );

        if (!existe)
        {
            throw new AppException(
                "Categoria de gasto no valida.",
                400
            );
        }
    }

    private static void ValidarRequest(GastoRequest request)
    {
        if (request.Valor <= 0)
        {
            throw new AppException(
                "El valor del gasto debe ser mayor a cero.",
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