namespace PlayScout.Infrastructure.Persistence.Configurations;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PlayScout.Domain.Events;
using PlayScout.Domain.Venues;

public sealed class EventConfiguration : IEntityTypeConfiguration<Event>
{
    public void Configure(EntityTypeBuilder<Event> builder)
    {
        builder.ToTable("events");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Title).HasMaxLength(300).IsRequired();
        builder.Property(x => x.Description).HasMaxLength(8000);
        builder.Property(x => x.StartsAt).IsRequired();
        builder.Property(x => x.EndsAt).IsRequired();
        builder.Property(x => x.ExternalUrl).HasMaxLength(2000);
        builder.Property(x => x.LocationLabel).HasMaxLength(500);
        builder.Property(x => x.MinAgeMonths);
        builder.Property(x => x.MaxAgeMonths);

        builder.HasIndex(x => x.StartsAt).HasDatabaseName("IX_events_starts_at");
        builder.HasIndex(x => x.VenueId).HasDatabaseName("IX_events_venue");
        builder.HasIndex(x => new { x.StartsAt, x.EndsAt }).HasDatabaseName("IX_events_window");

        builder.HasOne<Venue>()
            .WithMany()
            .HasForeignKey(x => x.VenueId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
