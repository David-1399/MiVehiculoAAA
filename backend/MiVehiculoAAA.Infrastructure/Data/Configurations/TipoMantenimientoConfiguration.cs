using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiVehiculoAAA.Domain.Entities;

namespace MiVehiculoAAA.Infrastructure.Data.Configurations;

public class TipoMantenimientoConfiguration
    : IEntityTypeConfiguration<TipoMantenimiento>
{
    public void Configure(
        EntityTypeBuilder<TipoMantenimiento> builder
    )
    {
        builder.ToTable("tipos_mantenimiento");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(x => x.Nombre)
            .HasColumnName("nombre")
            .HasMaxLength(80)
            .IsRequired();

        builder.Property(x => x.Categoria)
            .HasColumnName("categoria")
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(x => x.Descripcion)
            .HasColumnName("descripcion")
            .HasMaxLength(200);

        builder.Property(x => x.Activo)
            .HasColumnName("activo")
            .HasDefaultValue(true);

        builder.HasIndex(x => x.Nombre)
            .IsUnique();
    }
}