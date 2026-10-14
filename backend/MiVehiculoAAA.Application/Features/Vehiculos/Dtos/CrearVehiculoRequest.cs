using System.ComponentModel.DataAnnotations;

namespace MiVehiculoAAA.Application.Features.Vehiculos.Dtos;

public class CrearVehiculoRequest
{
    [Required]
    public Guid TipoVehiculoId { get; set; }

    [Required]
    [MaxLength(50)]
    public string Marca { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string Modelo { get; set; } = string.Empty;

    [Range(1900, 2100)]
    public int Anio { get; set; }

    [Required]
    [MaxLength(15)]
    public string Placa { get; set; } = string.Empty;

    [Range(0, int.MaxValue)]
    public int Kilometraje { get; set; }
}