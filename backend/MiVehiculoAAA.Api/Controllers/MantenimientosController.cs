using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.Mantenimientos;
using MiVehiculoAAA.Application.Features.Mantenimientos.Dtos;

namespace MiVehiculoAAA.Api.Controllers;

[ApiController]
[Authorize]
public class MantenimientosController : ControllerBase
{
    private readonly IMantenimientoService _service;

    public MantenimientosController(IMantenimientoService service) => _service = service;

    [HttpGet("api/vehiculos/{vehiculoId:guid}/mantenimientos")]
    public async Task<IActionResult> Listar(Guid vehiculoId, CancellationToken ct)
    {
        try { return Ok(await _service.ObtenerPorVehiculoAsync(UsuarioId(), vehiculoId, ct)); }
        catch (AppException ex) { return StatusCode(ex.StatusCode, new { mensaje = ex.Message }); }
    }

    [HttpGet("api/mantenimientos/{id:guid}")]
    public async Task<IActionResult> Obtener(Guid id, CancellationToken ct)
    {
        var item = await _service.ObtenerPorIdAsync(UsuarioId(), id, ct);
        return item is null
            ? NotFound(new { mensaje = "Mantenimiento no encontrado." })
            : Ok(item);
    }

    [HttpPost("api/vehiculos/{vehiculoId:guid}/mantenimientos")]
    public async Task<IActionResult> Crear(
        Guid vehiculoId, MantenimientoRequest request, CancellationToken ct)
    {
        try
        {
            return StatusCode(201,
                await _service.CrearAsync(UsuarioId(), vehiculoId, request, ct));
        }
        catch (AppException ex) { return StatusCode(ex.StatusCode, new { mensaje = ex.Message }); }
    }

    [HttpPut("api/mantenimientos/{id:guid}")]
    public async Task<IActionResult> Actualizar(
        Guid id, MantenimientoRequest request, CancellationToken ct)
    {
        try { return Ok(await _service.ActualizarAsync(UsuarioId(), id, request, ct)); }
        catch (AppException ex) { return StatusCode(ex.StatusCode, new { mensaje = ex.Message }); }
    }

    [HttpDelete("api/mantenimientos/{id:guid}")]
    public async Task<IActionResult> Eliminar(Guid id, CancellationToken ct)
    {
        try
        {
            await _service.EliminarAsync(UsuarioId(), id, ct);
            return Ok(new { mensaje = "Mantenimiento eliminado correctamente." });
        }
        catch (AppException ex) { return StatusCode(ex.StatusCode, new { mensaje = ex.Message }); }
    }

    private Guid UsuarioId() =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}