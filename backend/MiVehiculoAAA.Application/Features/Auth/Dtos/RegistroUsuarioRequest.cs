using System.ComponentModel.DataAnnotations;

namespace MiVehiculoAAA.Application.Features.Auth.Dtos;

public class RegistroUsuarioRequest
{
    [Required]
    [MaxLength(80)]
    public string Nombres { get; set; } = string.Empty;

    [Required]
    [MaxLength(80)]
    public string Apellidos { get; set; } = string.Empty;

    [MaxLength(20)]
    public string? Telefono { get; set; }

    [Required]
    [EmailAddress]
    [MaxLength(120)]
    public string Correo { get; set; } = string.Empty;

    [Required]
    [MinLength(6)]
    [MaxLength(100)]
    public string Password { get; set; } = string.Empty;
}