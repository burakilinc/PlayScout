namespace PlayScout.Infrastructure.Persistence.Configurations;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PlayScout.Domain.Suggestions;
using PlayScout.Domain.Users;

public sealed class SuggestedVenueConfiguration : IEntityTypeConfiguration<SuggestedVenue>
{
    public void Configure(EntityTypeBuilder<SuggestedVenue> builder)
    {
        builder.ToTable("suggested_venues");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Name).HasMaxLength(200).IsRequired();
        builder.Property(x => x.Category).HasConversion<int>().IsRequired();
        builder.Property(x => x.Description).HasMaxLength(4000);
        builder.Property(x => x.Latitude);
        builder.Property(x => x.Longitude);
        builder.Property(x => x.LocationLabel).HasMaxLength(500);
        builder.Property(x => x.MinAgeMonths);
        builder.Property(x => x.MaxAgeMonths);
        builder.Property(x => x.HasPlaySupervisor).IsRequired();
        builder.Property(x => x.AllowsChildDropOff).IsRequired();
        builder.Property(x => x.AmenitiesJson).HasMaxLength(2000);
        builder.Property(x => x.Status).HasConversion<int>().IsRequired();
        builder.Property(x => x.ModeratorNotes).HasMaxLength(2000);

        builder.HasIndex(x => x.Status).HasDatabaseName("IX_suggested_venues_status");
        builder.HasIndex(x => x.SubmittedByUserId).HasDatabaseName("IX_suggested_venues_submitter");
        builder.HasIndex(x => new { x.SubmittedByUserId, x.CreatedAt })
            .HasDatabaseName("IX_suggested_venues_submitter_created");

        builder.HasOne<User>()
            .WithMany()
            .HasForeignKey(x => x.SubmittedByUserId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
