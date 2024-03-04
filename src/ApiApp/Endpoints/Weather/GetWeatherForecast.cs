namespace MoodDrivenPlaylist.ApiApp.Endpoints.Weather;

public static partial class WeatherForecastEndpoint
{
    private static string[] summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    public static RouteHandlerBuilder GetWeatherForecast(this WebApplication app)
    {
        var builder = app.MapGet("/weatherforecast", () =>
        {
            var forecast = Enumerable.Range(1, 5).Select(index =>
                new WeatherForecast
                (
                    DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                    Random.Shared.Next(-20, 55),
                    summaries[Random.Shared.Next(summaries.Length)]
                ))
                .ToList();

            return forecast;
        })
        .Produces<List<WeatherForecast>>(statusCode: StatusCodes.Status200OK, contentType: "application/json")
        .WithTags("weather")
        .WithName("GetWeatherForecast")
        .WithOpenApi();

        return builder;
    }
}

internal record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
