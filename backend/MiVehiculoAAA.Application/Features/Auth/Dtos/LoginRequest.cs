using System.ComponentModel.DataAnnotations;

namespace MiVehiculoAAA.Application.Features.Auth.Dtos;

public class LoginRequest
{
    [Required]
    [EmailAddress]
    public string Correo { get; set; } = string.Empty;

    [Required]
    public string Password { get; set; } = string.Empty;
}