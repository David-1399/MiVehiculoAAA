using MiVehiculoAAA.Application.Features.Vehiculos.Dtos;

namespace MiVehiculoAAA.Application.Features.Vehiculos;

public interface IVehiculoService
{
    Task<IReadOnlyList<VehiculoDto>> ObtenerTodosAsync(
        Guid usuarioId,
        CancellationToken cancellationToken = default
    );

    Task<VehiculoDto?> ObtenerPorIdAsync(
        Guid usuarioId,
        Guid vehiculoId,
        CancellationToken cancellationToken = default
    );

    Task<VehiculoDto> CrearAsync(
        Guid usuarioId,
        CrearVehiculoRequest request,
        CancellationToken cancellationToken = default
    );

    Task<VehiculoDto> ActualizarAsync(
        Guid usuarioId,
        Guid vehiculoId,
        ActualizarVehiculoRequest request,
        CancellationToken cancellationToken = default
    );

    Task EliminarAsync(
        Guid usuarioId,
        Guid vehiculoId,
        CancellationToken cancellationToken = default
    );
}