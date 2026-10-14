using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiVehiculoAAA.Domain.Entities;

namespace MiVehiculoAAA.Infrastructure.Data.Configurations;

public class MantenimientoConfiguration
    : IEntityTypeConfiguration<Mantenimiento>
{
    public void Configure(EntityTypeBuilder<Mantenimiento> builder)
    {
        builder.ToTable("mantenimientos");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(x => x.VehiculoId)
            .HasColumnName("vehiculo_id");

        builder.Property(x => x.TipoMantenimientoId)
            .HasColumnName("tipo_mantenimiento_id");

        builder.Property(x => x.Descripcion)
            .HasColumnName("descripcion")
            .HasMaxLength(250);

        builder.Property(x => x.Fecha)
            .HasColumnName("fecha")
            .HasColumnType("date");

        builder.Property(x => x.Kilometraje)
            .HasColumnName("kilometraje");

        builder.Property(x => x.Costo)
            .HasColumnName("costo")
            .HasPrecision(12, 2);

        builder.Property(x => x.Taller)
            .HasColumnName("taller")
            .HasMaxLength(120);

        builder.Property(x => x.ProximoKilometraje)
            .HasColumnName("proximo_kilometraje");

        builder.Property(x => x.ProximaFecha)
            .HasColumnName("proxima_fecha")
            .HasColumnType("date");

        builder.Property(x => x.Observaciones)
            .HasColumnName("observaciones");

        builder.Property(x => x.FechaCreacion)
            .HasColumnName("fecha_creacion")
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(x => x.FechaActualizacion)
            .HasColumnName("fecha_actualizacion");

        builder.HasOne(x => x.Vehiculo)
            .WithMany(x => x.Mantenimientos)
            .HasForeignKey(x => x.VehiculoId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.TipoMantenimiento)
            .WithMany(x => x.Mantenimientos)
            .HasForeignKey(x => x.TipoMantenimientoId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}