namespace PlayScout.Infrastructure.Persistence.Configurations;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PlayScout.Domain.Reviews;

public sealed class ReviewTranslationConfiguration : IEntityTypeConfiguration<ReviewTranslation>
{
    public void Configure(EntityTypeBuilder<ReviewTranslation> builder)
    {
        builder.ToTable("review_translations");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.VenueReviewId).IsRequired();
        builder.Property(x => x.LanguageCode).HasMaxLength(16).IsRequired();
        builder.Property(x => x.TranslatedText).HasMaxLength(4000).IsRequired();
        builder.Property(x => x.TranslationProvider).HasMaxLength(64);
        builder.Property(x => x.CachedAt).IsRequired();

        builder.HasIndex(x => new { x.VenueReviewId, x.LanguageCode })
            .IsUnique()
            .HasDatabaseName("UX_review_translations_review_lang");

        builder.HasOne<VenueReview>()
            .WithMany("reviewTranslations")
            .HasForeignKey(x => x.VenueReviewId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
