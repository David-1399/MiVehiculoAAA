namespace MiVehiculoAAA.Application.Features.Gastos.Dtos;

public class GastoDto
{
    public Guid Id { get; set; }
    public Guid VehiculoId { get; set; }
    public Guid CategoriaGastoId { get; set; }
    public string CategoriaGasto { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public decimal Valor { get; set; }
    public DateOnly Fecha { get; set; }
    public string? RutaSoporte { get; set; }
    public string? Observaciones { get; set; }
    public DateTime FechaCreacion { get; set; }
}