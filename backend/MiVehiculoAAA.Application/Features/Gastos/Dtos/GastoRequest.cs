using System.ComponentModel.DataAnnotations;

namespace MiVehiculoAAA.Application.Features.Gastos.Dtos;

public class GastoRequest
{
    [Required]
    public Guid CategoriaGastoId { get; set; }

    [Required]
    [MaxLength(300)]
    public string Descripcion { get; set; } = string.Empty;


    public decimal Valor { get; set; }

    public DateOnly Fecha { get; set; }

    [MaxLength(500)]
    public string? RutaSoporte { get; set; }

    [MaxLength(500)]
    public string? Observaciones { get; set; }
}