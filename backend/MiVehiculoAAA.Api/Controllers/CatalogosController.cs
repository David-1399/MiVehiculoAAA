using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiVehiculoAAA.Application.Features.Catalogos;

namespace MiVehiculoAAA.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/catalogos")]
public class CatalogosController : ControllerBase
{
    private readonly ICatalogoService _catalogoService;

    public CatalogosController(ICatalogoService catalogoService)
    {
        _catalogoService = catalogoService;
    }

    [HttpGet("tipos-vehiculo")]
    public async Task<IActionResult> TiposVehiculo(
        CancellationToken cancellationToken
    )
    {
        return Ok(
            await _catalogoService.ObtenerTiposVehiculoAsync(
                cancellationToken
            )
        );
    }

    [HttpGet("tipos-mantenimiento")]
    public async Task<IActionResult> TiposMantenimiento(
        CancellationToken cancellationToken
    )
    {
        return Ok(
            await _catalogoService.ObtenerTiposMantenimientoAsync(
                cancellationToken
            )
        );
    }

    [HttpGet("tipos-documento")]
    public async Task<IActionResult> TiposDocumento(
        CancellationToken cancellationToken
    )
    {
        return Ok(
            await _catalogoService.ObtenerTiposDocumentoAsync(
                cancellationToken
            )
        );
    }

    [HttpGet("categorias-gasto")]
    public async Task<IActionResult> CategoriasGasto(
        CancellationToken cancellationToken
    )
    {
        return Ok(
            await _catalogoService.ObtenerCategoriasGastoAsync(
                cancellationToken
            )
        );
    }
}