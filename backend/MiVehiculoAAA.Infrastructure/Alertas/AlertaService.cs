using Microsoft.EntityFrameworkCore;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.Alertas;
using MiVehiculoAAA.Application.Features.Alertas.Dtos;
using MiVehiculoAAA.Domain.Entities;
using MiVehiculoAAA.Infrastructure.Data;

namespace MiVehiculoAAA.Infrastructure.Alertas;

public class AlertaService : IAlertaService
{
    private readonly MiVehiculoDbContext _dbContext;

    public AlertaService(MiVehiculoDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<AlertaDto>> ObtenerAsync(
        Guid usuarioId,
        CancellationToken cancellationToken = default
    )
    {
        return await _dbContext.Alertas
            .AsNoTracking()
            .Where(x => x.UsuarioId == usuarioId && x.Activa)
            .OrderBy(x => x.Leida)
            .ThenByDescending(x => x.FechaAlerta)
            .Select(x => new AlertaDto
            {
                Id = x.Id,
                VehiculoId = x.VehiculoId,
                Tipo = x.Tipo,
                Titulo = x.Titulo,
                Mensaje = x.Mensaje,
                FechaAlerta = x.FechaAlerta,
                Leida = x.Leida,
                FechaLectura = x.FechaLectura
            })
            .ToListAsync(cancellationToken);
    }

    public async Task MarcarLeidaAsync(
        Guid usuarioId,
        Guid alertaId,
        CancellationToken cancellationToken = default
    )
    {
        var alerta = await _dbContext.Alertas.FirstOrDefaultAsync(
            x => x.Id == alertaId &&
                 x.UsuarioId == usuarioId &&
                 x.Activa,
            cancellationToken
        );

        if (alerta is null)
        {
            throw new AppException("Alerta no encontrada.", 404);
        }

        if (!alerta.Leida)
        {
            alerta.Leida = true;
            alerta.FechaLectura = DateTime.UtcNow;
            await _dbContext.SaveChangesAsync(cancellationToken);
        }
    }

    public async Task<int> GenerarAlertasAutomaticasAsync(
        Guid usuarioId,
        CancellationToken cancellationToken = default
    )
    {
        var hoy = DateOnly.FromDateTime(DateTime.UtcNow);
        var limite = hoy.AddDays(30);
        var ahora = DateTime.UtcNow;
        var creadas = 0;

        var documentos = await _dbContext.Documentos
            .AsNoTracking()
            .Where(x =>
                x.Vehiculo.UsuarioId == usuarioId &&
                x.Vehiculo.Activo &&
                x.FechaVencimiento.HasValue &&
                x.FechaVencimiento.Value <= limite)
            .Select(x => new
            {
                x.Id,
                x.VehiculoId,
                Tipo = x.TipoDocumento.Nombre,
                x.Vehiculo.Placa,
                x.FechaVencimiento
            })
            .ToListAsync(cancellationToken);

        foreach (var doc in documentos)
        {
            var clave = $"DOC:{doc.Id}";
            var existe = await _dbContext.Alertas.AnyAsync(
                x => x.UsuarioId == usuarioId &&
                     x.Tipo == "DOCUMENTO" &&
                     x.Mensaje.Contains(clave) &&
                     x.Activa,
                cancellationToken
            );

            if (!existe)
            {
                _dbContext.Alertas.Add(new Alerta
                {
                    Id = Guid.NewGuid(),
                    UsuarioId = usuarioId,
                    VehiculoId = doc.VehiculoId,
                    Tipo = "DOCUMENTO",
                    Titulo = "Documento próximo a vencer",
                    Mensaje =
                        $"{doc.Tipo} del vehículo {doc.Placa} vence el {doc.FechaVencimiento:yyyy-MM-dd}. [{clave}]",
                    FechaAlerta = ahora,
                    Leida = false,
                    Activa = true
                });
                creadas++;
            }
        }

        var mantenimientos = await _dbContext.Mantenimientos
            .AsNoTracking()
            .Where(x =>
                x.Vehiculo.UsuarioId == usuarioId &&
                x.Vehiculo.Activo &&
                (
                    (x.ProximaFecha.HasValue && x.ProximaFecha.Value <= limite) ||
                    (x.ProximoKilometraje.HasValue &&
                     x.ProximoKilometraje.Value <= x.Vehiculo.Kilometraje + 1000)
                ))
            .Select(x => new
            {
                x.Id,
                x.VehiculoId,
                Tipo = x.TipoMantenimiento.Nombre,
                x.Vehiculo.Placa,
                x.ProximaFecha,
                x.ProximoKilometraje,
                Actual = x.Vehiculo.Kilometraje
            })
            .ToListAsync(cancellationToken);

        foreach (var mant in mantenimientos)
        {
            var clave = $"MANT:{mant.Id}";
            var existe = await _dbContext.Alertas.AnyAsync(
                x => x.UsuarioId == usuarioId &&
                     x.Tipo == "MANTENIMIENTO" &&
                     x.Mensaje.Contains(clave) &&
                     x.Activa,
                cancellationToken
            );

            if (!existe)
            {
                var detalleFecha = mant.ProximaFecha.HasValue
                    ? $" fecha {mant.ProximaFecha:yyyy-MM-dd}"
                    : string.Empty;

                var detalleKm = mant.ProximoKilometraje.HasValue
                    ? $" kilometraje {mant.ProximoKilometraje} km (actual {mant.Actual} km)"
                    : string.Empty;

                _dbContext.Alertas.Add(new Alerta
                {
                    Id = Guid.NewGuid(),
                    UsuarioId = usuarioId,
                    VehiculoId = mant.VehiculoId,
                    Tipo = "MANTENIMIENTO",
                    Titulo = "Mantenimiento próximo",
                    Mensaje =
                        $"{mant.Tipo} del vehículo {mant.Placa}:{detalleFecha}{detalleKm}. [{clave}]",
                    FechaAlerta = ahora,
                    Leida = false,
                    Activa = true
                });
                creadas++;
            }
        }

        if (creadas > 0)
        {
            await _dbContext.SaveChangesAsync(cancellationToken);
        }

        return creadas;
    }
}