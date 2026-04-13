namespace PlayScout.Infrastructure.Persistence.Configurations;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PlayScout.Domain.Venues;

public sealed class VenueImageConfiguration : IEntityTypeConfiguration<VenueImage>
{
    public void Configure(EntityTypeBuilder<VenueImage> builder)
    {
        builder.ToTable("venue_images");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.VenueId).IsRequired();
        builder.Property(x => x.Url).HasMaxLength(2000).IsRequired();
        builder.Property(x => x.SortOrder).IsRequired();
        builder.Property(x => x.AltText).HasMaxLength(500);

        builder.HasIndex(x => new { x.VenueId, x.SortOrder })
            .HasDatabaseName("IX_venue_images_venue_sort");

        builder.HasOne<Venue>()
            .WithMany("venueImages")
            .HasForeignKey(x => x.VenueId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
