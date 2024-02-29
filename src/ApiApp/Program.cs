using System.Reflection;

using Microsoft.OpenApi.Models;

using MoodDrivenPlaylist.ApiApp.Configs;
using MoodDrivenPlaylist.ApiApp.Endpoints.Spotify;
using MoodDrivenPlaylist.ApiApp.Endpoints.Weather;
using MoodDrivenPlaylist.ApiApp.Extensions;
using MoodDrivenPlaylist.ApiApp.Services;

using Swashbuckle.AspNetCore.Filters;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddHttpContextAccessor();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerExamplesFromAssemblies(Assembly.GetEntryAssembly());
builder.Services.AddSwaggerGen(options =>
{
    var info = new OpenApiInfo()
    {
        Version = "v1",
        Title = "Mood Driven Playlist API",
        Description = "An API to create a Spotify playlist based on the mood"
    };
    options.SwaggerDoc("v1", info);

    options.ExampleFilters();

    var accessor = builder.Services.BuildServiceProvider().GetService<IHttpContextAccessor>();
    var request = accessor.HttpContext.Request;
    var server = new OpenApiServer
    {
        Url = $"{request.BaseUrl().TrimEnd('/')}/api",
    };
    options.AddServer(server);

    var securityScheme = new OpenApiSecurityScheme()
    {
        Type = SecuritySchemeType.ApiKey,
        Name = "x-api-key",
        Description = "API key",
        In = ParameterLocation.Header,
    };
    options.AddSecurityDefinition("apiKey", securityScheme);

    var securityRequirementScheme = new OpenApiSecurityScheme() { Reference = new OpenApiReference() { Type = ReferenceType.SecurityScheme, Id = "apiKey" } };
    var securityRequirement = new OpenApiSecurityRequirement() { { securityRequirementScheme, new List<string>() } };
    options.AddSecurityRequirement(securityRequirement);
});

var config = builder.Configuration;

builder.Services.AddSingleton<AuthSettings>(_ =>
{
    var settings = config.GetSection(AuthSettings.Name).Get<AuthSettings>();

    return settings;
});
builder.Services.AddSingleton<AzureSettings>(_ =>
{
    var settings = config.GetSection(AzureSettings.Name).Get<AzureSettings>();

    return settings;
});
builder.Services.AddSingleton<SpotifySettings>(_ =>
{
    var settings = config.GetSection(SpotifySettings.Name).Get<SpotifySettings>();

    return settings;
});

builder.Services.AddHttpClient<ISpotifyService, SpotifyService>(http =>
{
    var apim = builder.Services.BuildServiceProvider().GetService<AzureSettings>().ApiManagement;
    http.BaseAddress = new Uri(apim.BaseUrl);
    http.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", apim.SubscriptionKey);
});

var app = builder.Build();
app.UsePathBase(new PathString("/api"));
app.UseRouting();

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
