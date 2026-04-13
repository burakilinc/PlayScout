/**
 * Build app_<lang>.arb from app_en.arb using Google Translate (gtx) with ICU placeholder masking.
 * Run from repo: node tool/gtx_build_arbs.mjs
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const L10N = path.join(ROOT, "lib", "l10n");
const EN_PATH = path.join(L10N, "app_en.arb");

/** Flutter locale code -> gtx tl */
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

function maskIcu(s) {
  return s.replace(/\{([a-zA-Z_][a-zA-Z0-9_]*)\}/g, (_, name) => `<ph_${name}/>`);
}

function unmaskIcu(s) {
  return s.replace(/<ph_([a-zA-Z_][a-zA-Z0-9_]*)\/>/g, (_, name) => `{${name}}`);
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function gtx(text, tl) {
  const url =
    "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=" +
    encodeURIComponent(tl) +
    "&dt=t&q=" +
    encodeURIComponent(text);
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const data = await res.json();
  return String(data[0][0][0] ?? "");
}

async function translateOne(text, tl, cache) {
  const masked = maskIcu(text);
  const ck = tl + "\n" + masked;
  if (cache.has(ck)) return cache.get(ck);
  let last;
  for (let i = 0; i < 6; i++) {
    try {
      const raw = await gtx(masked, tl);
      const out = unmaskIcu(raw);
      cache.set(ck, out);
      await sleep(120);
      return out;
    } catch (e) {
      last = e;
      await sleep(500 * (i + 1));
    }
  }
  console.warn("translate failed, using EN:", tl, text.slice(0, 40), last?.message || last);
  cache.set(ck, text);
  return text;
}

async function main() {
  const en = JSON.parse(fs.readFileSync(EN_PATH, "utf8"));
  const keys = Object.keys(en)
    .filter((k) => k !== "@@locale" && !k.startsWith("@"))
    .sort();

  for (const [fileCode, gtxTl] of LANGS) {
    const cache = new Map();
    const out = { "@@locale": fileCode };
    let n = 0;
    for (const k of keys) {
      const v = en[k];
      if (typeof v !== "string") continue;
      out[k] = await translateOne(v, gtxTl, cache);
      n++;
      if (n % 40 === 0) console.log(fileCode, n, "/", keys.length);
    }
    const outPath = path.join(L10N, `app_${fileCode}.arb`);
    fs.writeFileSync(outPath, JSON.stringify(out, null, 2) + "\n", "utf8");
    console.log("Wrote", path.basename(outPath));
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
