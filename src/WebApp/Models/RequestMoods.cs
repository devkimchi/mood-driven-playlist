namespace MoodDrivenPlaylist.WebApp.Models;

public class RequestMoods(string? description = null)
{
    public string? Description { get; set; } = description;
}
