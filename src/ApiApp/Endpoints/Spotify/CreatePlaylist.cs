using Microsoft.AspNetCore.Mvc;

using MoodDrivenPlaylist.ApiApp.Configs;
using MoodDrivenPlaylist.ApiApp.Models;
using MoodDrivenPlaylist.ApiApp.Services;

using Swashbuckle.AspNetCore.Filters;

namespace MoodDrivenPlaylist.ApiApp.Endpoints.Spotify;

public static partial class SpotifyEndpoint
{
    public static RouteHandlerBuilder CreatePlaylist(this WebApplication app)
    {
        var builder = app.MapPost("/playlists",
            [SwaggerResponseExample(StatusCodes.Status200OK, typeof(EmbeddedPlayerDetailsExample))]
        async (
            [FromQuery(Name = "q")] string query,
            HttpRequest req,
            AuthSettings auth,
            ISpotifyService spotify) =>
        {
            var apiKey = req.Headers["x-api-key"].ToString();
            if (apiKey.Equals(auth.ApiKey, StringComparison.InvariantCulture) == false)
            {
                return Results.Unauthorized();
            }

            try
            {
                var player = await spotify.GetEmbeddedPlayer(query).ConfigureAwait(false);

                return Results.Ok<EmbeddedPlayerDetails>(player);
            }
            catch (Exception ex)
            {
                return Results.Problem(ex.Message, statusCode: StatusCodes.Status500InternalServerError);
            }
        })
        .Produces<EmbeddedPlayerDetails>(statusCode: StatusCodes.Status200OK, contentType: "application/json")
        .Produces(statusCode: StatusCodes.Status401Unauthorized)
        .Produces<string>(statusCode: StatusCodes.Status500InternalServerError, contentType: "text/plain")
        .WithTags("spotify")
        .WithName("CreatePlaylist")
        .WithOpenApi(operation =>
        {
            operation.Summary = "Create a playlist";
            operation.Description = "Create a playlist based on the mood";
            operation.Parameters[0].Description = "Query passing the mood";

            return operation;
        });

        return builder;
    }
}
