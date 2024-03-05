using MoodDrivenPlaylist.WebApp.Models;

namespace MoodDrivenPlaylist.WebApp.Clients;

public interface IApiAppClient
{
    Task<ResponseMoods> GetMoodAsync(string message, bool useApim = false);

    Task<EmbeddedPlayerDetails> CreatePlaylistAsync(string query);
}

public class ApiAppClient(HttpClient http) : IApiAppClient
{
    private readonly HttpClient _http = http ?? throw new ArgumentNullException(nameof(http));

    public async Task<ResponseMoods> GetMoodAsync(string message, bool useApim = false)
    {
        var response = await this._http.PostAsJsonAsync<RequestMoods>($"moods?useApim={useApim}", new RequestMoods(message)).ConfigureAwait(false);
        var moods = await response.Content.ReadFromJsonAsync<ResponseMoods>();

        return moods;
    }

    public async Task<EmbeddedPlayerDetails> CreatePlaylistAsync(string query)
    {
        var response = await this._http.PostAsJsonAsync<string>($"playlists?q={query}", string.Empty).ConfigureAwait(false);
        var playlist = await response.Content.ReadFromJsonAsync<EmbeddedPlayerDetails>();

        return playlist;
    }
}
