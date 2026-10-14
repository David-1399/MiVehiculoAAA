using Microsoft.EntityFrameworkCore;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.Vehiculos;
using MiVehiculoAAA.Application.Features.Vehiculos.Dtos;
using MiVehiculoAAA.Domain.Entities;
using MiVehiculoAAA.Infrastructure.Data;

namespace MiVehiculoAAA.Infrastructure.Vehiculos;

public class VehiculoService : IVehiculoService
{
    private readonly MiVehiculoDbContext _dbContext;

    public VehiculoService(MiVehiculoDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<VehiculoDto>> ObtenerTodosAsync(
        Guid usuarioId,
        CancellationToken cancellationToken = default
    )
    {
        return await _dbContext.Vehiculos
            .AsNoTracking()
            .Where(x => x.UsuarioId == usuarioId && x.Activo)
            .OrderByDescending(x => x.FechaCreacion)
            .Select(x => new VehiculoDto
            {
                Id = x.Id,
                TipoVehiculoId = x.TipoVehiculoId,
                TipoVehiculo = x.TipoVehiculo.Nombre,
                Marca = x.Marca,
                Modelo = x.Modelo,
                Anio = x.Anio,
                Placa = x.Placa,
                Kilometraje = x.Kilometraje,
                Activo = x.Activo,
                FechaCreacion = x.FechaCreacion,
                FechaActualizacion = x.FechaActualizacion
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<VehiculoDto?> ObtenerPorIdAsync(
        Guid usuarioId,
        Guid vehiculoId,
        CancellationToken cancellationToken = default
    )
    {
        return await _dbContext.Vehiculos
            .AsNoTracking()
            .Where(
                x => x.Id == vehiculoId &&
                     x.UsuarioId == usuarioId &&
                     x.Activo
            )
            .Select(x => new VehiculoDto
            {
                Id = x.Id,
                TipoVehiculoId = x.TipoVehiculoId,
                TipoVehiculo = x.TipoVehiculo.Nombre,
                Marca = x.Marca,
                Modelo = x.Modelo,
                Anio = x.Anio,
                Placa = x.Placa,
                Kilometraje = x.Kilometraje,
                Activo = x.Activo,
                FechaCreacion = x.FechaCreacion,
                FechaActualizacion = x.FechaActualizacion
            })
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<VehiculoDto> CrearAsync(
        Guid usuarioId,
        CrearVehiculoRequest request,
        CancellationToken cancellationToken = default
    )
    {
        var tipoExiste = await _dbContext.TiposVehiculo
            .AnyAsync(
                x => x.Id == request.TipoVehiculoId && x.Activo,
                cancellationToken
            );

        if (!tipoExiste)
        {
            throw new AppException(
                "El tipo de vehiculo seleccionado no existe.",
                400
            );
        }

        var placa = NormalizarPlaca(request.Placa);

        var placaExiste = await _dbContext.Vehiculos
            .AnyAsync(
                x => x.Placa.ToUpper() == placa,
                cancellationToken
            );

        if (placaExiste)
        {
            throw new AppException(
                "Ya existe un vehiculo registrado con esa placa.",
                409
            );
        }

        var ahora = DateTime.UtcNow;

        var vehiculo = new Vehiculo
        {
            Id = Guid.NewGuid(),
            UsuarioId = usuarioId,
            TipoVehiculoId = request.TipoVehiculoId,
            Marca = request.Marca.Trim(),
            Modelo = request.Modelo.Trim(),
            Anio = request.Anio,
            Placa = placa,
            Kilometraje = request.Kilometraje,
            Activo = true,
            FechaCreacion = ahora
        };

        _dbContext.Vehiculos.Add(vehiculo);

        _dbContext.Kilometrajes.Add(
            new Kilometraje
            {
                Id = Guid.NewGuid(),
                VehiculoId = vehiculo.Id,
                Valor = request.Kilometraje,
                Fecha = DateOnly.FromDateTime(ahora),
                Observaciones = "Kilometraje inicial",
                FechaCreacion = ahora
            }
        );

        await _dbContext.SaveChangesAsync(cancellationToken);

        return await ObtenerDtoObligatorioAsync(
            usuarioId,
            vehiculo.Id,
            cancellationToken
        );
    }

    public async Task<VehiculoDto> ActualizarAsync(
        Guid usuarioId,
        Guid vehiculoId,
        ActualizarVehiculoRequest request,
        CancellationToken cancellationToken = default
    )
    {
        var vehiculo = await _dbContext.Vehiculos
            .FirstOrDefaultAsync(
                x => x.Id == vehiculoId &&
                     x.UsuarioId == usuarioId &&
                     x.Activo,
                cancellationToken
            );

        if (vehiculo is null)
        {
            throw new AppException(
                "Vehiculo no encontrado.",
                404
            );
        }

        var tipoExiste = await _dbContext.TiposVehiculo
            .AnyAsync(
                x => x.Id == request.TipoVehiculoId && x.Activo,
                cancellationToken
            );

        if (!tipoExiste)
        {
            throw new AppException(
                "El tipo de vehiculo seleccionado no existe.",
                400
            );
        }

        var placa = NormalizarPlaca(request.Placa);

        var placaExiste = await _dbContext.Vehiculos
            .AnyAsync(
                x => x.Id != vehiculoId &&
                     x.Placa.ToUpper() == placa,
                cancellationToken
            );

        if (placaExiste)
        {
            throw new AppException(
                "Ya existe un vehiculo registrado con esa placa.",
                409
            );
        }

        vehiculo.TipoVehiculoId = request.TipoVehiculoId;
        vehiculo.Marca = request.Marca.Trim();
        vehiculo.Modelo = request.Modelo.Trim();
        vehiculo.Anio = request.Anio;
        vehiculo.Placa = placa;
        vehiculo.FechaActualizacion = DateTime.UtcNow;

        await _dbContext.SaveChangesAsync(cancellationToken);

        return await ObtenerDtoObligatorioAsync(
            usuarioId,
            vehiculoId,
            cancellationToken
        );
    }

    public async Task EliminarAsync(
        Guid usuarioId,
        Guid vehiculoId,
        CancellationToken cancellationToken = default
    )
    {
        var vehiculo = await _dbContext.Vehiculos
            .FirstOrDefaultAsync(
                x => x.Id == vehiculoId &&
                     x.UsuarioId == usuarioId &&
                     x.Activo,
                cancellationToken
            );

        if (vehiculo is null)
        {
            throw new AppException(
                "Vehiculo no encontrado.",
                404
            );
        }

        vehiculo.Activo = false;
        vehiculo.FechaActualizacion = DateTime.UtcNow;

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task<VehiculoDto> ObtenerDtoObligatorioAsync(
        Guid usuarioId,
        Guid vehiculoId,
        CancellationToken cancellationToken
    )
    {
        var dto = await ObtenerPorIdAsync(
            usuarioId,
            vehiculoId,
            cancellationToken
        );

        if (dto is null)
        {
            throw new AppException(
                "No fue posible obtener el vehiculo.",
                500
            );
        }

        return dto;
    }

    private static string NormalizarPlaca(string placa)
    {
        return placa
            .Trim()
            .Replace(" ", string.Empty)
            .ToUpperInvariant();
    }
}