namespace MiVehiculoAAA.Domain.Entities;

public class Kilometraje
{
    public Guid Id { get; set; }
    public Guid VehiculoId { get; set; }

    public int Valor { get; set; }
    public DateOnly Fecha { get; set; }
    public string? Observaciones { get; set; }
    public DateTime FechaCreacion { get; set; }

    public Vehiculo Vehiculo { get; set; } = null!;
}