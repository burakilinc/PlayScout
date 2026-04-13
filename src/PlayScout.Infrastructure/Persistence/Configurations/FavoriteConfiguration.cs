namespace PlayScout.Infrastructure.Persistence.Configurations;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PlayScout.Domain.Favorites;
using PlayScout.Domain.Users;
using PlayScout.Domain.Venues;

public sealed class FavoriteConfiguration : IEntityTypeConfiguration<Favorite>
{
    public void Configure(EntityTypeBuilder<Favorite> builder)
    {
        builder.ToTable("favorites");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.VenueId).IsRequired();

        builder.HasIndex(x => new { x.UserId, x.VenueId })
            .IsUnique()
            .HasDatabaseName("UX_favorites_user_venue");

        builder.HasIndex(x => x.UserId)
            .HasDatabaseName("IX_favorites_user");

        builder.HasIndex(x => x.VenueId).HasDatabaseName("IX_favorites_venue");

        builder.HasOne<User>()
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne<Venue>()
            .WithMany()
            .HasForeignKey(x => x.VenueId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
