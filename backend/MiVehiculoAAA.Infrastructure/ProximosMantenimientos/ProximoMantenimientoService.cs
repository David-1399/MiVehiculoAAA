using Microsoft.EntityFrameworkCore;
using MiVehiculoAAA.Application.Features.ProximosMantenimientos;
using MiVehiculoAAA.Application.Features.ProximosMantenimientos.Dtos;
using MiVehiculoAAA.Infrastructure.Data;

namespace MiVehiculoAAA.Infrastructure.ProximosMantenimientos;

public class ProximoMantenimientoService : IProximoMantenimientoService
{
    private readonly MiVehiculoDbContext _dbContext;

    public ProximoMantenimientoService(MiVehiculoDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<ProximoMantenimientoDto>> ObtenerAsync(
        Guid usuarioId,
        int dias = 30,
        int kilometros = 1000,
        CancellationToken cancellationToken = default
    )
    {
        dias = Math.Clamp(dias, 1, 365);
        kilometros = Math.Clamp(kilometros, 1, 50000);

        var hoy = DateOnly.FromDateTime(DateTime.UtcNow);
        var limiteFecha = hoy.AddDays(dias);

        var items = await _dbContext.Mantenimientos
            .AsNoTracking()
            .Where(x =>
                x.Vehiculo.UsuarioId == usuarioId &&
                x.Vehiculo.Activo &&
                (
                    (x.ProximaFecha.HasValue &&
                     x.ProximaFecha.Value <= limiteFecha) ||
                    (x.ProximoKilometraje.HasValue &&
                     x.ProximoKilometraje.Value <=
                        x.Vehiculo.Kilometraje + kilometros)
                ))
            .Select(x => new
            {
                x.Id,
                x.VehiculoId,
                Vehiculo = x.Vehiculo.Marca + " " + x.Vehiculo.Modelo,
                x.Vehiculo.Placa,
                Tipo = x.TipoMantenimiento.Nombre,
                x.ProximaFecha,
                x.ProximoKilometraje,
                Actual = x.Vehiculo.Kilometraje
            })
            .ToListAsync(cancellationToken);

        return items
            .Select(x => new ProximoMantenimientoDto
            {
                MantenimientoId = x.Id,
                VehiculoId = x.VehiculoId,
                Vehiculo = x.Vehiculo,
                Placa = x.Placa,
                TipoMantenimiento = x.Tipo ?? string.Empty,
                ProximaFecha = x.ProximaFecha,
                ProximoKilometraje = x.ProximoKilometraje,
                KilometrajeActual = x.Actual,
                KilometrosRestantes = x.ProximoKilometraje.HasValue
                    ? x.ProximoKilometraje.Value - x.Actual
                    : null,
                DiasRestantes = x.ProximaFecha.HasValue
                    ? x.ProximaFecha.Value.DayNumber - hoy.DayNumber
                    : null
            })
            .OrderBy(x => x.DiasRestantes ?? int.MaxValue)
            .ThenBy(x => x.KilometrosRestantes ?? int.MaxValue)
            .ToList();
    }
}