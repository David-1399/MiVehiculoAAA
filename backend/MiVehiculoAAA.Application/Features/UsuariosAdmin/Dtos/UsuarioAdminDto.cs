namespace MiVehiculoAAA.Application.Features.UsuariosAdmin.Dtos;

public class UsuarioAdminDto
{
    public Guid Id { get; set; }
    public Guid RolId { get; set; }
    public string Rol { get; set; } = string.Empty;
    public string Nombres { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public string? Telefono { get; set; }
    public string Correo { get; set; } = string.Empty;
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaActualizacion { get; set; }
}