using Microsoft.AspNetCore.Mvc;

using MoodDrivenPlaylist.ApiApp.Configs;
using MoodDrivenPlaylist.ApiApp.Models;
using MoodDrivenPlaylist.ApiApp.Services;

using Swashbuckle.AspNetCore.Filters;

namespace MoodDrivenPlaylist.ApiApp.Endpoints.OpenAI;

public static class OpenAIEndpoint
{
    public static RouteHandlerBuilder GetMoods(this WebApplication app)
    {
        var builder = app.MapPost("/moods",
            [SwaggerRequestExample(typeof(RequestMoods), typeof(RequestMoodsExample))]
        [SwaggerResponseExample(StatusCodes.Status200OK, typeof(ResponseMoodsExample))]
        async (
            [FromBody] RequestMoods body,
            HttpRequest req,
            AuthSettings auth,
            IOpenAIService aoai) =>
            {
                var apiKey = req.Headers["x-api-key"].ToString();
                if (apiKey.Equals(auth.ApiKey, StringComparison.InvariantCulture) == false)
                {
                    return Results.Unauthorized();
                }

                try
                {
                    var moods = await aoai.GetMoodsAsync(body.Description).ConfigureAwait(false);

                    return Results.Ok<ResponseMoods>(moods);
                }
                catch (Exception ex)
                {
                    return Results.Problem(ex.Message, statusCode: StatusCodes.Status500InternalServerError);
                }
            })
        .Produces<ResponseMoods>(statusCode: StatusCodes.Status200OK, contentType: "application/json")
        .Produces(statusCode: StatusCodes.Status401Unauthorized)
        .Produces<string>(statusCode: StatusCodes.Status500InternalServerError, contentType: "text/plain")
        .WithTags("openai")
        .WithName("GetMoods")
        .WithOpenApi(operation =>
        {
            operation.Summary = "Get moods";
            operation.Description = "Get moods from the given description";

            return operation;
        });

        return builder;
    }
}
