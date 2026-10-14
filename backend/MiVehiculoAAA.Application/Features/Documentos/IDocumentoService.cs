using MiVehiculoAAA.Application.Features.Documentos.Dtos;

namespace MiVehiculoAAA.Application.Features.Documentos;

public interface IDocumentoService
{
    Task<IReadOnlyList<DocumentoDto>> ObtenerPorVehiculoAsync(
        Guid usuarioId, Guid vehiculoId, CancellationToken cancellationToken = default);

    Task<DocumentoDto> CrearAsync(
        Guid usuarioId, Guid vehiculoId, DocumentoRequest request,
        CancellationToken cancellationToken = default);

    Task<DocumentoDto> ActualizarAsync(
        Guid usuarioId, Guid id, DocumentoRequest request,
        CancellationToken cancellationToken = default);

    Task EliminarAsync(
        Guid usuarioId, Guid id, CancellationToken cancellationToken = default);
}