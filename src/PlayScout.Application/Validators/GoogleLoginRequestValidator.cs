namespace PlayScout.Application.Validators;

using FluentValidation;
using PlayScout.Application.Contracts;

public sealed class GoogleLoginRequestValidator : AbstractValidator<GoogleLoginRequest>
{
    public GoogleLoginRequestValidator()
    {
        RuleFor(x => x.IdToken).NotEmpty().MaximumLength(16_384);
    }
}
