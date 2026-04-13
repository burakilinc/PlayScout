namespace PlayScout.Application.Localization;

/// <summary>Normalize and validate language tags used for reviews and translations.</summary>
public static class LanguageCodes
{
    /// <summary>Primary subtag only, lowercase (e.g. en-US → en).</summary>
    public static bool TryNormalize(string? input, out string normalized)
    {
        normalized = string.Empty;
        if (string.IsNullOrWhiteSpace(input))
            return false;

        var t = input.Trim();
        var sep = t.IndexOfAny(['-', '_']);
        var primary = sep < 0 ? t : t[..sep];
        if (primary.Length is < 2 or > 8)
            return false;

        foreach (var c in primary)
        {
            if (!char.IsLetter(c))
                return false;
        }

        normalized = primary.ToLowerInvariant();
        return true;
    }

    /// <summary>Languages the app accepts for review originals and UI translation requests.</summary>
    public static bool IsSupported(string normalizedPrimary) =>
        Supported.Contains(normalizedPrimary);

    private static readonly HashSet<string> Supported =
    [
        "en", "tr", "de", "fr", "es", "it", "pt", "nl", "pl", "ru", "ar", "ja", "ko", "zh",
        "hi", "sv", "da", "fi", "no", "nb", "nn", "cs", "sk", "hu", "ro", "bg", "el", "he",
        "id", "ms", "th", "vi", "uk", "sl", "hr", "sr", "lt", "lv", "et", "is", "ga", "mt",
    ];
}
