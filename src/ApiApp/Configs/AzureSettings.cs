namespace MoodDrivenPlaylist.ApiApp.Configs;

public class AzureSettings
{
    public const string Name = "Azure";

    public ApiManagementSettings? ApiManagement { get; set; }

    public OpenAISettings? OpenAI { get; set; }
}
