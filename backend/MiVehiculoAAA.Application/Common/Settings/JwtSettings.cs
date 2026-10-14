namespace MiVehiculoAAA.Application.Common.Settings;

public class JwtSettings
{
    public const string SectionName = "Jwt";

    public string Key { get; set; } = string.Empty;
    public string Issuer { get; set; } = "MiVehiculoAAA.Api";
    public string Audience { get; set; } = "MiVehiculoAAA.Mobile";
    public int ExpirationMinutes { get; set; } = 480;
}