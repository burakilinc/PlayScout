#!/usr/bin/env python3
"""Merge tool/l10n_extra.json into lib/l10n/app_en.arb and fill/update locale ARBs.

Preserves existing translations in each app_<code>.arb when the key is already present.
Uses Google Translate via deep_translator for missing keys (cached per English source string).
"""

from __future__ import annotations

import json
import re
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
L10N_DIR = ROOT / "lib" / "l10n"
EXTRA_PATH = ROOT / "tool" / "l10n_extra.json"

# @metadata for ICU placeholders (must stay in sync with app_en values).
PLACEHOLDER_METAS: dict[str, dict] = {
    "reviewTranslatedFrom": {"placeholders": {"language": {"type": "String"}}},
    "mapKmAway": {"placeholders": {"distance": {"type": "String"}}},
    "writeReviewWrittenInAppLang": {"placeholders": {"code": {"type": "String"}}},
    "formatDistanceMeters": {"placeholders": {"meters": {"type": "String"}}},
    "formatDistanceKm": {"placeholders": {"km": {"type": "String"}}},
    "ageYearsSingle": {"placeholders": {"years": {"type": "String"}}},
    "ageYearsRange": {"placeholders": {"low": {"type": "String"}, "high": {"type": "String"}}},
    "ratingWithCount": {"placeholders": {"rating": {"type": "String"}, "count": {"type": "String"}}},
    "notVisibleUntilReview": {"placeholders": {"name": {"type": "String"}}},
    "eventTodayTime": {"placeholders": {"time": {"type": "String"}}},
    "eventAgesRangeLabel": {"placeholders": {"low": {"type": "String"}, "high": {"type": "String"}}},
    "eventAgesMinPlusLabel": {"placeholders": {"years": {"type": "String"}}},
    "eventAgesUpToOnly": {"placeholders": {"years": {"type": "String"}}},
    "venueMilesAway": {"placeholders": {"miles": {"type": "String"}}},
    "venueAgeChipRange": {"placeholders": {"low": {"type": "String"}, "high": {"type": "String"}}},
    "ageMonthsShort": {"placeholders": {"months": {"type": "String"}}},
    "ageYearsPlusShort": {"placeholders": {"years": {"type": "String"}}},
    "ageUpToWithLabel": {"placeholders": {"label": {"type": "String"}}},
}

# (google_translate_target, arb_filename_suffix / @@locale)
LANGS: list[tuple[str, str, str]] = [
    ("tr", "tr", "tr"),
    ("ja", "ja", "ja"),
    ("zh-CN", "zh", "zh"),
    ("de", "de", "de"),
    ("fr", "fr", "fr"),
    ("ko", "ko", "ko"),
    ("pt", "pt", "pt"),
    ("es", "es", "es"),
    ("ru", "ru", "ru"),
    ("ar", "ar", "ar"),
    ("hi", "hi", "hi"),
    ("it", "it", "it"),
]


def _protect_braces(s: str) -> tuple[str, list[str]]:
    found: list[str] = []

    def repl(m: re.Match[str]) -> str:
        found.append(m.group(0))
        return f"⟦{len(found) - 1}⟧"

    return re.sub(r"\{[^}]+\}", repl, s), found


def _restore_braces(s: str, parts: list[str]) -> str:
    for i, p in enumerate(parts):
        s = s.replace(f"⟦{i}⟧", p)
    return s


def main() -> int:
    try:
        from deep_translator import GoogleTranslator
    except ImportError:
        print("Install: pip install deep-translator", file=sys.stderr)
        return 1

    extra = json.loads(EXTRA_PATH.read_text(encoding="utf-8"))
    en_path = L10N_DIR / "app_en.arb"
    en: dict = json.loads(en_path.read_text(encoding="utf-8"))
    en.update(extra)
    for k, meta in PLACEHOLDER_METAS.items():
        en[f"@{k}"] = meta
    en_path.write_text(json.dumps(en, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Merged extra into {en_path.relative_to(ROOT)}")

    keys = sorted(k for k in en if not str(k).startswith("@") and k != "@@locale")

    for google_target, file_code, locale_tag in LANGS:
        out_path = L10N_DIR / f"app_{file_code}.arb"
        old: dict = {}
        if out_path.exists():
            old = json.loads(out_path.read_text(encoding="utf-8"))

        translator = GoogleTranslator(source="en", target=google_target)
        cache: dict[str, str] = {}

        def translate_value(english: str) -> str:
            if english in cache:
                return cache[english]
            prot, parts = _protect_braces(english)
            last_err: Exception | None = None
            for attempt in range(4):
                try:
                    out = translator.translate(prot)
                    cache[english] = _restore_braces(out, parts)
                    time.sleep(0.08)
                    return cache[english]
                except Exception as e:  # noqa: BLE001
                    last_err = e
                    time.sleep(0.6 * (attempt + 1))
            print(f"WARN translate failed ({google_target}): {english[:60]!r} -> {last_err}", file=sys.stderr)
            cache[english] = english
            return english

        out: dict[str, object] = {"@@locale": locale_tag}
        for k in keys:
            src = en[k]
            if not isinstance(src, str):
                continue
            if k in old and isinstance(old[k], str) and old[k].strip():
                out[k] = old[k]
            else:
                out[k] = translate_value(src)

        out_path.write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"Wrote {out_path.name} ({len(keys)} keys)")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
