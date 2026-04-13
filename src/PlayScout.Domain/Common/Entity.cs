namespace PlayScout.Domain.Common;

public abstract class Entity
{
    public Guid Id { get; protected init; }

    public DateTimeOffset CreatedAt { get; protected init; }

    public DateTimeOffset? UpdatedAt { get; protected set; }

    protected Entity()
    {
        Id = Guid.NewGuid();
        CreatedAt = DateTimeOffset.UtcNow;
    }

    protected Entity(Guid id, DateTimeOffset createdAt)
    {
        Id = id;
        CreatedAt = createdAt;
    }
}
