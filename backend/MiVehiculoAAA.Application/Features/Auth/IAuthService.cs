using MiVehiculoAAA.Application.Features.Auth.Dtos;

namespace MiVehiculoAAA.Application.Features.Auth;

public interface IAuthService
{
    Task<AuthResponse> RegistrarAsync(
        RegistroUsuarioRequest request,
        CancellationToken cancellationToken = default
    );

    Task<AuthResponse> LoginAsync(
        LoginRequest request,
        CancellationToken cancellationToken = default
    );

    Task<PerfilResponse?> ObtenerPerfilAsync(
        Guid usuarioId,
        CancellationToken cancellationToken = default
    );
}