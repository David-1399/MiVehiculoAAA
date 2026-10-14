namespace MiVehiculoAAA.Application.Features.ProximosMantenimientos.Dtos;

public class ProximoMantenimientoDto
{
    public Guid MantenimientoId { get; set; }
    public Guid VehiculoId { get; set; }
    public string Vehiculo { get; set; } = string.Empty;
    public string Placa { get; set; } = string.Empty;
    public string TipoMantenimiento { get; set; } = string.Empty;
    public DateOnly? ProximaFecha { get; set; }
    public int? ProximoKilometraje { get; set; }
    public int KilometrajeActual { get; set; }
    public int? KilometrosRestantes { get; set; }
    public int? DiasRestantes { get; set; }
}