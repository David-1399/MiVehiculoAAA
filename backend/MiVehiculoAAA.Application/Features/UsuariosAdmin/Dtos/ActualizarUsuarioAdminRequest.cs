using System.ComponentModel.DataAnnotations;

namespace MiVehiculoAAA.Application.Features.UsuariosAdmin.Dtos;

public class ActualizarUsuarioAdminRequest
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
    [MaxLength(30)]
    public string Rol { get; set; } = string.Empty;

    [MinLength(6)]
    [MaxLength(100)]
    public string? Password { get; set; }
}