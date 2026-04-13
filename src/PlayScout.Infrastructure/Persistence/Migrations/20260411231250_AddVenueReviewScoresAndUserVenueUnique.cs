using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PlayScout.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddVenueReviewScoresAndUserVenueUnique : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_venue_reviews_venue_user",
                table: "venue_reviews");

            migrationBuilder.AddColumn<byte>(
                name: "CleanlinessScore",
                table: "venue_reviews",
                type: "tinyint",
                nullable: true);

            migrationBuilder.AddColumn<byte>(
                name: "SafetyScore",
                table: "venue_reviews",
                type: "tinyint",
                nullable: true);

            migrationBuilder.AddColumn<byte>(
                name: "SuitabilitySmallChildrenScore",
                table: "venue_reviews",
                type: "tinyint",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "UX_venue_reviews_user_venue",
                table: "venue_reviews",
                columns: new[] { "UserId", "VenueId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "UX_venue_reviews_user_venue",
                table: "venue_reviews");

            migrationBuilder.DropColumn(
                name: "CleanlinessScore",
                table: "venue_reviews");

            migrationBuilder.DropColumn(
                name: "SafetyScore",
                table: "venue_reviews");

            migrationBuilder.DropColumn(
                name: "SuitabilitySmallChildrenScore",
                table: "venue_reviews");

            migrationBuilder.CreateIndex(
                name: "IX_venue_reviews_venue_user",
                table: "venue_reviews",
                columns: new[] { "VenueId", "UserId" });
        }
    }
}
