namespace MiVehiculoAAA.Application.Features.Catalogos.Dtos;

public class CatalogoItemDto
{
    public Guid Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
}