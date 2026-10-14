using MiVehiculoAAA.Application.Features.Alertas;
using MiVehiculoAAA.Application.Features.ProximosMantenimientos;
using MiVehiculoAAA.Infrastructure.Alertas;
using MiVehiculoAAA.Infrastructure.ProximosMantenimientos;
using MiVehiculoAAA.Application.Features.Documentos;
using MiVehiculoAAA.Application.Features.Gastos;
using MiVehiculoAAA.Application.Features.Kilometrajes;
using MiVehiculoAAA.Application.Features.Mantenimientos;
using MiVehiculoAAA.Infrastructure.Documentos;
using MiVehiculoAAA.Infrastructure.Gastos;
using MiVehiculoAAA.Infrastructure.Kilometrajes;
using MiVehiculoAAA.Infrastructure.Mantenimientos;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using MiVehiculoAAA.Application.Common.Settings;
using MiVehiculoAAA.Application.Features.Auth;
using MiVehiculoAAA.Application.Features.Catalogos;
using MiVehiculoAAA.Application.Features.Vehiculos;
using MiVehiculoAAA.Infrastructure.Auth;
using MiVehiculoAAA.Infrastructure.Catalogos;
using MiVehiculoAAA.Infrastructure.Data;
using MiVehiculoAAA.Infrastructure.Vehiculos;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

var connectionString =
    builder.Configuration.GetConnectionString("PostgreSQL");

if (string.IsNullOrWhiteSpace(connectionString))
{
    throw new InvalidOperationException(
        "No se encontro la cadena de conexion 'PostgreSQL'."
    );
}

builder.Services.AddDbContext<MiVehiculoDbContext>(options =>
    options.UseNpgsql(connectionString)
);

builder.Services.Configure<JwtSettings>(
    builder.Configuration.GetSection(JwtSettings.SectionName)
);

var jwtSettings =
    builder.Configuration
        .GetSection(JwtSettings.SectionName)
        .Get<JwtSettings>()
    ?? throw new InvalidOperationException(
        "No se encontro la configuracion JWT."
    );

if (string.IsNullOrWhiteSpace(jwtSettings.Key) ||
    jwtSettings.Key.Length < 32)
{
    throw new InvalidOperationException(
        "La clave JWT no existe o es demasiado corta."
    );
}

builder.Services
    .AddAuthentication(
        JwtBearerDefaults.AuthenticationScheme
    )
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters =
            new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = jwtSettings.Issuer,
                ValidAudience = jwtSettings.Audience,
                IssuerSigningKey =
                    new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(
                            jwtSettings.Key
                        )
                    ),
                ClockSkew = TimeSpan.FromMinutes(1)
            };
    });

builder.Services.AddAuthorization();

builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<ICatalogoService, CatalogoService>();
builder.Services.AddScoped<IVehiculoService, VehiculoService>();
builder.Services.AddScoped<IKilometrajeService, KilometrajeService>();
builder.Services.AddScoped<IMantenimientoService, MantenimientoService>();
builder.Services.AddScoped<IDocumentoService, DocumentoService>();
builder.Services.AddScoped<IGastoService, GastoService>();
builder.Services.AddScoped<IAlertaService, AlertaService>();
builder.Services.AddScoped<IProximoMantenimientoService, ProximoMantenimientoService>();

builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc(
        "v1",
        new OpenApiInfo
        {
            Title = "MiVehiculoAAA API",
            Version = "v1"
        }
    );

    options.AddSecurityDefinition(
        "Bearer",
        new OpenApiSecurityScheme
        {
            Name = "Authorization",
            Type = SecuritySchemeType.Http,
            Scheme = "bearer",
            BearerFormat = "JWT",
            In = ParameterLocation.Header,
            Description =
                "Escribe el token JWT obtenido en /api/auth/login."
        }
    );

    options.AddSecurityRequirement(
        new OpenApiSecurityRequirement
        {
            {
                new OpenApiSecurityScheme
                {
                    Reference = new OpenApiReference
                    {
                        Type = ReferenceType.SecurityScheme,
                        Id = "Bearer"
                    }
                },
                Array.Empty<string>()
            }
        }
    );
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();