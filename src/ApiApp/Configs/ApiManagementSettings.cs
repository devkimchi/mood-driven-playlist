﻿namespace MoodDrivenPlaylist.ApiApp.Configs;

public class ApiManagementSettings
{
    public const string Name = "ApiManagement";

    public string? BaseUrl { get; set; }
    public string? SubscriptionKey { get; set; }
    public OpenAIInstanceSettings? OpenAI { get; set; }
}
