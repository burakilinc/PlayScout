namespace PlayScout.Infrastructure.Persistence.Configurations;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PlayScout.Domain.Venues;

public sealed class VenueConfiguration : IEntityTypeConfiguration<Venue>
{
    public void Configure(EntityTypeBuilder<Venue> builder)
    {
        builder.ToTable("venues");

        builder.Ignore(x => x.Features);
        builder.Ignore(x => x.Images);

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Name).HasMaxLength(200).IsRequired();
        builder.Property(x => x.Description).HasMaxLength(4000);
        builder.Property(x => x.Latitude).IsRequired();
        builder.Property(x => x.Longitude).IsRequired();
        builder.Property(x => x.HasPlaySupervisor).IsRequired();
        builder.Property(x => x.AllowsChildDropOff).IsRequired();
        builder.Property(x => x.AverageRating);
        builder.Property(x => x.ReviewCount).IsRequired();

        builder.HasIndex(x => new { x.Latitude, x.Longitude })
            .HasDatabaseName("IX_venues_lat_lon");

        builder.HasIndex(x => x.HasPlaySupervisor)
            .HasDatabaseName("IX_venues_play_supervisor");

        builder.HasIndex(x => x.AllowsChildDropOff)
            .HasDatabaseName("IX_venues_child_dropoff");

        builder.HasIndex(x => new { x.AverageRating, x.ReviewCount })
            .HasDatabaseName("IX_venues_rating");

    }
}
