using MoodDrivenPlaylist.ApiApp.Configs;
using MoodDrivenPlaylist.ApiApp.Services;

namespace MoodDrivenPlaylist.ApiApp.Extensions;

public static partial class IServiceCollectionExtensions
{
    public static IServiceCollection AddSpotifyService(this IServiceCollection services)
    {
        services.AddHttpClient<ISpotifyService, SpotifyService>((services, http) =>
        {
            var apim = services.GetService<ApiManagementSettings>();
            http.BaseAddress = new Uri(apim.BaseUrl.TrimEnd('/'));
            http.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", apim.SubscriptionKey);
        });

        return services;
    }
}
