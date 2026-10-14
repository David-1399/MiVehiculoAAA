using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.Alertas;

namespace MiVehiculoAAA.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/alertas")]
public class AlertasController : ControllerBase
{
    private readonly IAlertaService _service;

    public AlertasController(IAlertaService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> Obtener(CancellationToken ct)
    {
        var usuarioId = UsuarioId();
        await _service.GenerarAlertasAutomaticasAsync(usuarioId, ct);
        return Ok(await _service.ObtenerAsync(usuarioId, ct));
    }

    [HttpPost("generar")]
    public async Task<IActionResult> Generar(CancellationToken ct)
    {
        var cantidad =
            await _service.GenerarAlertasAutomaticasAsync(
                UsuarioId(), ct);

        return Ok(new { alertasCreadas = cantidad });
    }

    [HttpPut("{id:guid}/leida")]
    public async Task<IActionResult> MarcarLeida(Guid id, CancellationToken ct)
    {
        try
        {
            await _service.MarcarLeidaAsync(UsuarioId(), id, ct);
            return Ok(new { mensaje = "Alerta marcada como leída." });
        }
        catch (AppException ex)
        {
            return StatusCode(ex.StatusCode, new { mensaje = ex.Message });
        }
    }

    private Guid UsuarioId() =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}