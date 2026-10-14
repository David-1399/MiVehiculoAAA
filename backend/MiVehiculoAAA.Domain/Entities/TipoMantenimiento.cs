namespace MiVehiculoAAA.Domain.Entities;

public class TipoMantenimiento
{
    public Guid Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Categoria { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public bool Activo { get; set; } = true;

    public ICollection<Mantenimiento> Mantenimientos { get; set; } =
        new List<Mantenimiento>();
}