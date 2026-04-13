/** Regenerate every app_<code>.arb from app_en.arb (stable <ph_name/> ICU mask). */
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

function maskIcu(s) {
  return s.replace(/\{([a-zA-Z_][a-zA-Z0-9_]*)\}/g, (_, name) => `<ph_${name}/>`);
}

function unmaskIcu(s) {
  return s.replace(/<ph_([a-zA-Z_][a-zA-Z0-9_]*)\/>/g, (_, name) => `{${name}}`);
}

function phNames(s) {
  return [...new Set([...s.matchAll(/\{([a-zA-Z_][a-zA-Z0-9_]*)\}/g)].map((m) => m[1]))];
}

function placeholdersOk(enVal, outVal) {
  const names = phNames(enVal);
  if (!names.length) return true;
  if (typeof outVal !== "string") return false;
  if (outVal.includes("<ph_")) return false;
  return names.every((n) => outVal.includes(`{${n}}`));
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

async function translateOne(enText, tl, cache) {
  const masked = maskIcu(enText);
  const ck = tl + "\n" + masked;
  if (cache.has(ck)) return cache.get(ck);
  let last;
  for (let attempt = 0; attempt < 8; attempt++) {
    try {
      const raw = await gtx(masked, tl);
      let out = unmaskIcu(raw);
      if (!placeholdersOk(enText, out)) {
        last = new Error("placeholder mismatch");
        await sleep(400 * (attempt + 1));
        continue;
      }
      cache.set(ck, out);
      await sleep(95);
      return out;
    } catch (e) {
      last = e;
      await sleep(500 * (attempt + 1));
    }
  }
  console.warn("fallback EN", tl, enText.slice(0, 60), last?.message || last);
  cache.set(ck, enText);
  return enText;
}

async function buildLang(fileCode, gtxTl) {
  const en = JSON.parse(fs.readFileSync(EN_PATH, "utf8"));
  const keys = Object.keys(en)
    .filter((k) => k !== "@@locale" && !k.startsWith("@"))
    .sort();
  const cache = new Map();
  const out = { "@@locale": fileCode };
  let n = 0;
  for (const k of keys) {
    const v = en[k];
    if (typeof v !== "string") continue;
    out[k] = await translateOne(v, gtxTl, cache);
    n++;
    if (n % 60 === 0) console.log(fileCode, n, "/", keys.length);
  }
  const outPath = path.join(L10N, `app_${fileCode}.arb`);
  fs.writeFileSync(outPath, JSON.stringify(out, null, 2) + "\n", "utf8");
  console.log("Wrote", path.basename(outPath));
}

async function main() {
  for (const [code, tl] of LANGS) {
    await buildLang(code, tl);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
