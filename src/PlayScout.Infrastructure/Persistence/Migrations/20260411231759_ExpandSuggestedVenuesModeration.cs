using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PlayScout.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class ExpandSuggestedVenuesModeration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "AmenitiesJson",
                table: "suggested_venues",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Category",
                table: "suggested_venues",
                type: "int",
                nullable: false,
                defaultValue: 99);

            migrationBuilder.AddColumn<string>(
                name: "LocationLabel",
                table: "suggested_venues",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "MaxAgeMonths",
                table: "suggested_venues",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "MinAgeMonths",
                table: "suggested_venues",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_suggested_venues_submitter_created",
                table: "suggested_venues",
                columns: new[] { "SubmittedByUserId", "CreatedAt" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_suggested_venues_submitter_created",
                table: "suggested_venues");

            migrationBuilder.DropColumn(
                name: "AmenitiesJson",
                table: "suggested_venues");

            migrationBuilder.DropColumn(
                name: "Category",
                table: "suggested_venues");

            migrationBuilder.DropColumn(
                name: "LocationLabel",
                table: "suggested_venues");

            migrationBuilder.DropColumn(
                name: "MaxAgeMonths",
                table: "suggested_venues");

            migrationBuilder.DropColumn(
                name: "MinAgeMonths",
                table: "suggested_venues");
        }
    }
}
