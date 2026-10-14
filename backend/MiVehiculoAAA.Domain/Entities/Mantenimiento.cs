namespace MiVehiculoAAA.Domain.Entities;

public class Mantenimiento
{
    public Guid Id { get; set; }
    public Guid VehiculoId { get; set; }
    public Guid TipoMantenimientoId { get; set; }

    public string? Descripcion { get; set; }
    public DateOnly Fecha { get; set; }
    public int? Kilometraje { get; set; }
    public decimal? Costo { get; set; }
    public string? Taller { get; set; }
    public int? ProximoKilometraje { get; set; }
    public DateOnly? ProximaFecha { get; set; }
    public string? Observaciones { get; set; }

    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaActualizacion { get; set; }

    public Vehiculo Vehiculo { get; set; } = null!;
    public TipoMantenimiento TipoMantenimiento { get; set; } = null!;
}