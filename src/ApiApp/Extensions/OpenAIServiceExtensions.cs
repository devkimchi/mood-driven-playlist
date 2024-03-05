using Azure;
using Azure.AI.OpenAI;

using MoodDrivenPlaylist.ApiApp.Configs;
using MoodDrivenPlaylist.ApiApp.Services;
using MoodDrivenPlaylist.ApiApp.Wrappers;

namespace MoodDrivenPlaylist.ApiApp.Extensions;

public static partial class IServiceCollectionExtensions
{
    public static IServiceCollection AddOpenAIService(this IServiceCollection services)
    {
        services.AddScoped<IOpenAIClientWrapper, OpenAIClientWrapper>(services =>
        {
            var openai = services.GetService<OpenAISettings>();

            // Get feature flag
            var accessor = services.GetService<IHttpContextAccessor>();
            var request = accessor.HttpContext.Request;
            var useApim = request.GetFeatureFlag("useApim");

            var wrapper = default(OpenAIClientWrapper);
            // Load balancing through APIM
            if (useApim == true)
            {
                var apim = services.GetService<ApiManagementSettings>();

                var endpoint = new Uri($"{apim.BaseUrl.TrimEnd('/')}");
                var credential = new AzureKeyCredential(apim.SubscriptionKey);
                var client = new OpenAIClient(endpoint, credential);
                wrapper = new OpenAIClientWrapper(client, apim.OpenAI.DeploymentNames, openai.Messages);
            }
            // Load balancing within the app
            else
            {
                var index = openai.Random.Next(openai.Instances.Count);
                var instance = openai.Instances[index];
                var endpoint = new Uri(instance.Endpoint);
                var credential = new AzureKeyCredential(instance.ApiKey);
                var client = new OpenAIClient(endpoint, credential);
                wrapper = new OpenAIClientWrapper(client, instance.DeploymentNames, openai.Messages);
            }

            return wrapper;
        });

        services.AddScoped<IOpenAIService, OpenAIService>();

        return services;
    }
}