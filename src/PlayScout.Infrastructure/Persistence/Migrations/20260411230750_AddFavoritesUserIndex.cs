using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PlayScout.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddFavoritesUserIndex : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_favorites_user",
                table: "favorites",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_favorites_user",
                table: "favorites");
        }
    }
}
