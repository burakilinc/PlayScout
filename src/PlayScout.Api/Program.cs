using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using PlayScout.Api.Authentication;
using PlayScout.Api.Endpoints;
using PlayScout.Application;
using PlayScout.Application.Abstractions;
using PlayScout.Application.Contracts;
using PlayScout.Infrastructure;
using PlayScout.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);

static bool ShouldRunMigrationsOnStartup(IHostEnvironment env, IConfiguration configuration) =>
    env.IsDevelopment()
    || configuration.GetValue("Database:RunMigrationsOnStartup", false);

builder.Services.AddApplication(builder.Configuration);
builder.Services.AddInfrastructure(builder.Configuration);
builder.Services.AddPlayScoutJwtAuthenticationAndAuthorization(builder.Configuration);

builder.Services.AddCors(options =>
{
    options.AddPolicy(
        "DevelopmentBrowser",
        policy =>
        {
            policy
                .SetIsOriginAllowed(static origin =>
                {
                    if (string.IsNullOrEmpty(origin))
                    {
                        return false;
                    }

                    try
                    {
                        var uri = new Uri(origin);
                        if (uri.Host is "localhost" or "127.0.0.1")
                        {
                            return uri.Scheme is "http" or "https";
                        }
                    }
                    catch (UriFormatException)
                    {
                        return false;
                    }

                    return false;
                })
                .AllowAnyHeader()
                .AllowAnyMethod();
        });
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new() { Title = "PlayScout API", Version = "v1" });
    options.AddSecurityDefinition(
        "Bearer",
        new OpenApiSecurityScheme
        {
            Description = "JWT Authorization header using the Bearer scheme.",
            Name = "Authorization",
            In = ParameterLocation.Header,
            Type = SecuritySchemeType.Http,
            Scheme = "bearer",
            BearerFormat = "JWT",
        });
    options.AddSecurityRequirement(
        new OpenApiSecurityRequirement
        {
            {
                new OpenApiSecurityScheme
                {
                    Reference = new OpenApiReference
                    {
                        Type = ReferenceType.SecurityScheme,
                        Id = "Bearer",
                    },
                },
                Array.Empty<string>()
            },
        });
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<PlayScoutDbContext>();
    var configuration = scope.ServiceProvider.GetRequiredService<IConfiguration>();
    var logger = scope.ServiceProvider.GetRequiredService<ILoggerFactory>().CreateLogger("DatabaseStartup");

    if (ShouldRunMigrationsOnStartup(app.Environment, configuration))
    {
        await db.Database.MigrateAsync();
        logger.LogInformation("Database migrations applied on startup.");
    }
    else
    {
        logger.LogInformation(
            "Skipping automatic database migrations (not Development and Database:RunMigrationsOnStartup is false).");
    }

    if (app.Environment.IsDevelopment())
        await PlayScoutDbSeeder.SeedDevelopmentDataAsync(db);
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (app.Environment.IsDevelopment())
{
    app.UseCors("DevelopmentBrowser");
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapAuthEndpoints();
app.MapFavoritesEndpoints();
app.MapReviewsEndpoints();
app.MapSuggestionsEndpoints();

app.MapGet("/health", () => Results.Ok(new { status = "ok", service = "PlayScout.Api" }))
    .WithTags("Health");

app.MapGet("/venues/nearby", async Task<IResult> (
        [AsParameters] VenueNearbyRequest request,
        IVenueReadService venues,
        CancellationToken ct) =>
    Results.Ok(await venues.GetNearbyAsync(request, ct)))
    .WithName("GetVenuesNearby")
    .WithTags("Venues");

app.MapGet("/venues/{id:guid}", async Task<IResult> (Guid id, IVenueReadService venues, CancellationToken ct) =>
    {
        var venue = await venues.GetByIdAsync(id, ct);
        return venue is null ? Results.NotFound() : Results.Ok(venue);
    })
    .WithName("GetVenueById")
    .WithTags("Venues");

app.MapGet("/events", async Task<IResult> (
        [AsParameters] EventListRequest request,
        IEventReadService events,
        CancellationToken ct) =>
    Results.Ok(await events.ListAsync(request, ct)))
    .WithName("ListEvents")
    .WithTags("Events");

app.MapGet("/events/{id:guid}", async Task<IResult> (Guid id, IEventReadService events, CancellationToken ct) =>
    {
        var detail = await events.GetByIdAsync(id, ct);
        return detail is null ? Results.NotFound() : Results.Ok(detail);
    })
    .WithName("GetEventById")
    .WithTags("Events");

app.MapGet("/recommendations", async Task<IResult> (
        [AsParameters] RecommendationRequest request,
        IRecommendationReadService recommendations,
        CancellationToken ct) =>
    Results.Ok(await recommendations.GetAsync(request, ct)))
    .WithName("GetRecommendations")
    .WithTags("Recommendations");

app.Run();
