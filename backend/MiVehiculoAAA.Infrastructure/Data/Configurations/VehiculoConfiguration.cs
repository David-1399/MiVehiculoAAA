using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiVehiculoAAA.Domain.Entities;

namespace MiVehiculoAAA.Infrastructure.Data.Configurations;

public class VehiculoConfiguration : IEntityTypeConfiguration<Vehiculo>
{
    public void Configure(EntityTypeBuilder<Vehiculo> builder)
    {
        builder.ToTable("vehiculos");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(x => x.UsuarioId)
            .HasColumnName("usuario_id");

        builder.Property(x => x.TipoVehiculoId)
            .HasColumnName("tipo_vehiculo_id");

        builder.Property(x => x.Marca)
            .HasColumnName("marca")
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(x => x.Modelo)
            .HasColumnName("modelo")
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(x => x.Anio)
            .HasColumnName("anio");

        builder.Property(x => x.Placa)
            .HasColumnName("placa")
            .HasMaxLength(15)
            .IsRequired();

        builder.Property(x => x.Kilometraje)
            .HasColumnName("kilometraje")
            .HasDefaultValue(0);

        builder.Property(x => x.Activo)
            .HasColumnName("activo")
            .HasDefaultValue(true);

        builder.Property(x => x.FechaCreacion)
            .HasColumnName("fecha_creacion")
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(x => x.FechaActualizacion)
            .HasColumnName("fecha_actualizacion");

        builder.HasIndex(x => x.Placa)
            .IsUnique();

        builder.HasOne(x => x.Usuario)
            .WithMany(x => x.Vehiculos)
            .HasForeignKey(x => x.UsuarioId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.TipoVehiculo)
            .WithMany(x => x.Vehiculos)
            .HasForeignKey(x => x.TipoVehiculoId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}