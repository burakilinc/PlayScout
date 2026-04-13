namespace PlayScout.Infrastructure;

using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using PlayScout.Application.Abstractions;
using PlayScout.Domain.Users;
using PlayScout.Infrastructure.Auth;
using PlayScout.Infrastructure.Persistence;
using PlayScout.Infrastructure.Services;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("PlayScout")
            ?? throw new InvalidOperationException("Connection string 'PlayScout' is not configured.");

        services.AddDbContext<PlayScoutDbContext>(options =>
            options.UseSqlServer(connectionString));

        services.AddScoped<IVenueReadService, VenueReadService>();
        services.AddScoped<IEventReadService, EventReadService>();
        services.AddScoped<IRecommendationReadService, RecommendationReadService>();

        services.AddScoped<IPasswordHasher<User>, PasswordHasher<User>>();
        services.AddSingleton<IAccessTokenFactory, JwtAccessTokenFactory>();
        services.AddScoped<IGoogleIdTokenValidator, GoogleIdTokenValidator>();
        services.AddScoped<IAppleIdentityTokenValidator, AppleIdentityTokenValidatorStub>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IFavoritesService, FavoritesService>();

        services.AddSingleton<ITranslationProvider, StubTranslationProvider>();
        services.AddScoped<IReviewTranslationService, ReviewTranslationService>();
        services.AddScoped<IReviewsService, ReviewsService>();
        services.AddScoped<ISuggestionsService, SuggestionsService>();

        return services;
    }
}
