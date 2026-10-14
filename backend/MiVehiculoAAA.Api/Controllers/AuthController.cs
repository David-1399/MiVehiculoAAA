using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.Auth;
using MiVehiculoAAA.Application.Features.Auth.Dtos;

namespace MiVehiculoAAA.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [AllowAnonymous]
    [HttpPost("registro")]
    public async Task<IActionResult> Registro(
        [FromBody] RegistroUsuarioRequest request,
        CancellationToken cancellationToken
    )
    {
        try
        {
            var response =
                await _authService.RegistrarAsync(
                    request,
                    cancellationToken
                );

            return StatusCode(201, response);
        }
        catch (AppException ex)
        {
            return StatusCode(
                ex.StatusCode,
                new { mensaje = ex.Message }
            );
        }
    }

    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<IActionResult> Login(
        [FromBody] LoginRequest request,
        CancellationToken cancellationToken
    )
    {
        try
        {
            var response =
                await _authService.LoginAsync(
                    request,
                    cancellationToken
                );

            return Ok(response);
        }
        catch (AppException ex)
        {
            return StatusCode(
                ex.StatusCode,
                new { mensaje = ex.Message }
            );
        }
    }

    [Authorize]
    [HttpGet("perfil")]
    public async Task<IActionResult> Perfil(
        CancellationToken cancellationToken
    )
    {
        var idText =
            User.FindFirstValue(
                ClaimTypes.NameIdentifier
            );

        if (!Guid.TryParse(idText, out var usuarioId))
        {
            return Unauthorized(
                new { mensaje = "Token invalido." }
            );
        }

        var perfil =
            await _authService.ObtenerPerfilAsync(
                usuarioId,
                cancellationToken
            );

        if (perfil is null)
        {
            return NotFound(
                new { mensaje = "Usuario no encontrado." }
            );
        }

        return Ok(perfil);
    }

    [Authorize]
    [HttpPost("logout")]
    public IActionResult Logout()
    {
        return Ok(new
        {
            mensaje =
                "Sesion cerrada. El cliente debe eliminar el token almacenado."
        });
    }
}