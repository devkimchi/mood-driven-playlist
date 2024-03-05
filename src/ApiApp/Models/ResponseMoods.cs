using Swashbuckle.AspNetCore.Filters;

namespace MoodDrivenPlaylist.ApiApp.Models;

public class ResponseMoods(string? summary = null)
{
    public string? Summary { get; set; } = summary;
}

public class ResponseMoodsExample : IExamplesProvider<ResponseMoods>
{
    public ResponseMoods GetExamples()
    {
        var example = new ResponseMoods(summary: "mood1, mood2, mood3, mood4, mood5");

        return example;
    }
}