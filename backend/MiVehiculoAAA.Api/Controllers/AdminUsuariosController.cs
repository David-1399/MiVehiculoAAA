using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.UsuariosAdmin;
using MiVehiculoAAA.Application.Features.UsuariosAdmin.Dtos;

namespace MiVehiculoAAA.Api.Controllers;

[ApiController]
[Authorize(Roles = "ADMINISTRADOR")]
[Route("api/admin/usuarios")]
public class AdminUsuariosController : ControllerBase
{
    private readonly IUsuarioAdminService _usuarioAdminService;

    public AdminUsuariosController(
        IUsuarioAdminService usuarioAdminService
    )
    {
        _usuarioAdminService = usuarioAdminService;
    }

    [HttpGet]
    public async Task<IActionResult> ObtenerTodos(
        CancellationToken cancellationToken
    )
    {
        var usuarios =
            await _usuarioAdminService.ObtenerTodosAsync(
                cancellationToken
            );

        return Ok(usuarios);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> ObtenerPorId(
        Guid id,
        CancellationToken cancellationToken
    )
    {
        var usuario =
            await _usuarioAdminService.ObtenerPorIdAsync(
                id,
                cancellationToken
            );

        if (usuario is null)
        {
            return NotFound(
                new { mensaje = "Usuario no encontrado." }
            );
        }

        return Ok(usuario);
    }

    [HttpPost]
    public async Task<IActionResult> Crear(
        [FromBody] CrearUsuarioAdminRequest request,
        CancellationToken cancellationToken
    )
    {
        try
        {
            var usuario =
                await _usuarioAdminService.CrearAsync(
                    request,
                    cancellationToken
                );

            return StatusCode(201, usuario);
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
        [FromBody] ActualizarUsuarioAdminRequest request,
        CancellationToken cancellationToken
    )
    {
        try
        {
            var usuario =
                await _usuarioAdminService.ActualizarAsync(
                    id,
                    request,
                    cancellationToken
                );

            return Ok(usuario);
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
    public async Task<IActionResult> Desactivar(
        Guid id,
        CancellationToken cancellationToken
    )
    {
        try
        {
            var administradorId =
                ObtenerUsuarioActualId();

            await _usuarioAdminService.DesactivarAsync(
                id,
                administradorId,
                cancellationToken
            );

            return Ok(
                new
                {
                    mensaje = "Usuario desactivado correctamente."
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

    private Guid ObtenerUsuarioActualId()
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