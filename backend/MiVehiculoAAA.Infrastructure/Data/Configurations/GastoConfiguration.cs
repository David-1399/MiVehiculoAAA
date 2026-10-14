using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiVehiculoAAA.Domain.Entities;

namespace MiVehiculoAAA.Infrastructure.Data.Configurations;

public class GastoConfiguration : IEntityTypeConfiguration<Gasto>
{
    public void Configure(EntityTypeBuilder<Gasto> builder)
    {
        builder.ToTable("gastos");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(x => x.VehiculoId)
            .HasColumnName("vehiculo_id");

        builder.Property(x => x.CategoriaGastoId)
            .HasColumnName("categoria_gasto_id");

        builder.Property(x => x.Descripcion)
            .HasColumnName("descripcion")
            .HasMaxLength(200);

        builder.Property(x => x.Valor)
            .HasColumnName("valor")
            .HasPrecision(12, 2);

        builder.Property(x => x.Fecha)
            .HasColumnName("fecha")
            .HasColumnType("date");

        builder.Property(x => x.RutaSoporte)
            .HasColumnName("ruta_soporte")
            .HasMaxLength(300);

        builder.Property(x => x.Observaciones)
            .HasColumnName("observaciones");

        builder.Property(x => x.FechaCreacion)
            .HasColumnName("fecha_creacion")
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.HasOne(x => x.Vehiculo)
            .WithMany(x => x.Gastos)
            .HasForeignKey(x => x.VehiculoId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.CategoriaGasto)
            .WithMany(x => x.Gastos)
            .HasForeignKey(x => x.CategoriaGastoId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}