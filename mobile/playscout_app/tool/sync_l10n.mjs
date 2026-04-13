/**
 * Merge tool/l10n_extra.json into lib/l10n/app_en.arb, add @ ICU metadata,
 * fill app_<lang>.arb using MyMemory translate API (cached; preserves existing keys).
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const L10N = path.join(ROOT, "lib", "l10n");
const EXTRA = path.join(ROOT, "tool", "l10n_extra.json");

const PLACEHOLDER_METAS = {
  reviewTranslatedFrom: { placeholders: { language: { type: "String" } } },
  mapKmAway: { placeholders: { distance: { type: "String" } } },
  writeReviewWrittenInAppLang: { placeholders: { code: { type: "String" } } },
  formatDistanceMeters: { placeholders: { meters: { type: "String" } } },
  formatDistanceKm: { placeholders: { km: { type: "String" } } },
  ageYearsSingle: { placeholders: { years: { type: "String" } } },
  ageYearsRange: { placeholders: { low: { type: "String" }, high: { type: "String" } } },
  ratingWithCount: { placeholders: { rating: { type: "String" }, count: { type: "String" } } },
  notVisibleUntilReview: { placeholders: { name: { type: "String" } } },
  eventTodayTime: { placeholders: { time: { type: "String" } } },
  eventAgesRangeLabel: { placeholders: { low: { type: "String" }, high: { type: "String" } } },
  eventAgesMinPlusLabel: { placeholders: { years: { type: "String" } } },
  eventAgesUpToOnly: { placeholders: { years: { type: "String" } } },
  venueMilesAway: { placeholders: { miles: { type: "String" } } },
  venueAgeChipRange: { placeholders: { low: { type: "String" }, high: { type: "String" } } },
  ageMonthsShort: { placeholders: { months: { type: "String" } } },
  ageYearsPlusShort: { placeholders: { years: { type: "String" } } },
  ageUpToWithLabel: { placeholders: { label: { type: "String" } } },
};

/** MyMemory target language code */
const LANGS = [
  ["tr", "tr"],
  ["ja", "ja"],
  ["zh", "zh-CN"],
  ["de", "de"],
  ["fr", "fr"],
  ["ko", "ko"],
  ["pt", "pt"],
  ["es", "es"],
  ["ru", "ru"],
  ["ar", "ar"],
  ["hi", "hi"],
  ["it", "it"],
];

function protect(s) {
  const parts = [];
  const out = s.replace(/\{[^}]+\}/g, (m) => {
    parts.push(m);
    return `\u27e8${parts.length - 1}\u27e9`;
  });
  return { out, parts };
}

function restore(s, parts) {
  let r = s;
  for (let i = 0; i < parts.length; i++) {
    r = r.split(`\u27e8${i}\u27e9`).join(parts[i]);
  }
  return r;
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function translateMm(text, myMemoryTarget) {
  const { out, parts } = protect(text);
  const url =
    "https://api.mymemory.translated.net/get?q=" +
    encodeURIComponent(out) +
    "&langpair=en|" +
    encodeURIComponent(myMemoryTarget);
  const res = await fetch(url);
  const j = await res.json();
  const st = j.responseStatus;
  if (st !== 200) {
    throw new Error(`MyMemory ${st}: ${j.responseDetails || JSON.stringify(j)}`);
  }
  return restore(String(j.responseData.translatedText || ""), parts);
}

async function main() {
  const extra = JSON.parse(fs.readFileSync(EXTRA, "utf8"));
  const enPath = path.join(L10N, "app_en.arb");
  const en = JSON.parse(fs.readFileSync(enPath, "utf8"));
  Object.assign(en, extra);
  for (const [k, meta] of Object.entries(PLACEHOLDER_METAS)) {
    en["@" + k] = meta;
  }
  fs.writeFileSync(enPath, JSON.stringify(en, null, 2) + "\n", "utf8");
  console.log("Merged tool/l10n_extra.json -> app_en.arb");

  const keys = Object.keys(en)
    .filter((k) => !k.startsWith("@") && k !== "@@locale")
    .sort();

  for (const [fileCode, mmTarget] of LANGS) {
    const outPath = path.join(L10N, `app_${fileCode}.arb`);
    let old = {};
    if (fs.existsSync(outPath)) {
      old = JSON.parse(fs.readFileSync(outPath, "utf8"));
    }
    const cache = new Map();
    const out = { "@@locale": fileCode };

    for (const k of keys) {
      const src = en[k];
      if (typeof src !== "string") continue;

      if (old[k] && String(old[k]).trim()) {
        out[k] = old[k];
        continue;
      }

      if (!cache.has(src)) {
        let lastErr;
        for (let attempt = 0; attempt < 5; attempt++) {
          try {
            const t = await translateMm(src, mmTarget);
            cache.set(src, t);
            await sleep(200);
            break;
          } catch (e) {
            lastErr = e;
            await sleep(800 * (attempt + 1));
          }
        }
        if (!cache.has(src)) {
          console.warn(`WARN ${fileCode} fallback EN for:`, src.slice(0, 50), lastErr?.message || lastErr);
          cache.set(src, src);
        }
      }
      out[k] = cache.get(src);
    }

    fs.writeFileSync(outPath, JSON.stringify(out, null, 2) + "\n", "utf8");
    console.log("Wrote", path.basename(outPath), keys.length, "keys");
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
