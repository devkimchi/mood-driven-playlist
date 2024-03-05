using MoodDrivenPlaylist.WebApp.Configs;

namespace MoodDrivenPlaylist.WebApp.Extensions;

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

        return services;
    }
}
