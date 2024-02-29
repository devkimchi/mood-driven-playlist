using Microsoft.AspNetCore.Mvc;

using MoodDrivenPlaylist.ApiApp.Services;

namespace MoodDrivenPlaylist.ApiApp.Endpoints.Spotify;

public static partial class SpotifyEndpoint
{
    public static RouteHandlerBuilder CreatePlaylist(this WebApplication app)
    {
        var builder = app.MapPost("/playlists", async ([FromQuery(Name = "q")] string query, ISpotifyService spotify) =>
        {
            var player = await spotify.GetEmbeddedPlayer(query).ConfigureAwait(false);
            return player;
        })
        .WithName("CreatePlaylist")
        .WithOpenApi();

        return builder;
    }
}
