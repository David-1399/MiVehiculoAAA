using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiVehiculoAAA.Domain.Entities;

namespace MiVehiculoAAA.Infrastructure.Data.Configurations;

public class KilometrajeConfiguration
    : IEntityTypeConfiguration<Kilometraje>
{
    public void Configure(EntityTypeBuilder<Kilometraje> builder)
    {
        builder.ToTable("kilometrajes");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(x => x.VehiculoId)
            .HasColumnName("vehiculo_id");

        builder.Property(x => x.Valor)
            .HasColumnName("kilometraje");

        builder.Property(x => x.Fecha)
            .HasColumnName("fecha")
            .HasColumnType("date");

        builder.Property(x => x.Observaciones)
            .HasColumnName("observaciones");

        builder.Property(x => x.FechaCreacion)
            .HasColumnName("fecha_creacion")
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.HasOne(x => x.Vehiculo)
            .WithMany(x => x.Kilometrajes)
            .HasForeignKey(x => x.VehiculoId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}