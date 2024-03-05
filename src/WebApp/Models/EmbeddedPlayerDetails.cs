namespace MoodDrivenPlaylist.WebApp.Models;

public class EmbeddedPlayerDetails
{
    public string? Title { get; set; }

    public string? PlaylistId { get; set; }

    public string? Src
    {
        get
        {
            return this.PlaylistId == null
                ? string.Empty
                : $"https://open.spotify.com/embed/playlist/{this.PlaylistId}?utm_source=MoodPickerByAzureOpenAI&theme=0";
        }
    }

    public string Style
    {
        get
        {
            return this.PlaylistId == null
                ? "display: hidden;"
                : "min-height: 360px;";
        }
    }
}
