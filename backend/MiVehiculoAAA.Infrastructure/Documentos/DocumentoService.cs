using Microsoft.EntityFrameworkCore;
using MiVehiculoAAA.Application.Common.Exceptions;
using MiVehiculoAAA.Application.Features.Documentos;
using MiVehiculoAAA.Application.Features.Documentos.Dtos;
using MiVehiculoAAA.Domain.Entities;
using MiVehiculoAAA.Infrastructure.Data;

namespace MiVehiculoAAA.Infrastructure.Documentos;

public class DocumentoService : IDocumentoService
{
    private readonly MiVehiculoDbContext _dbContext;

    public DocumentoService(MiVehiculoDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<DocumentoDto>> ObtenerPorVehiculoAsync(
        Guid usuarioId, Guid vehiculoId, CancellationToken cancellationToken = default)
    {
        await ValidarVehiculoAsync(usuarioId, vehiculoId, cancellationToken);

        return await Query(usuarioId)
            .Where(x => x.VehiculoId == vehiculoId)
            .OrderBy(x => x.FechaVencimiento)
            .Select(x => new DocumentoDto
            {
                Id = x.Id,
                VehiculoId = x.VehiculoId,
                TipoDocumentoId = x.TipoDocumentoId,
                TipoDocumento = x.TipoDocumento.Nombre,
                NumeroReferencia = x.NumeroReferencia,
                EntidadEmisora = x.EntidadEmisora,
                FechaExpedicion = x.FechaExpedicion,
                FechaVencimiento = x.FechaVencimiento,
                RutaArchivo = x.RutaArchivo,
                Observaciones = x.Observaciones,
                FechaCreacion = x.FechaCreacion,
                FechaActualizacion = x.FechaActualizacion
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<DocumentoDto> CrearAsync(
        Guid usuarioId, Guid vehiculoId, DocumentoRequest request,
        CancellationToken cancellationToken = default)
    {
        await ValidarVehiculoAsync(usuarioId, vehiculoId, cancellationToken);
        await ValidarTipoAsync(request.TipoDocumentoId, cancellationToken);
        ValidarFechas(request);

        var item = new Documento
        {
            Id = Guid.NewGuid(),
            VehiculoId = vehiculoId,
            TipoDocumentoId = request.TipoDocumentoId,
            NumeroReferencia = Normalizar(request.NumeroReferencia),
            EntidadEmisora = Normalizar(request.EntidadEmisora),
            FechaExpedicion = request.FechaExpedicion,
            FechaVencimiento = request.FechaVencimiento,
            RutaArchivo = Normalizar(request.RutaArchivo),
            Observaciones = Normalizar(request.Observaciones),
            FechaCreacion = DateTime.UtcNow
        };

        _dbContext.Documentos.Add(item);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return await ObtenerUnoAsync(usuarioId, item.Id, cancellationToken)
            ?? throw new AppException("No fue posible obtener el documento.", 500);
    }

    public async Task<DocumentoDto> ActualizarAsync(
        Guid usuarioId, Guid id, DocumentoRequest request,
        CancellationToken cancellationToken = default)
    {
        var item = await _dbContext.Documentos
            .Include(x => x.Vehiculo)
            .FirstOrDefaultAsync(
                x => x.Id == id && x.Vehiculo.UsuarioId == usuarioId && x.Vehiculo.Activo,
                cancellationToken);

        if (item is null)
            throw new AppException("Documento no encontrado.", 404);

        await ValidarTipoAsync(request.TipoDocumentoId, cancellationToken);
        ValidarFechas(request);

        item.TipoDocumentoId = request.TipoDocumentoId;
        item.NumeroReferencia = Normalizar(request.NumeroReferencia);
        item.EntidadEmisora = Normalizar(request.EntidadEmisora);
        item.FechaExpedicion = request.FechaExpedicion;
        item.FechaVencimiento = request.FechaVencimiento;
        item.RutaArchivo = Normalizar(request.RutaArchivo);
        item.Observaciones = Normalizar(request.Observaciones);
        item.FechaActualizacion = DateTime.UtcNow;

        await _dbContext.SaveChangesAsync(cancellationToken);

        return await ObtenerUnoAsync(usuarioId, id, cancellationToken)
            ?? throw new AppException("No fue posible obtener el documento.", 500);
    }

    public async Task EliminarAsync(
        Guid usuarioId, Guid id, CancellationToken cancellationToken = default)
    {
        var item = await _dbContext.Documentos
            .Include(x => x.Vehiculo)
            .FirstOrDefaultAsync(
                x => x.Id == id && x.Vehiculo.UsuarioId == usuarioId && x.Vehiculo.Activo,
                cancellationToken);

        if (item is null)
            throw new AppException("Documento no encontrado.", 404);

        _dbContext.Documentos.Remove(item);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private IQueryable<Documento> Query(Guid usuarioId) =>
        _dbContext.Documentos
            .AsNoTracking()
            .Where(x => x.Vehiculo.UsuarioId == usuarioId && x.Vehiculo.Activo);

    private async Task<DocumentoDto?> ObtenerUnoAsync(
        Guid usuarioId, Guid id, CancellationToken cancellationToken)
    {
        return await Query(usuarioId)
            .Where(x => x.Id == id)
            .Select(x => new DocumentoDto
            {
                Id = x.Id,
                VehiculoId = x.VehiculoId,
                TipoDocumentoId = x.TipoDocumentoId,
                TipoDocumento = x.TipoDocumento.Nombre,
                NumeroReferencia = x.NumeroReferencia,
                EntidadEmisora = x.EntidadEmisora,
                FechaExpedicion = x.FechaExpedicion,
                FechaVencimiento = x.FechaVencimiento,
                RutaArchivo = x.RutaArchivo,
                Observaciones = x.Observaciones,
                FechaCreacion = x.FechaCreacion,
                FechaActualizacion = x.FechaActualizacion
            })
            .FirstOrDefaultAsync(cancellationToken);
    }

    private async Task ValidarVehiculoAsync(
        Guid usuarioId, Guid vehiculoId, CancellationToken cancellationToken)
    {
        var existe = await _dbContext.Vehiculos.AnyAsync(
            x => x.Id == vehiculoId && x.UsuarioId == usuarioId && x.Activo,
            cancellationToken);

        if (!existe)
            throw new AppException("Vehiculo no encontrado.", 404);
    }

    private async Task ValidarTipoAsync(Guid id, CancellationToken cancellationToken)
    {
        var existe = await _dbContext.TiposDocumento.AnyAsync(
            x => x.Id == id && x.Activo, cancellationToken);

        if (!existe)
            throw new AppException("Tipo de documento no valido.", 400);
    }

    private static void ValidarFechas(DocumentoRequest request)
    {
        if (request.FechaExpedicion.HasValue &&
            request.FechaVencimiento.HasValue &&
            request.FechaVencimiento.Value < request.FechaExpedicion.Value)
        {
            throw new AppException(
                "La fecha de vencimiento no puede ser anterior a la fecha de expedicion.", 400);
        }
    }

    private static string? Normalizar(string? value) =>
        string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}