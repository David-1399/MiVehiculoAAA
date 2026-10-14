using MiVehiculoAAA.Application.Features.ProximosMantenimientos.Dtos;

namespace MiVehiculoAAA.Application.Features.ProximosMantenimientos;

public interface IProximoMantenimientoService
{
    Task<IReadOnlyList<ProximoMantenimientoDto>> ObtenerAsync(
        Guid usuarioId,
        int dias = 30,
        int kilometros = 1000,
        CancellationToken cancellationToken = default
    );
}