using Azure.AI.OpenAI;

using MoodDrivenPlaylist.ApiApp.Models;
using MoodDrivenPlaylist.ApiApp.Wrappers;

namespace MoodDrivenPlaylist.ApiApp.Services;

public interface IOpenAIService
{
    Task<ResponseMoods> GetMoodsAsync(string message);
}

public class OpenAIService(IOpenAIClientWrapper client) : IOpenAIService
{
    private readonly IOpenAIClientWrapper _client = client ?? throw new ArgumentNullException(nameof(client));

    public async Task<ResponseMoods> GetMoodsAsync(string message)
    {
        var options = new ChatCompletionsOptions
        {
            DeploymentName = this._client.DeploymentNames[0],
            MaxTokens = 4000,
            Temperature = 0.7f
        };

        options.Messages.Add(new ChatRequestSystemMessage(this._client.Messages["System"]));
        options.Messages.Add(new ChatRequestUserMessage(this._client.Messages["User"]));
        options.Messages.Add(new ChatRequestAssistantMessage(this._client.Messages["Assistant"]));
        options.Messages.Add(new ChatRequestUserMessage(message));

        var result = await this._client.GetChatCompletionsAsync(options).ConfigureAwait(false);
        var response = new ResponseMoods(result.Value.Choices[0].Message.Content);

        return response;
    }
}
