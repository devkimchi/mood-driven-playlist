using System.Security.Cryptography;

using MoodDrivenPlaylist.ApiApp.Configs;
using MoodDrivenPlaylist.ApiApp.Models;

using SpotifyAPI.Web;

namespace MoodDrivenPlaylist.ApiApp.Services;

public interface ISpotifyService
{
    Task<List<FullTrack>> SearchTracksAsync(string query);

    Task<PrivateUser> GetMyProfileAsync();

    Task<FullPlaylist> CreatePlaylist(string userId, string name, string? description = null);

    Task<SnapshotResponse> AddTracksToPlaylist(string playlistId, List<string> trackUris);

    Task<EmbeddedPlayerDetails> GetEmbeddedPlayer(string query);
}

public class SpotifyService(SpotifySettings settings, HttpClient http) : ISpotifyService
{
    private readonly SpotifySettings _settings = settings ?? throw new ArgumentNullException(nameof(settings));
    private readonly HttpClient _http = http ?? throw new ArgumentNullException(nameof(http));
    private ISpotifyClient _spotify;

    public async Task<List<FullTrack>> SearchTracksAsync(string query)
    {
        if (this._spotify == null) await this.SetSpotifyClientAsync();

        var request = new SearchRequest(SearchRequest.Types.Track, $"kpop {query}") { Market = this._settings.Market };
        var response = await this._spotify.Search.Item(request).ConfigureAwait(false);

        var tracks = new List<FullTrack>();
        for (var i = 0; i < this._settings.MaxItems; i++)
        {
            var j = RandomNumberGenerator.GetInt32(0, response.Tracks.Items.Count);
            var track = response.Tracks.Items[j];
            tracks.Add(track);
        }

        return tracks;
    }

    public async Task<PrivateUser> GetMyProfileAsync()
    {
        if (this._spotify == null) await this.SetSpotifyClientAsync();

        var profile = await this._spotify.UserProfile.Current().ConfigureAwait(false);

        return profile;
    }

    public async Task<FullPlaylist> CreatePlaylist(string userId, string name, string? description = null)
    {
        if (this._spotify == null) await this.SetSpotifyClientAsync();

        var request = new PlaylistCreateRequest(name) { Description = description, Public = false, Collaborative = false };
        var playlist = await this._spotify.Playlists.Create(userId, request).ConfigureAwait(false);

        return playlist;
    }

    public async Task<SnapshotResponse> AddTracksToPlaylist(string playlistId, List<string> trackUris)
    {
        if (this._spotify == null) await this.SetSpotifyClientAsync();

        var request = new PlaylistAddItemsRequest(trackUris);
        var snapshot = await this._spotify.Playlists.AddItems(playlistId, request).ConfigureAwait(false);

        return snapshot;
    }

    public async Task<EmbeddedPlayerDetails> GetEmbeddedPlayer(string query)
    {
        var tracks = await this.SearchTracksAsync(query).ConfigureAwait(false);
        var profile = await this.GetMyProfileAsync().ConfigureAwait(false);

        var title = $"Playlist by AOAI Mood Picker - {DateTimeOffset.UtcNow.ToLocalTime():yyyyMMddHHmmss}";
        var description = "A playlist based on your mood";
        var playlist = await this.CreatePlaylist(profile.Id, title, description).ConfigureAwait(false);

        var trackUris = tracks.Select(track => track.Uri).ToList();
        var snapshot = await this.AddTracksToPlaylist(playlist.Id, trackUris).ConfigureAwait(false);

        var player = new EmbeddedPlayerDetails(playlist.Id) { Title = title };

        return player;
    }

    private async Task SetSpotifyClientAsync()
    {
        var accessToken = await _http.GetStringAsync("spotify/access-token").ConfigureAwait(false);
        var spotify = new SpotifyClient(accessToken);

        this._spotify = spotify;
    }
}
