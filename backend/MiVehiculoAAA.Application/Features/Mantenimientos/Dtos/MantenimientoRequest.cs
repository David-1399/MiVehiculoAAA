using System.ComponentModel.DataAnnotations;

namespace MiVehiculoAAA.Application.Features.Mantenimientos.Dtos;

public class MantenimientoRequest
{
    [Required]
    public Guid TipoMantenimientoId { get; set; }

    [Required]
    [MaxLength(300)]
    public string Descripcion { get; set; } = string.Empty;

    public DateOnly Fecha { get; set; }

    [Range(0, int.MaxValue)]
    public int? Kilometraje { get; set; }


    public decimal Costo { get; set; }

    [MaxLength(150)]
    public string? Taller { get; set; }

    [Range(0, int.MaxValue)]
    public int? ProximoKilometraje { get; set; }

    public DateOnly? ProximaFecha { get; set; }

    [MaxLength(500)]
    public string? Observaciones { get; set; }
}