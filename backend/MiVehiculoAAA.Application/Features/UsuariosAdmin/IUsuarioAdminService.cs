using MiVehiculoAAA.Application.Features.UsuariosAdmin.Dtos;

namespace MiVehiculoAAA.Application.Features.UsuariosAdmin;

public interface IUsuarioAdminService
{
    Task<IReadOnlyList<UsuarioAdminDto>> ObtenerTodosAsync(
        CancellationToken cancellationToken = default
    );

    Task<UsuarioAdminDto?> ObtenerPorIdAsync(
        Guid usuarioId,
        CancellationToken cancellationToken = default
    );

    Task<UsuarioAdminDto> CrearAsync(
        CrearUsuarioAdminRequest request,
        CancellationToken cancellationToken = default
    );

    Task<UsuarioAdminDto> ActualizarAsync(
        Guid usuarioId,
        ActualizarUsuarioAdminRequest request,
        CancellationToken cancellationToken = default
    );

    Task DesactivarAsync(
        Guid usuarioId,
        Guid administradorEjecutorId,
        CancellationToken cancellationToken = default
    );
}