namespace PlayScout.Api.Endpoints;

using System.Security.Claims;
using FluentValidation;
using PlayScout.Application.Abstractions;
using PlayScout.Application.Auth;
using PlayScout.Application.Contracts;

public static class FavoritesEndpoints
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

    public static void MapFavoritesEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/favorites")
            .RequireAuthorization(AuthPolicies.FullMember)
            .WithTags("Favorites");

        group.MapPost(
                "/",
                async Task<IResult> (
                    AddFavoriteRequest body,
                    IValidator<AddFavoriteRequest> validator,
                    IFavoritesService favorites,
                    ClaimsPrincipal user,
                    CancellationToken ct) =>
                {
                    var vr = await validator.ValidateAsync(body, ct);
                    if (!vr.IsValid)
                        return Results.ValidationProblem(ToErrorDictionary(vr));

                    var userId = TryGetUserId(user);
                    if (userId is null)
                        return Results.Unauthorized();

                    var (ok, response, error) = await favorites.AddAsync(userId.Value, body.VenueId, ct);
                    if (!ok)
                    {
                        return error switch
                        {
                            "venue_not_found" => Results.NotFound(),
                            _ => Results.Problem(statusCode: StatusCodes.Status500InternalServerError),
                        };
                    }

                    return Results.Ok(response);
                });

        group.MapDelete(
            "/{venueId:guid}",
            async Task<IResult> (
                Guid venueId,
                IFavoritesService favorites,
                ClaimsPrincipal user,
                CancellationToken ct) =>
            {
                var userId = TryGetUserId(user);
                if (userId is null)
                    return Results.Unauthorized();

                var (deleted, error) = await favorites.RemoveAsync(userId.Value, venueId, ct);
                if (!deleted)
                {
                    return error switch
                    {
                        "favorite_not_found" => Results.NotFound(),
                        _ => Results.Problem(statusCode: StatusCodes.Status500InternalServerError),
                    };
                }

                return Results.NoContent();
            });

        group.MapGet(
                "/",
                async Task<IResult> (
                    [AsParameters] FavoriteListQuery query,
                    IFavoritesService favorites,
                    ClaimsPrincipal user,
                    CancellationToken ct) =>
                {
                    var userId = TryGetUserId(user);
                    if (userId is null)
                        return Results.Unauthorized();

                    if (query.Latitude is null ^ query.Longitude is null)
                    {
                        return Results.BadRequest(
                            new { error = "latitude_and_longitude_must_be_together_for_distance" });
                    }

                    var items = await favorites.ListAsync(userId.Value, query.Latitude, query.Longitude, ct);
                    return Results.Ok(new FavoritesListResponse(items));
                });
    }
}
