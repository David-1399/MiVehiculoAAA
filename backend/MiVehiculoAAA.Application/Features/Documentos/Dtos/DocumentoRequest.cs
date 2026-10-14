using System.ComponentModel.DataAnnotations;

namespace MiVehiculoAAA.Application.Features.Documentos.Dtos;

public class DocumentoRequest
{
    [Required]
    public Guid TipoDocumentoId { get; set; }

    [MaxLength(100)]
    public string? NumeroReferencia { get; set; }

    [MaxLength(150)]
    public string? EntidadEmisora { get; set; }

    public DateOnly? FechaExpedicion { get; set; }
    public DateOnly? FechaVencimiento { get; set; }

    [MaxLength(500)]
    public string? RutaArchivo { get; set; }

    [MaxLength(500)]
    public string? Observaciones { get; set; }
}