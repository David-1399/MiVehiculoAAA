using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.Gastos;
using MiVehiculoAAA.Application.Features.Gastos.Dtos;

namespace MiVehiculoAAA.Api.Controllers;

[ApiController]
[Authorize]
public class GastosController : ControllerBase
{
    private readonly IGastoService _service;

    public GastosController(IGastoService service) => _service = service;

    [HttpGet("api/vehiculos/{vehiculoId:guid}/gastos")]
    public async Task<IActionResult> Listar(Guid vehiculoId, CancellationToken ct)
    {
        try { return Ok(await _service.ObtenerPorVehiculoAsync(UsuarioId(), vehiculoId, ct)); }
        catch (AppException ex) { return StatusCode(ex.StatusCode, new { mensaje = ex.Message }); }
    }

    [HttpPost("api/vehiculos/{vehiculoId:guid}/gastos")]
    public async Task<IActionResult> Crear(
        Guid vehiculoId, GastoRequest request, CancellationToken ct)
    {
        try
        {
            return StatusCode(201,
                await _service.CrearAsync(UsuarioId(), vehiculoId, request, ct));
        }
        catch (AppException ex) { return StatusCode(ex.StatusCode, new { mensaje = ex.Message }); }
    }

    [HttpPut("api/gastos/{id:guid}")]
    public async Task<IActionResult> Actualizar(
        Guid id, GastoRequest request, CancellationToken ct)
    {
        try { return Ok(await _service.ActualizarAsync(UsuarioId(), id, request, ct)); }
        catch (AppException ex) { return StatusCode(ex.StatusCode, new { mensaje = ex.Message }); }
    }

    [HttpDelete("api/gastos/{id:guid}")]
    public async Task<IActionResult> Eliminar(Guid id, CancellationToken ct)
    {
        try
        {
            await _service.EliminarAsync(UsuarioId(), id, ct);
            return Ok(new { mensaje = "Gasto eliminado correctamente." });
        }
        catch (AppException ex) { return StatusCode(ex.StatusCode, new { mensaje = ex.Message }); }
    }

    private Guid UsuarioId() =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}