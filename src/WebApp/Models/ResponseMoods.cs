namespace MoodDrivenPlaylist.WebApp.Models;

public class ResponseMoods(string? summary = null)
{
    public string? Summary { get; set; } = summary;
}
