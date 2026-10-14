namespace MiVehiculoAAA.Domain.Entities;

public class Gasto
{
    public Guid Id { get; set; }
    public Guid VehiculoId { get; set; }
    public Guid CategoriaGastoId { get; set; }

    public string? Descripcion { get; set; }
    public decimal Valor { get; set; }
    public DateOnly Fecha { get; set; }
    public string? RutaSoporte { get; set; }
    public string? Observaciones { get; set; }

    public DateTime FechaCreacion { get; set; }

    public Vehiculo Vehiculo { get; set; } = null!;
    public CategoriaGasto CategoriaGasto { get; set; } = null!;
}