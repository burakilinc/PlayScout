namespace PlayScout.Infrastructure.Persistence;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

/// <summary>Design-time factory for <c>dotnet ef</c> (startup project: PlayScout.Api).</summary>
public sealed class PlayScoutDbContextDesignTimeFactory : IDesignTimeDbContextFactory<PlayScoutDbContext>
{
    public PlayScoutDbContext CreateDbContext(string[] args)
    {
        var options = new DbContextOptionsBuilder<PlayScoutDbContext>()
            .UseSqlServer(
                "Server=(localdb)\\mssqllocaldb;Database=PlayScoutDesign;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True")
            .Options;

        return new PlayScoutDbContext(options);
    }
}
