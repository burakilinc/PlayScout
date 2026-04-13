namespace PlayScout.Application.Validators;

using FluentValidation;
using PlayScout.Application.Contracts;

public sealed class AppleLoginRequestValidator : AbstractValidator<AppleLoginRequest>
{
    public AppleLoginRequestValidator()
    {
        RuleFor(x => x.IdentityToken).NotEmpty().MaximumLength(16_384);
    }
}
