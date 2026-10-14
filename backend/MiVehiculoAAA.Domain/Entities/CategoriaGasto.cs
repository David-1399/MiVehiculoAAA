namespace MiVehiculoAAA.Domain.Entities;

public class CategoriaGasto
{
    public Guid Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public bool Activo { get; set; } = true;

    public ICollection<Gasto> Gastos { get; set; } = new List<Gasto>();
}