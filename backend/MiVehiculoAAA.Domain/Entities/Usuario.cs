namespace MiVehiculoAAA.Domain.Entities;

public class Usuario
{
    public Guid Id { get; set; }
    public Guid RolId { get; set; }

    public string Nombres { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public string? Telefono { get; set; }
    public string Correo { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;

    public bool Activo { get; set; } = true;
    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaActualizacion { get; set; }

    public Rol Rol { get; set; } = null!;
    public ICollection<Vehiculo> Vehiculos { get; set; } = new List<Vehiculo>();
    public ICollection<Alerta> Alertas { get; set; } = new List<Alerta>();
}