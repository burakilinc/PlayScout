namespace PlayScout.Application.Validators;

using FluentValidation;
using PlayScout.Application.Contracts;
using PlayScout.Domain.Venues;

public sealed class CreateSuggestionRequestValidator : AbstractValidator<CreateSuggestionRequest>
{
    private const int MaxAgeMonthsUpper = 18 * 12;

    public CreateSuggestionRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(200)
            .Must(s => s.Trim().Length >= 2)
            .WithMessage("Name cannot be only whitespace.")
            .Must(ContainsMeaningfulCharacter)
            .WithMessage("Name must include letters or digits.");

        RuleFor(x => x.Category).IsInEnum();

        RuleFor(x => x)
            .Must(HaveLocation)
            .WithMessage("Provide both latitude and longitude, or a location label of at least 5 characters.");

        RuleFor(x => x.Latitude)
            .InclusiveBetween(-90.0, 90.0)
            .When(x => x.Latitude is not null);

        RuleFor(x => x.Longitude)
            .InclusiveBetween(-180.0, 180.0)
            .When(x => x.Longitude is not null);

        RuleFor(x => x)
            .Must(x => x.Latitude is not null == (x.Longitude is not null))
            .WithMessage("Latitude and longitude must both be set or both omitted.");

        RuleFor(x => x.LocationLabel)
            .MaximumLength(500)
            .When(x => x.LocationLabel is not null);

        RuleFor(x => x.Description)
            .MaximumLength(4000)
            .When(x => x.Description is not null);

        RuleFor(x => x.Description)
            .MinimumLength(10)
            .When(x => !string.IsNullOrWhiteSpace(x.Description))
            .WithMessage("When provided, description must be at least 10 characters.");

        RuleFor(x => x.MinAgeMonths)
            .InclusiveBetween(0, MaxAgeMonthsUpper)
            .When(x => x.MinAgeMonths is not null);

        RuleFor(x => x.MaxAgeMonths)
            .InclusiveBetween(0, MaxAgeMonthsUpper)
            .When(x => x.MaxAgeMonths is not null);

        RuleFor(x => x)
            .Must(x => !x.MinAgeMonths.HasValue || !x.MaxAgeMonths.HasValue || x.MinAgeMonths <= x.MaxAgeMonths)
            .WithMessage("min_age_months cannot be greater than max_age_months.");

        When(x => x.OptionalAmenities is { Count: > 0 }, () =>
        {
            RuleForEach(x => x.OptionalAmenities!).IsInEnum();
            RuleFor(x => x.OptionalAmenities!)
                .Must(a => a!.Distinct().Count() == a.Count)
                .WithMessage("Duplicate amenities are not allowed.");
            RuleFor(x => x).Must(AmenitiesMatchTrustFlags);
        });
    }

    private static bool AmenitiesMatchTrustFlags(CreateSuggestionRequest request)
    {
        if (request.OptionalAmenities is null)
            return true;

        foreach (var a in request.OptionalAmenities)
        {
            if (a == VenueFeatureType.PlaySupervisorAvailable && !request.HasPlaySupervisor)
                return false;

            if (a == VenueFeatureType.ChildDropOffAllowed && !request.AllowsChildDropOff)
                return false;
        }

        return true;
    }

    private static bool HaveLocation(CreateSuggestionRequest x)
    {
        var hasCoords = x.Latitude is not null && x.Longitude is not null;
        var label = x.LocationLabel?.Trim();
        var hasLabel = !string.IsNullOrEmpty(label) && label.Length >= 5;
        return hasCoords || hasLabel;
    }

    private static bool ContainsMeaningfulCharacter(string name)
    {
        foreach (var c in name.AsSpan().Trim())
        {
            if (char.IsLetterOrDigit(c))
                return true;
        }

        return false;
    }
}
