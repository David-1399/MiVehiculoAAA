namespace MiVehiculoAAA.Application.Features.Kilometrajes.Dtos;

public class KilometrajeDto
{
    public Guid Id { get; set; }
    public Guid VehiculoId { get; set; }
    public int Kilometraje { get; set; }
    public DateOnly Fecha { get; set; }
    public string? Observaciones { get; set; }
    public DateTime FechaCreacion { get; set; }
}