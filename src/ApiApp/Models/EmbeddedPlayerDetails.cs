namespace MoodDrivenPlaylist.ApiApp.Models;

public class EmbeddedPlayerDetails(string? playlistId = null)
{
    private readonly string _playlistId = playlistId;

    public string? Title { get; set; }

    public string? Src
    {
        get
        {
            return $"https://open.spotify.com/embed/playlist/{this._playlistId}?utm_source=MoodPickerByAzureOpenAI&theme=0";
        }
    }

    public string? Width { get; set; } = "100%";

    public string? Height { get; set; } = "100%";

    public string? Style { get; set; } = "min-height: 360px";

    public string? FrameBorder { get; set; } = "0";

    public string? Allow { get; set; } = "autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture";

    public string? Loading { get; set; } = "lazy";
}
