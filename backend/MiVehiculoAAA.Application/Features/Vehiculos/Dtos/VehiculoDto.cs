namespace MiVehiculoAAA.Application.Features.Vehiculos.Dtos;

public class VehiculoDto
{
    public Guid Id { get; set; }
    public Guid TipoVehiculoId { get; set; }
    public string TipoVehiculo { get; set; } = string.Empty;
    public string Marca { get; set; } = string.Empty;
    public string Modelo { get; set; } = string.Empty;
    public int Anio { get; set; }
    public string Placa { get; set; } = string.Empty;
    public int Kilometraje { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaActualizacion { get; set; }
}