using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiVehiculoAAA.Domain.Entities;

namespace MiVehiculoAAA.Infrastructure.Data.Configurations;

public class DocumentoConfiguration
    : IEntityTypeConfiguration<Documento>
{
    public void Configure(EntityTypeBuilder<Documento> builder)
    {
        builder.ToTable("documentos");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(x => x.VehiculoId)
            .HasColumnName("vehiculo_id");

        builder.Property(x => x.TipoDocumentoId)
            .HasColumnName("tipo_documento_id");

        builder.Property(x => x.NumeroReferencia)
            .HasColumnName("numero_referencia")
            .HasMaxLength(80);

        builder.Property(x => x.EntidadEmisora)
            .HasColumnName("entidad_emisora")
            .HasMaxLength(120);

        builder.Property(x => x.FechaExpedicion)
            .HasColumnName("fecha_expedicion")
            .HasColumnType("date");

        builder.Property(x => x.FechaVencimiento)
            .HasColumnName("fecha_vencimiento")
            .HasColumnType("date");

        builder.Property(x => x.RutaArchivo)
            .HasColumnName("ruta_archivo")
            .HasMaxLength(300);

        builder.Property(x => x.Observaciones)
            .HasColumnName("observaciones");

        builder.Property(x => x.FechaCreacion)
            .HasColumnName("fecha_creacion")
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(x => x.FechaActualizacion)
            .HasColumnName("fecha_actualizacion");

        builder.HasOne(x => x.Vehiculo)
            .WithMany(x => x.Documentos)
            .HasForeignKey(x => x.VehiculoId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.TipoDocumento)
            .WithMany(x => x.Documentos)
            .HasForeignKey(x => x.TipoDocumentoId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}