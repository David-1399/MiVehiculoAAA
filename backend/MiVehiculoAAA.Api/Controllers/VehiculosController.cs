using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.Vehiculos;
using MiVehiculoAAA.Application.Features.Vehiculos.Dtos;

namespace MiVehiculoAAA.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/vehiculos")]
public class VehiculosController : ControllerBase
{
    private readonly IVehiculoService _vehiculoService;

    public VehiculosController(IVehiculoService vehiculoService)
    {
        _vehiculoService = vehiculoService;
    }

    [HttpGet]
    public async Task<IActionResult> ObtenerTodos(
        CancellationToken cancellationToken
    )
    {
        var usuarioId = ObtenerUsuarioId();

        return Ok(
            await _vehiculoService.ObtenerTodosAsync(
                usuarioId,
                cancellationToken
            )
        );
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> ObtenerPorId(
        Guid id,
        CancellationToken cancellationToken
    )
    {
        var usuarioId = ObtenerUsuarioId();

        var vehiculo =
            await _vehiculoService.ObtenerPorIdAsync(
                usuarioId,
                id,
                cancellationToken
            );

        if (vehiculo is null)
        {
            return NotFound(
                new { mensaje = "Vehiculo no encontrado." }
            );
        }

        return Ok(vehiculo);
    }

    [HttpPost]
    public async Task<IActionResult> Crear(
        [FromBody] CrearVehiculoRequest request,
        CancellationToken cancellationToken
    )
    {
        try
        {
            var usuarioId = ObtenerUsuarioId();

            var vehiculo =
                await _vehiculoService.CrearAsync(
                    usuarioId,
                    request,
                    cancellationToken
                );

            return CreatedAtAction(
                nameof(ObtenerPorId),
                new { id = vehiculo.Id },
                vehiculo
            );
        }
        catch (AppException ex)
        {
            return StatusCode(
                ex.StatusCode,
                new { mensaje = ex.Message }
            );
        }
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Actualizar(
        Guid id,
        [FromBody] ActualizarVehiculoRequest request,
        CancellationToken cancellationToken
    )
    {
        try
        {
            var usuarioId = ObtenerUsuarioId();

            return Ok(
                await _vehiculoService.ActualizarAsync(
                    usuarioId,
                    id,
                    request,
                    cancellationToken
                )
            );
        }
        catch (AppException ex)
        {
            return StatusCode(
                ex.StatusCode,
                new { mensaje = ex.Message }
            );
        }
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Eliminar(
        Guid id,
        CancellationToken cancellationToken
    )
    {
        try
        {
            var usuarioId = ObtenerUsuarioId();

            await _vehiculoService.EliminarAsync(
                usuarioId,
                id,
                cancellationToken
            );

            return Ok(
                new
                {
                    mensaje =
                        "Vehiculo eliminado correctamente."
                }
            );
        }
        catch (AppException ex)
        {
            return StatusCode(
                ex.StatusCode,
                new { mensaje = ex.Message }
            );
        }
    }

    private Guid ObtenerUsuarioId()
    {
        var idText =
            User.FindFirstValue(
                ClaimTypes.NameIdentifier
            );

        if (!Guid.TryParse(idText, out var usuarioId))
        {
            throw new AppException(
                "Token invalido.",
                401
            );
        }

        return usuarioId;
    }
}