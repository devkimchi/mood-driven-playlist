using MoodDrivenPlaylist.ApiApp.Endpoints.Spotify;
using MoodDrivenPlaylist.ApiApp.Endpoints.Weather;
using MoodDrivenPlaylist.ApiApp.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var config = builder.Configuration;

builder.Services.AddSingleton<IConfiguration>(_ =>
{
    var spotify = config.GetSection("Spotify");

    return spotify;
});

builder.Services.AddHttpClient<ISpotifyService, SpotifyService>(http =>
{
    var apim = config.GetSection("Azure").GetSection("ApiManagement");
    http.BaseAddress = new Uri(apim["BaseUrl"]);
    http.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", apim["SubscriptionKey"]);
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.GetWeatherForecast();
app.CreatePlaylist();

app.Run();
