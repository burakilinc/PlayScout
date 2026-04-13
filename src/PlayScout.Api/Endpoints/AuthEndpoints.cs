namespace PlayScout.Api.Endpoints;

using System.Security.Claims;
using FluentValidation;
using PlayScout.Application.Abstractions;
using PlayScout.Application.Auth;
using PlayScout.Application.Contracts;

public static class AuthEndpoints
{
    private static Dictionary<string, string[]> ToErrorDictionary(FluentValidation.Results.ValidationResult vr) =>
        vr.Errors
            .GroupBy(e => e.PropertyName)
            .ToDictionary(g => g.Key, g => g.Select(e => e.ErrorMessage).ToArray());

    public static void MapAuthEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/auth").WithTags("Auth");

        group.MapPost(
                "/register",
                async Task<IResult> (
                    RegisterRequest body,
                    IValidator<RegisterRequest> validator,
                    IAuthService auth,
                    CancellationToken ct) =>
                {
                    var vr = await validator.ValidateAsync(body, ct);
                    if (!vr.IsValid)
                        return Results.ValidationProblem(ToErrorDictionary(vr));

                    var (ok, tokens, errors) = await auth.RegisterAsync(body, ct);
                    if (!ok)
                        return Results.ValidationProblem(new Dictionary<string, string[]>(errors!));

                    return Results.Ok(tokens);
                })
            .AllowAnonymous();

        group.MapPost(
                "/login",
                async Task<IResult> (
                    LoginRequest body,
                    IValidator<LoginRequest> validator,
                    IAuthService auth,
                    CancellationToken ct) =>
                {
                    var vr = await validator.ValidateAsync(body, ct);
                    if (!vr.IsValid)
                        return Results.ValidationProblem(ToErrorDictionary(vr));

                    var (ok, tokens, error) = await auth.LoginAsync(body, ct);
                    if (!ok)
                        return Results.Unauthorized();

                    return Results.Ok(tokens);
                })
            .AllowAnonymous();

        group.MapPost(
                "/refresh",
                async Task<IResult> (
                    RefreshRequest body,
                    IValidator<RefreshRequest> validator,
                    IAuthService auth,
                    CancellationToken ct) =>
                {
                    var vr = await validator.ValidateAsync(body, ct);
                    if (!vr.IsValid)
                        return Results.ValidationProblem(ToErrorDictionary(vr));

                    var (ok, tokens, error) = await auth.RefreshAsync(body, ct);
                    if (!ok)
                        return Results.Unauthorized();

                    return Results.Ok(tokens);
                })
            .AllowAnonymous();

        group.MapPost(
                "/guest",
                async Task<IResult> (IAuthService auth, CancellationToken ct) =>
                {
                    var tokens = await auth.CreateGuestSessionAsync(ct);
                    return Results.Ok(tokens);
                })
            .AllowAnonymous();

        group.MapPost(
                "/google",
                async Task<IResult> (
                    GoogleLoginRequest body,
                    IValidator<GoogleLoginRequest> validator,
                    IAuthService auth,
                    CancellationToken ct) =>
                {
                    var vr = await validator.ValidateAsync(body, ct);
                    if (!vr.IsValid)
                        return Results.ValidationProblem(ToErrorDictionary(vr));

                    var (ok, tokens, error) = await auth.LoginWithGoogleAsync(body, ct);
                    if (!ok)
                    {
                        return error switch
                        {
                            "google_oauth_not_configured" => Results.Problem(
                                statusCode: StatusCodes.Status503ServiceUnavailable,
                                title: "Google Sign-In not configured",
                                detail: "Set Google:ClientId to enable this endpoint."),
                            "email_linked_to_different_google_account" => Results.Conflict(),
                            _ => Results.Unauthorized(),
                        };
                    }

                    return Results.Ok(tokens);
                })
            .AllowAnonymous();

        group.MapPost(
                "/apple",
                async Task<IResult> (
                    AppleLoginRequest body,
                    IValidator<AppleLoginRequest> validator,
                    IAuthService auth,
                    CancellationToken ct) =>
                {
                    var vr = await validator.ValidateAsync(body, ct);
                    if (!vr.IsValid)
                        return Results.ValidationProblem(ToErrorDictionary(vr));

                    var (ok, tokens, error) = await auth.LoginWithAppleAsync(body, ct);
                    if (!ok)
                    {
                        return error switch
                        {
                            "APPLE_SIGN_IN_NOT_CONFIGURED" => Results.Problem(
                                statusCode: StatusCodes.Status501NotImplemented,
                                title: "Apple Sign In not configured",
                                detail: "Apple identity token validation is not implemented yet."),
                            _ => Results.Problem(
                                statusCode: StatusCodes.Status401Unauthorized,
                                title: "Apple Sign In failed",
                                detail: error),
                        };
                    }

                    return Results.Ok(tokens);
                })
            .AllowAnonymous();

        group.MapGet(
                "/member-check",
                () => Results.Ok(new { fullMember = true }))
            .RequireAuthorization(AuthPolicies.FullMember);

        group.MapGet(
                "/me",
                (ClaimsPrincipal user) =>
                {
                    var sub = user.FindFirstValue(ClaimTypes.NameIdentifier)
                        ?? user.FindFirstValue(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.Sub);
                    var email = user.FindFirstValue(ClaimTypes.Email);
                    var guest = user.FindFirstValue(AuthClaimTypes.IsGuest);
                    if (string.IsNullOrEmpty(sub) || !Guid.TryParse(sub, out var id))
                        return Results.Unauthorized();

                    return Results.Ok(new
                    {
                        userId = id,
                        email,
                        isGuest = string.Equals(guest, "true", StringComparison.OrdinalIgnoreCase),
                    });
                })
            .RequireAuthorization();
    }
}
