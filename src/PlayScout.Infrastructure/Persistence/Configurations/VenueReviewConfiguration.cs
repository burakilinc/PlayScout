namespace PlayScout.Infrastructure.Persistence.Configurations;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PlayScout.Domain.Reviews;
using PlayScout.Domain.Users;
using PlayScout.Domain.Venues;

public sealed class VenueReviewConfiguration : IEntityTypeConfiguration<VenueReview>
{
    public void Configure(EntityTypeBuilder<VenueReview> builder)
    {
        builder.ToTable("venue_reviews");

        builder.Ignore(x => x.Translations);

        builder.HasKey(x => x.Id);

        builder.Property(x => x.VenueId).IsRequired();
        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.RatingStars).IsRequired();
        builder.Property(x => x.OriginalText).HasMaxLength(4000).IsRequired();
        builder.Property(x => x.OriginalLanguage).HasMaxLength(16).IsRequired();
        builder.Property(x => x.CleanlinessScore).HasColumnType("tinyint");
        builder.Property(x => x.SafetyScore).HasColumnType("tinyint");
        builder.Property(x => x.SuitabilitySmallChildrenScore).HasColumnType("tinyint");

        builder.HasIndex(x => x.VenueId).HasDatabaseName("IX_venue_reviews_venue");
        builder.HasIndex(x => x.UserId).HasDatabaseName("IX_venue_reviews_user");
        builder.HasIndex(x => new { x.UserId, x.VenueId })
            .IsUnique()
            .HasDatabaseName("UX_venue_reviews_user_venue");

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
