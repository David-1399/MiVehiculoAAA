namespace MiVehiculoAAA.Application.Features.Auth.Dtos;

public class AuthResponse
{
    public UsuarioSesionDto Usuario { get; set; } = new();
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiraEn { get; set; }
}