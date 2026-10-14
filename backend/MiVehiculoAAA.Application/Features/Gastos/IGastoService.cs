using MiVehiculoAAA.Application.Features.Gastos.Dtos;

namespace MiVehiculoAAA.Application.Features.Gastos;

public interface IGastoService
{
    Task<IReadOnlyList<GastoDto>> ObtenerPorVehiculoAsync(
        Guid usuarioId, Guid vehiculoId, CancellationToken cancellationToken = default);

    Task<GastoDto> CrearAsync(
        Guid usuarioId, Guid vehiculoId, GastoRequest request,
        CancellationToken cancellationToken = default);

    Task<GastoDto> ActualizarAsync(
        Guid usuarioId, Guid id, GastoRequest request,
        CancellationToken cancellationToken = default);

    Task EliminarAsync(
        Guid usuarioId, Guid id, CancellationToken cancellationToken = default);
}