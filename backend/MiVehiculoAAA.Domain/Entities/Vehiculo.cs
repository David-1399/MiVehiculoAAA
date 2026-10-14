namespace MiVehiculoAAA.Domain.Entities;

public class Vehiculo
{
    public Guid Id { get; set; }
    public Guid UsuarioId { get; set; }
    public Guid TipoVehiculoId { get; set; }

    public string Marca { get; set; } = string.Empty;
    public string Modelo { get; set; } = string.Empty;
    public int Anio { get; set; }
    public string Placa { get; set; } = string.Empty;
    public int Kilometraje { get; set; }

    public bool Activo { get; set; } = true;
    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaActualizacion { get; set; }

    public Usuario Usuario { get; set; } = null!;
    public TipoVehiculo TipoVehiculo { get; set; } = null!;

    public ICollection<Mantenimiento> Mantenimientos { get; set; } =
        new List<Mantenimiento>();

    public ICollection<Kilometraje> Kilometrajes { get; set; } =
        new List<Kilometraje>();

    public ICollection<Documento> Documentos { get; set; } =
        new List<Documento>();

    public ICollection<Gasto> Gastos { get; set; } =
        new List<Gasto>();

    public ICollection<Alerta> Alertas { get; set; } =
        new List<Alerta>();
}