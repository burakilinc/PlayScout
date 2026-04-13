namespace PlayScout.Api.Endpoints;

using System.Security.Claims;
using FluentValidation;
using PlayScout.Application.Abstractions;
using PlayScout.Application.Auth;
using PlayScout.Application.Contracts;

public static class SuggestionsEndpoints
{
    private static Dictionary<string, string[]> ToErrorDictionary(FluentValidation.Results.ValidationResult vr) =>
        vr.Errors
            .GroupBy(e => e.PropertyName)
            .ToDictionary(g => g.Key, g => g.Select(e => e.ErrorMessage).ToArray());

    private static Guid? TryGetUserId(ClaimsPrincipal user)
    {
        var sub = user.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? user.FindFirstValue(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.Sub);
        return Guid.TryParse(sub, out var id) ? id : null;
    }

    public static void MapSuggestionsEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/suggestions")
            .RequireAuthorization(AuthPolicies.FullMember)
            .WithTags("Suggestions");

        group.MapPost(
            "/",
            async Task<IResult> (
                CreateSuggestionRequest body,
                IValidator<CreateSuggestionRequest> validator,
                ISuggestionsService suggestions,
                ClaimsPrincipal user,
                CancellationToken ct) =>
            {
                var vr = await validator.ValidateAsync(body, ct);
                if (!vr.IsValid)
                    return Results.ValidationProblem(ToErrorDictionary(vr));

                var userId = TryGetUserId(user);
                if (userId is null)
                    return Results.Unauthorized();

                var (ok, response, error) = await suggestions.CreateAsync(userId.Value, body, ct);
                if (!ok)
                {
                    return error switch
                    {
                        "user_not_found" => Results.NotFound(),
                        _ => Results.Problem(statusCode: StatusCodes.Status500InternalServerError),
                    };
                }

                return Results.Created($"/suggestions/{response!.SuggestionId}", response);
            });
    }
}
