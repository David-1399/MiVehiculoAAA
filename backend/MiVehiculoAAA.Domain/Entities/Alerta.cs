namespace MiVehiculoAAA.Domain.Entities;

public class Alerta
{
    public Guid Id { get; set; }
    public Guid? UsuarioId { get; set; }
    public Guid? VehiculoId { get; set; }

    public string Tipo { get; set; } = string.Empty;
    public string Titulo { get; set; } = string.Empty;
    public string Mensaje { get; set; } = string.Empty;

    public DateTime FechaAlerta { get; set; }
    public bool Leida { get; set; }
    public DateTime? FechaLectura { get; set; }
    public bool Activa { get; set; } = true;

    public Usuario? Usuario { get; set; }
    public Vehiculo? Vehiculo { get; set; }
}