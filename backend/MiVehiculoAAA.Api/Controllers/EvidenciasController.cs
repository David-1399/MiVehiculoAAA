using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MiVehiculoAAA.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/evidencias")]
public class EvidenciasController : ControllerBase
{
    private const long MaxFileSize = 8 * 1024 * 1024;

    private static readonly HashSet<string> AllowedExtensions =
        new(StringComparer.OrdinalIgnoreCase)
        {
            ".jpg",
            ".jpeg",
            ".png",
            ".webp"
        };

    private readonly IWebHostEnvironment _environment;

    public EvidenciasController(IWebHostEnvironment environment)
    {
        _environment = environment;
    }

    [HttpPost]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(MaxFileSize)]
    public async Task<IActionResult> Subir(
        IFormFile archivo,
        CancellationToken cancellationToken
    )
    {
        if (archivo is null || archivo.Length == 0)
        {
            return BadRequest(
                new { mensaje = "Selecciona una imagen para cargar." }
            );
        }

        if (archivo.Length > MaxFileSize)
        {
            return BadRequest(
                new { mensaje = "La imagen no puede superar 8 MB." }
            );
        }

        var extension =
            Path.GetExtension(archivo.FileName).ToLowerInvariant();

        if (!AllowedExtensions.Contains(extension))
        {
            return BadRequest(
                new
                {
                    mensaje =
                        "Formato no permitido. Usa JPG, JPEG, PNG o WEBP."
                }
            );
        }

        if (string.IsNullOrWhiteSpace(archivo.ContentType) ||
            !archivo.ContentType.StartsWith(
                "image/",
                StringComparison.OrdinalIgnoreCase
            ))
        {
            return BadRequest(
                new { mensaje = "El archivo debe ser una imagen." }
            );
        }

        var directory = Path.Combine(
            _environment.ContentRootPath,
            "wwwroot",
            "uploads",
            "evidencias"
        );

        Directory.CreateDirectory(directory);

        var fileName =
            $"{Guid.NewGuid():N}{extension}";

        var physicalPath =
            Path.Combine(directory, fileName);

        await using (
            var stream = new FileStream(
                physicalPath,
                FileMode.CreateNew,
                FileAccess.Write,
                FileShare.None,
                81920,
                useAsync: true
            )
        )
        {
            await archivo.CopyToAsync(
                stream,
                cancellationToken
            );
        }

        var relativePath =
            $"/uploads/evidencias/{fileName}";

        var absoluteUrl =
            $"{Request.Scheme}://{Request.Host}{relativePath}";

        return StatusCode(
            StatusCodes.Status201Created,
            new
            {
                ruta = relativePath,
                url = absoluteUrl,
                nombreArchivo = fileName,
                tamanoBytes = archivo.Length
            }
        );
    }
}