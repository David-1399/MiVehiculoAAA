using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiVehiculoAAA.Domain.Entities;

namespace MiVehiculoAAA.Infrastructure.Data.Configurations;

public class AlertaConfiguration : IEntityTypeConfiguration<Alerta>
{
    public void Configure(EntityTypeBuilder<Alerta> builder)
    {
        builder.ToTable("alertas");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(x => x.UsuarioId)
            .HasColumnName("usuario_id");

        builder.Property(x => x.VehiculoId)
            .HasColumnName("vehiculo_id");

        builder.Property(x => x.Tipo)
            .HasColumnName("tipo")
            .HasMaxLength(30)
            .IsRequired();

        builder.Property(x => x.Titulo)
            .HasColumnName("titulo")
            .HasMaxLength(120)
            .IsRequired();

        builder.Property(x => x.Mensaje)
            .HasColumnName("mensaje")
            .HasMaxLength(250)
            .IsRequired();

        builder.Property(x => x.FechaAlerta)
            .HasColumnName("fecha_alerta")
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(x => x.Leida)
            .HasColumnName("leida")
            .HasDefaultValue(false);

        builder.Property(x => x.FechaLectura)
            .HasColumnName("fecha_lectura");

        builder.Property(x => x.Activa)
            .HasColumnName("activa")
            .HasDefaultValue(true);

        builder.HasOne(x => x.Usuario)
            .WithMany(x => x.Alertas)
            .HasForeignKey(x => x.UsuarioId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Vehiculo)
            .WithMany(x => x.Alertas)
            .HasForeignKey(x => x.VehiculoId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}