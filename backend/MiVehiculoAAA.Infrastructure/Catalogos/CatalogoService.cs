using Microsoft.EntityFrameworkCore;
using MiVehiculoAAA.Application.Features.Catalogos;
using MiVehiculoAAA.Application.Features.Catalogos.Dtos;
using MiVehiculoAAA.Infrastructure.Data;

namespace MiVehiculoAAA.Infrastructure.Catalogos;

public class CatalogoService : ICatalogoService
{
    private readonly MiVehiculoDbContext _dbContext;

    public CatalogoService(MiVehiculoDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<CatalogoItemDto>> ObtenerTiposVehiculoAsync(
        CancellationToken cancellationToken = default
    )
    {
        return await _dbContext.TiposVehiculo
            .AsNoTracking()
            .Where(x => x.Activo)
            .OrderBy(x => x.Nombre)
            .Select(x => new CatalogoItemDto
            {
                Id = x.Id,
                Nombre = x.Nombre,
                Descripcion = x.Descripcion
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<TipoMantenimientoDto>>
        ObtenerTiposMantenimientoAsync(
            CancellationToken cancellationToken = default
        )
    {
        return await _dbContext.TiposMantenimiento
            .AsNoTracking()
            .Where(x => x.Activo)
            .OrderBy(x => x.Categoria)
            .ThenBy(x => x.Nombre)
            .Select(x => new TipoMantenimientoDto
            {
                Id = x.Id,
                Nombre = x.Nombre,
                Descripcion = x.Descripcion,
                Categoria = x.Categoria
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<CatalogoItemDto>> ObtenerTiposDocumentoAsync(
        CancellationToken cancellationToken = default
    )
    {
        return await _dbContext.TiposDocumento
            .AsNoTracking()
            .Where(x => x.Activo)
            .OrderBy(x => x.Nombre)
            .Select(x => new CatalogoItemDto
            {
                Id = x.Id,
                Nombre = x.Nombre,
                Descripcion = x.Descripcion
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<CatalogoItemDto>> ObtenerCategoriasGastoAsync(
        CancellationToken cancellationToken = default
    )
    {
        return await _dbContext.CategoriasGasto
            .AsNoTracking()
            .Where(x => x.Activo)
            .OrderBy(x => x.Nombre)
            .Select(x => new CatalogoItemDto
            {
                Id = x.Id,
                Nombre = x.Nombre,
                Descripcion = x.Descripcion
            })
            .ToListAsync(cancellationToken);
    }
}