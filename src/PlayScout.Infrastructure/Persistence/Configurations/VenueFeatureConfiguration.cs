namespace PlayScout.Infrastructure.Persistence.Configurations;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PlayScout.Domain.Venues;

public sealed class VenueFeatureConfiguration : IEntityTypeConfiguration<VenueFeature>
{
    public void Configure(EntityTypeBuilder<VenueFeature> builder)
    {
        builder.ToTable("venue_features");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.VenueId).IsRequired();
        builder.Property(x => x.Type).HasConversion<int>().IsRequired();

        builder.HasIndex(x => new { x.VenueId, x.Type })
            .IsUnique()
            .HasDatabaseName("UX_venue_features_venue_type");

        builder.HasOne<Venue>()
            .WithMany("venueFeatures")
            .HasForeignKey(x => x.VenueId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
