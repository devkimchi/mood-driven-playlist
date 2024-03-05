using System.Reflection;

using Microsoft.OpenApi.Models;

using MoodDrivenPlaylist.ApiApp.Endpoints.OpenAI;
using MoodDrivenPlaylist.ApiApp.Endpoints.Spotify;
using MoodDrivenPlaylist.ApiApp.Endpoints.Weather;
using MoodDrivenPlaylist.ApiApp.Extensions;

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
builder.Services.AddAppSettings(config);
builder.Services.AddSpotifyService();
builder.Services.AddOpenAIService();

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
app.GetMoods();

app.Run();
