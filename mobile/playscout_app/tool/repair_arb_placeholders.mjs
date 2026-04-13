/**
 * Re-translate ARB entries where ICU placeholder names were corrupted or lost.
 * Uses word-joiner delimited tokens (\u2060name\u2060) that survive gtx better than <ph/>.
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const L10N = path.join(ROOT, "lib", "l10n");
const EN_PATH = path.join(L10N, "app_en.arb");

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

function placeholderNames(s) {
  const m = [...s.matchAll(/\{([a-zA-Z_][a-zA-Z0-9_]*)\}/g)];
  return [...new Set(m.map((x) => x[1]))];
}

function mask(s) {
  return s.replace(/\{([a-zA-Z_][a-zA-Z0-9_]*)\}/g, (_, n) => `\u2060${n}\u2060`);
}

function unmask(s) {
  return s.replace(/\u2060([a-zA-Z_][a-zA-Z0-9_]*)\u2060/g, (_, n) => `{${n}}`);
}

function placeholdersOk(enVal, locVal) {
  const names = placeholderNames(enVal);
  if (names.length === 0) return true;
  if (typeof locVal !== "string") return false;
  return names.every((n) => locVal.includes(`{${n}}`));
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function gtx(text, tl) {
  const url =
    "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=" +
    encodeURIComponent(tl) +
    "&dt=t&q=" +
    encodeURIComponent(text);
  const ctrl = new AbortController();
  const id = setTimeout(() => ctrl.abort(), 15000);
  try {
    const res = await fetch(url, { signal: ctrl.signal });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    return String(data[0][0][0] ?? "");
  } finally {
    clearTimeout(id);
  }
}

async function translateFixed(enText, tl) {
  const masked = mask(enText);
  let last;
  for (let i = 0; i < 8; i++) {
    try {
      const raw = await gtx(masked, tl);
      const out = unmask(raw);
      await sleep(100);
      return out;
    } catch (e) {
      last = e;
      await sleep(500 * (i + 1));
    }
  }
  throw last;
}

async function main() {
  const en = JSON.parse(fs.readFileSync(EN_PATH, "utf8"));
  const keys = Object.keys(en)
    .filter((k) => k !== "@@locale" && !k.startsWith("@"))
    .sort();

  for (const [fileCode, gtxTl] of LANGS) {
    const p = path.join(L10N, `app_${fileCode}.arb`);
    const loc = JSON.parse(fs.readFileSync(p, "utf8"));
    let fixes = 0;
    for (const k of keys) {
      const enVal = en[k];
      if (typeof enVal !== "string") continue;
      if (placeholderNames(enVal).length === 0) continue;
      const cur = loc[k];
      if (placeholdersOk(enVal, cur)) continue;
      try {
        loc[k] = await translateFixed(enVal, gtxTl);
        fixes++;
      } catch (e) {
        console.warn("FAILED", fileCode, k, e?.message || e);
      }
    }
    fs.writeFileSync(p, JSON.stringify(loc, null, 2) + "\n", "utf8");
    console.log(fileCode, "fixed", fixes);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
