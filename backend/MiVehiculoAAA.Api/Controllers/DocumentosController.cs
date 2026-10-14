using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.Documentos;
using MiVehiculoAAA.Application.Features.Documentos.Dtos;

namespace MiVehiculoAAA.Api.Controllers;

[ApiController]
[Authorize]
public class DocumentosController : ControllerBase
{
    private readonly IDocumentoService _service;

    public DocumentosController(IDocumentoService service) => _service = service;

    [HttpGet("api/vehiculos/{vehiculoId:guid}/documentos")]
    public async Task<IActionResult> Listar(Guid vehiculoId, CancellationToken ct)
    {
        try { return Ok(await _service.ObtenerPorVehiculoAsync(UsuarioId(), vehiculoId, ct)); }
        catch (AppException ex) { return StatusCode(ex.StatusCode, new { mensaje = ex.Message }); }
    }

    [HttpPost("api/vehiculos/{vehiculoId:guid}/documentos")]
    public async Task<IActionResult> Crear(
        Guid vehiculoId, DocumentoRequest request, CancellationToken ct)
    {
        try
        {
            return StatusCode(201,
                await _service.CrearAsync(UsuarioId(), vehiculoId, request, ct));
        }
        catch (AppException ex) { return StatusCode(ex.StatusCode, new { mensaje = ex.Message }); }
    }

    [HttpPut("api/documentos/{id:guid}")]
    public async Task<IActionResult> Actualizar(
        Guid id, DocumentoRequest request, CancellationToken ct)
    {
        try { return Ok(await _service.ActualizarAsync(UsuarioId(), id, request, ct)); }
        catch (AppException ex) { return StatusCode(ex.StatusCode, new { mensaje = ex.Message }); }
    }

    [HttpDelete("api/documentos/{id:guid}")]
    public async Task<IActionResult> Eliminar(Guid id, CancellationToken ct)
    {
        try
        {
            await _service.EliminarAsync(UsuarioId(), id, ct);
            return Ok(new { mensaje = "Documento eliminado correctamente." });
        }
        catch (AppException ex) { return StatusCode(ex.StatusCode, new { mensaje = ex.Message }); }
    }

    private Guid UsuarioId() =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}