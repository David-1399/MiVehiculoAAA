using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.Kilometrajes;
using MiVehiculoAAA.Application.Features.Kilometrajes.Dtos;

namespace MiVehiculoAAA.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/vehiculos/{vehiculoId:guid}/kilometrajes")]
public class KilometrajesController : ControllerBase
{
    private readonly IKilometrajeService _service;

    public KilometrajesController(IKilometrajeService service) => _service = service;

    [HttpGet]
    public async Task<IActionResult> Obtener(
        Guid vehiculoId, CancellationToken cancellationToken)
    {
        try
        {
            return Ok(await _service.ObtenerAsync(
                UsuarioId(), vehiculoId, cancellationToken));
        }
        catch (AppException ex)
        {
            return StatusCode(ex.StatusCode, new { mensaje = ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> Registrar(
        Guid vehiculoId, RegistrarKilometrajeRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            return StatusCode(201, await _service.RegistrarAsync(
                UsuarioId(), vehiculoId, request, cancellationToken));
        }
        catch (AppException ex)
        {
            return StatusCode(ex.StatusCode, new { mensaje = ex.Message });
        }
    }

    private Guid UsuarioId() =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}