namespace MoodDrivenPlaylist.ApiApp.Configs;

public class OpenAISettings
{
    public const string Name = "OpenAI";

    public Random Random { get; } = new();

    public float? Temperature { get; set; }

    public int? MaxTokens { get; set; }

    public Dictionary<string, string>? Messages { get; set; }

    public List<OpenAIInstanceSettings>? Instances { get; set; }
}

public class OpenAIInstanceSettings
{
    public string? Endpoint { get; set; }
    public string? ApiKey { get; set; }
    public List<string>? DeploymentNames { get; set; }
}