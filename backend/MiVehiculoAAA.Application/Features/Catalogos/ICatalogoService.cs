using MiVehiculoAAA.Application.Features.Catalogos.Dtos;

namespace MiVehiculoAAA.Application.Features.Catalogos;

public interface ICatalogoService
{
    Task<IReadOnlyList<CatalogoItemDto>> ObtenerTiposVehiculoAsync(
        CancellationToken cancellationToken = default
    );

    Task<IReadOnlyList<TipoMantenimientoDto>> ObtenerTiposMantenimientoAsync(
        CancellationToken cancellationToken = default
    );

    Task<IReadOnlyList<CatalogoItemDto>> ObtenerTiposDocumentoAsync(
        CancellationToken cancellationToken = default
    );

    Task<IReadOnlyList<CatalogoItemDto>> ObtenerCategoriasGastoAsync(
        CancellationToken cancellationToken = default
    );
}