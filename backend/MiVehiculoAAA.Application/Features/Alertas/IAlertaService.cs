using MiVehiculoAAA.Application.Features.Alertas.Dtos;

namespace MiVehiculoAAA.Application.Features.Alertas;

public interface IAlertaService
{
    Task<IReadOnlyList<AlertaDto>> ObtenerAsync(
        Guid usuarioId,
        CancellationToken cancellationToken = default
    );

    Task MarcarLeidaAsync(
        Guid usuarioId,
        Guid alertaId,
        CancellationToken cancellationToken = default
    );

    Task<int> GenerarAlertasAutomaticasAsync(
        Guid usuarioId,
        CancellationToken cancellationToken = default
    );
}