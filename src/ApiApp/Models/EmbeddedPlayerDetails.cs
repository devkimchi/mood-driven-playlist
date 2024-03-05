using Swashbuckle.AspNetCore.Filters;

namespace MoodDrivenPlaylist.ApiApp.Models;

public class EmbeddedPlayerDetails
{
    public string? Title { get; set; }

    public string? PlaylistId { get; set; }

    public string? Src
    {
        get
        {
            return $"https://open.spotify.com/embed/playlist/{this.PlaylistId}?utm_source=MoodPickerByAzureOpenAI&theme=0";
        }
    }
}

public class EmbeddedPlayerDetailsExample : IExamplesProvider<EmbeddedPlayerDetails>
{
    public EmbeddedPlayerDetails GetExamples()
    {
        var example = new EmbeddedPlayerDetails
        {
            Title = $"Playlist by AOAI Mood Picker - {DateTimeOffset.UtcNow.ToLocalTime():yyyyMMddHHmmss}",
            PlaylistId = "55OvGbEdDvJNh3zratcxAq"
        };

        return example;
    }
}