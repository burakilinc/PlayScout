namespace PlayScout.Application.Validators;

using FluentValidation;
using PlayScout.Application.Contracts;

public sealed class AddFavoriteRequestValidator : AbstractValidator<AddFavoriteRequest>
{
    public AddFavoriteRequestValidator()
    {
        RuleFor(x => x.VenueId).NotEmpty();
    }
}
