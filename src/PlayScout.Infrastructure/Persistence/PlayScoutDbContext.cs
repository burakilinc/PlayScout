namespace PlayScout.Infrastructure.Persistence;

using Microsoft.EntityFrameworkCore;
using PlayScout.Domain.Auth;
using PlayScout.Domain.Events;
using PlayScout.Domain.Favorites;
using PlayScout.Domain.Reviews;
using PlayScout.Domain.Suggestions;
using PlayScout.Domain.Users;
using PlayScout.Domain.Venues;

public sealed class PlayScoutDbContext : DbContext
{
    public PlayScoutDbContext(DbContextOptions<PlayScoutDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();

    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    public DbSet<Venue> Venues => Set<Venue>();

    public DbSet<VenueFeature> VenueFeatures => Set<VenueFeature>();

    public DbSet<VenueImage> VenueImages => Set<VenueImage>();

    public DbSet<VenueReview> VenueReviews => Set<VenueReview>();

    public DbSet<ReviewTranslation> ReviewTranslations => Set<ReviewTranslation>();

    public DbSet<Favorite> Favorites => Set<Favorite>();

    public DbSet<Event> Events => Set<Event>();

    public DbSet<Workshop> Workshops => Set<Workshop>();

    public DbSet<SuggestedVenue> SuggestedVenues => Set<SuggestedVenue>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(PlayScoutDbContext).Assembly);
    }
}
