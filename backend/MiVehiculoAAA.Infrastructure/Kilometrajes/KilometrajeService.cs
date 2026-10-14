using Microsoft.EntityFrameworkCore;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.Kilometrajes;
using MiVehiculoAAA.Application.Features.Kilometrajes.Dtos;
using MiVehiculoAAA.Domain.Entities;
using MiVehiculoAAA.Infrastructure.Data;

namespace MiVehiculoAAA.Infrastructure.Kilometrajes;

public class KilometrajeService : IKilometrajeService
{
    private readonly MiVehiculoDbContext _dbContext;

    public KilometrajeService(MiVehiculoDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<KilometrajeDto>> ObtenerAsync(
        Guid usuarioId, Guid vehiculoId, CancellationToken cancellationToken = default)
    {
        await ValidarVehiculoAsync(usuarioId, vehiculoId, cancellationToken);

        return await _dbContext.Kilometrajes
            .AsNoTracking()
            .Where(x => x.VehiculoId == vehiculoId)
            .OrderByDescending(x => x.Fecha)
            .ThenByDescending(x => x.FechaCreacion)
            .Select(x => new KilometrajeDto
            {
                Id = x.Id,
                VehiculoId = x.VehiculoId,
                Kilometraje = x.Valor,
                Fecha = x.Fecha,
                Observaciones = x.Observaciones,
                FechaCreacion = x.FechaCreacion
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<KilometrajeDto> RegistrarAsync(
        Guid usuarioId, Guid vehiculoId, RegistrarKilometrajeRequest request,
        CancellationToken cancellationToken = default)
    {
        var vehiculo = await _dbContext.Vehiculos.FirstOrDefaultAsync(
            x => x.Id == vehiculoId && x.UsuarioId == usuarioId && x.Activo,
            cancellationToken);

        if (vehiculo is null)
            throw new AppException("Vehiculo no encontrado.", 404);

        if (request.Kilometraje <= vehiculo.Kilometraje)
            throw new AppException(
                $"El kilometraje debe ser mayor al actual ({vehiculo.Kilometraje}).", 400);

        var ahora = DateTime.UtcNow;
        var registro = new Kilometraje
        {
            Id = Guid.NewGuid(),
            VehiculoId = vehiculoId,
            Valor = request.Kilometraje,
            Fecha = request.Fecha ?? DateOnly.FromDateTime(ahora),
            Observaciones = string.IsNullOrWhiteSpace(request.Observaciones)
                ? null : request.Observaciones.Trim(),
            FechaCreacion = ahora
        };

        vehiculo.Kilometraje = request.Kilometraje;
        vehiculo.FechaActualizacion = ahora;
        _dbContext.Kilometrajes.Add(registro);

        await _dbContext.SaveChangesAsync(cancellationToken);

        return new KilometrajeDto
        {
            Id = registro.Id,
            VehiculoId = registro.VehiculoId,
            Kilometraje = registro.Valor,
            Fecha = registro.Fecha,
            Observaciones = registro.Observaciones,
            FechaCreacion = registro.FechaCreacion
        };
    }

    private async Task ValidarVehiculoAsync(
        Guid usuarioId, Guid vehiculoId, CancellationToken cancellationToken)
    {
        var existe = await _dbContext.Vehiculos.AnyAsync(
            x => x.Id == vehiculoId && x.UsuarioId == usuarioId && x.Activo,
            cancellationToken);

        if (!existe)
            throw new AppException("Vehiculo no encontrado.", 404);
    }
}