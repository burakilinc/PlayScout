namespace PlayScout.Application.Abstractions;

public interface IAccessTokenFactory
{
    (string Token, DateTimeOffset ExpiresAtUtc) CreateAccessToken(Guid userId, string email, bool isGuest);
}
