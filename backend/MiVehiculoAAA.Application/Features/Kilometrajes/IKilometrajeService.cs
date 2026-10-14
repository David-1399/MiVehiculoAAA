using MiVehiculoAAA.Application.Features.Kilometrajes.Dtos;

namespace MiVehiculoAAA.Application.Features.Kilometrajes;

public interface IKilometrajeService
{
    Task<IReadOnlyList<KilometrajeDto>> ObtenerAsync(
        Guid usuarioId, Guid vehiculoId, CancellationToken cancellationToken = default);

    Task<KilometrajeDto> RegistrarAsync(
        Guid usuarioId, Guid vehiculoId, RegistrarKilometrajeRequest request,
        CancellationToken cancellationToken = default);
}