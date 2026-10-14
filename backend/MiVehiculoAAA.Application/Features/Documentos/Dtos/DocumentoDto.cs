namespace MiVehiculoAAA.Application.Features.Documentos.Dtos;

public class DocumentoDto
{
    public Guid Id { get; set; }
    public Guid VehiculoId { get; set; }
    public Guid TipoDocumentoId { get; set; }
    public string TipoDocumento { get; set; } = string.Empty;
    public string? NumeroReferencia { get; set; }
    public string? EntidadEmisora { get; set; }
    public DateOnly? FechaExpedicion { get; set; }
    public DateOnly? FechaVencimiento { get; set; }
    public string? RutaArchivo { get; set; }
    public string? Observaciones { get; set; }
    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaActualizacion { get; set; }
}