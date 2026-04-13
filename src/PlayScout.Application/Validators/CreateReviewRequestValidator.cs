namespace PlayScout.Application.Validators;

using FluentValidation;
using PlayScout.Application.Contracts;
using PlayScout.Application.Localization;

public sealed class CreateReviewRequestValidator : AbstractValidator<CreateReviewRequest>
{
    public CreateReviewRequestValidator()
    {
        RuleFor(x => x.VenueId).NotEmpty();

        RuleFor(x => x.Rating).InclusiveBetween(1, 5);

        RuleFor(x => x.Comment)
            .NotEmpty()
            .MinimumLength(20)
            .MaximumLength(4000)
            .Must(HaveAtLeastThreeTokens)
            .WithMessage("Comment must contain at least three words.")
            .Must(NotSingleRepeatedCharacter)
            .WithMessage("Comment cannot be meaningless (single repeated character).");

        RuleFor(x => x.OriginalLanguage)
            .NotEmpty()
            .Must(lang => LanguageCodes.TryNormalize(lang, out var n) && LanguageCodes.IsSupported(n))
            .WithMessage("original_language must be a supported ISO-style language code.");

        RuleFor(x => x.CleanlinessScore).Must(v => !v.HasValue || (v.Value >= 1 && v.Value <= 5));
        RuleFor(x => x.SafetyScore).Must(v => !v.HasValue || (v.Value >= 1 && v.Value <= 5));
        RuleFor(x => x.SuitabilityForSmallChildrenScore)
            .Must(v => !v.HasValue || (v.Value >= 1 && v.Value <= 5));
    }

    private static bool HaveAtLeastThreeTokens(string text)
    {
        var wordCount = 0;
        var inWord = false;
        foreach (var c in text.AsSpan().Trim())
        {
            if (char.IsWhiteSpace(c))
            {
                inWord = false;
            }
            else if (!inWord)
            {
                inWord = true;
                wordCount++;
                if (wordCount >= 3)
                    return true;
            }
        }

        return wordCount >= 3;
    }

    private static bool NotSingleRepeatedCharacter(string text)
    {
        var u = text.Trim();
        if (u.Length < 2)
            return false;

        var first = u[0];
        return u.Any(c => c != first);
    }
}
