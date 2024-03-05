using Azure;
using Azure.AI.OpenAI;

namespace MoodDrivenPlaylist.ApiApp.Wrappers;

public interface IOpenAIClientWrapper
{
    List<string> DeploymentNames { get; }

    Dictionary<string, string> Messages { get; }

    Task<Response<ChatCompletions>> GetChatCompletionsAsync(ChatCompletionsOptions chatCompletionsOptions, CancellationToken cancellationToken = default(CancellationToken));
}

public class OpenAIClientWrapper(OpenAIClient client, List<string> deploymentModels, Dictionary<string, string> messages) : IOpenAIClientWrapper
{
    private readonly OpenAIClient _client = client ?? throw new ArgumentNullException(nameof(client));

    public List<string> DeploymentNames { get; } = deploymentModels ?? throw new ArgumentNullException(nameof(deploymentModels));
    public Dictionary<string, string> Messages { get; } = messages ?? throw new ArgumentNullException(nameof(messages));

    public async Task<Response<ChatCompletions>> GetChatCompletionsAsync(ChatCompletionsOptions chatCompletionsOptions, CancellationToken cancellationToken = default(CancellationToken))
    {
        return await this._client.GetChatCompletionsAsync(chatCompletionsOptions, cancellationToken).ConfigureAwait(false);
    }
}
