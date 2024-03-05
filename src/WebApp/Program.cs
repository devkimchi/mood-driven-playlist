using MoodDrivenPlaylist.WebApp.Clients;
using MoodDrivenPlaylist.WebApp.Components;
using MoodDrivenPlaylist.WebApp.Configs;
using MoodDrivenPlaylist.WebApp.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddHttpContextAccessor();

builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

var config = builder.Configuration;
builder.Services.AddAppSettings(config);

builder.Services.AddHttpClient<IApiAppClient, ApiAppClient>((services, http) =>
{
#if DEBUG
    var auth = services.GetService<AuthSettings>();
    http.BaseAddress = new Uri("https://localhost:5051/api");
    http.DefaultRequestHeaders.Add("x-api-key", auth.ApiKey);
#else
    var apim = services.GetService<ApiManagementSettings>();
    http.BaseAddress = new Uri($"{apim.BaseUrl.TrimEnd('/')}/api");
    http.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", apim.SubscriptionKey);
#endif
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();
app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
