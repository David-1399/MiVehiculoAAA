using System.ComponentModel.DataAnnotations;

namespace MiVehiculoAAA.Application.Features.Kilometrajes.Dtos;

public class RegistrarKilometrajeRequest
{
    [Range(0, int.MaxValue)]
    public int Kilometraje { get; set; }

    public DateOnly? Fecha { get; set; }

    [MaxLength(300)]
    public string? Observaciones { get; set; }
}