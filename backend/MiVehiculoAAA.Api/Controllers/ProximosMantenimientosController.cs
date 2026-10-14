using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiVehiculoAAA.Application.Features.ProximosMantenimientos;

namespace MiVehiculoAAA.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/mantenimientos/proximos")]
public class ProximosMantenimientosController : ControllerBase
{
    private readonly IProximoMantenimientoService _service;

    public ProximosMantenimientosController(
        IProximoMantenimientoService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> Obtener(
        [FromQuery] int dias = 30,
        [FromQuery] int kilometros = 1000,
        CancellationToken ct = default)
    {
        return Ok(
            await _service.ObtenerAsync(
                UsuarioId(), dias, kilometros, ct));
    }

    private Guid UsuarioId() =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}