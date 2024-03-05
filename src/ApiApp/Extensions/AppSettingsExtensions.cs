using MoodDrivenPlaylist.ApiApp.Configs;

namespace MoodDrivenPlaylist.ApiApp.Extensions;

public static partial class IServiceCollectionExtensions
{
    public static IServiceCollection AddAppSettings(this IServiceCollection services, IConfiguration config)
    {
        services.AddSingleton<AuthSettings>(_ =>
        {
            var settings = config.GetSection(AuthSettings.Name).Get<AuthSettings>();

            return settings;
        });

        services.AddSingleton<ApiManagementSettings>(_ =>
        {
            var settings = config.GetSection(AzureSettings.Name).GetSection(ApiManagementSettings.Name).Get<ApiManagementSettings>();

            return settings;
        });

        services.AddSingleton<OpenAISettings>(_ =>
        {
            var settings = config.GetSection(AzureSettings.Name).GetSection(OpenAISettings.Name).Get<OpenAISettings>();

            return settings;
        });

        services.AddSingleton<SpotifySettings>(_ =>
        {
            var settings = config.GetSection(SpotifySettings.Name).Get<SpotifySettings>();

            return settings;
        });

        return services;
    }
}
