using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MiVehiculoAAA.Infrastructure.Data;

namespace MiVehiculoAAA.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PruebaController : ControllerBase
{
    private readonly MiVehiculoDbContext _dbContext;

    public PruebaController(MiVehiculoDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        var puedeConectar =
            await _dbContext.Database.CanConnectAsync();

        var usuarios =
            await _dbContext.Usuarios
                .AsNoTracking()
                .CountAsync();

        var vehiculos =
            await _dbContext.Vehiculos
                .AsNoTracking()
                .CountAsync();

        var mantenimientos =
            await _dbContext.Mantenimientos
                .AsNoTracking()
                .CountAsync();

        var documentos =
            await _dbContext.Documentos
                .AsNoTracking()
                .CountAsync();

        var gastos =
            await _dbContext.Gastos
                .AsNoTracking()
                .CountAsync();

        var kilometrajes =
            await _dbContext.Kilometrajes
                .AsNoTracking()
                .CountAsync();

        var ejemplo =
            await _dbContext.Vehiculos
                .AsNoTracking()
                .Include(x => x.Usuario)
                .Include(x => x.TipoVehiculo)
                .OrderBy(x => x.FechaCreacion)
                .Select(x => new
                {
                    x.Id,
                    x.Placa,
                    x.Marca,
                    x.Modelo,
                    x.Anio,
                    x.Kilometraje,
                    Propietario =
                        x.Usuario.Nombres + " " +
                        x.Usuario.Apellidos,
                    TipoVehiculo =
                        x.TipoVehiculo.Nombre
                })
                .FirstOrDefaultAsync();

        return Ok(new
        {
            api = "MiVehiculoAAA",
            baseDatos = "mivehiculoaaa",
            conexionPostgreSql = puedeConectar,
            registros = new
            {
                usuarios,
                vehiculos,
                mantenimientos,
                documentos,
                gastos,
                kilometrajes
            },
            vehiculoEjemplo = ejemplo
        });
    }
}