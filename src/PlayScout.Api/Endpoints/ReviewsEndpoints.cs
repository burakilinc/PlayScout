namespace PlayScout.Api.Endpoints;

using System.Security.Claims;
using FluentValidation;
using PlayScout.Application.Abstractions;
using PlayScout.Application.Auth;
using PlayScout.Application.Contracts;
using PlayScout.Application.Localization;

public static class ReviewsEndpoints
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

    public static void MapReviewsEndpoints(this WebApplication app)
    {
        var read = app.MapGroup("/reviews").WithTags("Reviews");

        read.MapGet(
            "/",
            async Task<IResult> (
                [AsParameters] ReviewsListQuery query,
                IReviewsService reviews,
                CancellationToken ct) =>
            {
                var langRaw = string.IsNullOrWhiteSpace(query.Language) ? "en" : query.Language;
                if (!LanguageCodes.TryNormalize(langRaw, out var langNorm) || !LanguageCodes.IsSupported(langNorm))
                    return Results.BadRequest(new { error = "unsupported_language" });

                var (ok, response, error) = await reviews.ListForVenueAsync(query.VenueId, langNorm, ct);
                if (!ok)
                {
                    return error switch
                    {
                        "venue_not_found" => Results.NotFound(),
                        _ => Results.Problem(statusCode: StatusCodes.Status500InternalServerError),
                    };
                }

                return Results.Ok(response);
            })
            .AllowAnonymous();

        var write = app.MapGroup("/reviews")
            .RequireAuthorization(AuthPolicies.FullMember)
            .WithTags("Reviews");

        write.MapPost(
            "/",
            async Task<IResult> (
                CreateReviewRequest body,
                IValidator<CreateReviewRequest> validator,
                IReviewsService reviews,
                ClaimsPrincipal user,
                CancellationToken ct) =>
            {
                var vr = await validator.ValidateAsync(body, ct);
                if (!vr.IsValid)
                    return Results.ValidationProblem(ToErrorDictionary(vr));

                var userId = TryGetUserId(user);
                if (userId is null)
                    return Results.Unauthorized();

                var (ok, response, error) = await reviews.CreateAsync(userId.Value, body, ct);
                if (!ok)
                {
                    return error switch
                    {
                        "venue_not_found" => Results.NotFound(),
                        "review_already_exists" => Results.Conflict(new { error = "review_already_exists" }),
                        "unsupported_language" => Results.BadRequest(new { error = "unsupported_language" }),
                        _ => Results.Problem(statusCode: StatusCodes.Status500InternalServerError),
                    };
                }

                var location = $"/reviews?venueId={body.VenueId}";
                return Results.Created(location, response);
            });
    }
}
