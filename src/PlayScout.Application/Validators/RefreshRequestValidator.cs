namespace PlayScout.Application.Validators;

using FluentValidation;
using PlayScout.Application.Contracts;

public sealed class RefreshRequestValidator : AbstractValidator<RefreshRequest>
{
    public RefreshRequestValidator()
    {
        RuleFor(x => x.RefreshToken).NotEmpty().MaximumLength(2048);
    }
}
