using MiVehiculoAAA.Application.Features.Mantenimientos.Dtos;

namespace MiVehiculoAAA.Application.Features.Mantenimientos;

public interface IMantenimientoService
{
    Task<IReadOnlyList<MantenimientoDto>> ObtenerPorVehiculoAsync(
        Guid usuarioId, Guid vehiculoId, CancellationToken cancellationToken = default);

    Task<MantenimientoDto?> ObtenerPorIdAsync(
        Guid usuarioId, Guid id, CancellationToken cancellationToken = default);

    Task<MantenimientoDto> CrearAsync(
        Guid usuarioId, Guid vehiculoId, MantenimientoRequest request,
        CancellationToken cancellationToken = default);

    Task<MantenimientoDto> ActualizarAsync(
        Guid usuarioId, Guid id, MantenimientoRequest request,
        CancellationToken cancellationToken = default);

    Task EliminarAsync(
        Guid usuarioId, Guid id, CancellationToken cancellationToken = default);
}