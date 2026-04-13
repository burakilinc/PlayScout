/** Usage: node tool/gtx_one_lang.mjs fr fr (fileCode gtxTl) */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const L10N = path.join(ROOT, "lib", "l10n");
const EN_PATH = path.join(L10N, "app_en.arb");

const [fileCode, gtxTl] = process.argv.slice(2);
if (!fileCode || !gtxTl) {
  console.error("Usage: node tool/gtx_one_lang.mjs <fileCode> <gtxTl>");
  process.exit(1);
}

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

async function translateOne(text, tl, cache) {
  const masked = maskIcu(text);
  const ck = tl + "\n" + masked;
  if (cache.has(ck)) return cache.get(ck);
  let last;
  for (let i = 0; i < 8; i++) {
    try {
      const raw = await gtx(masked, tl);
      const out = unmaskIcu(raw);
      cache.set(ck, out);
      await sleep(100);
      return out;
    } catch (e) {
      last = e;
      await sleep(600 * (i + 1));
    }
  }
  console.warn("fallback EN:", text.slice(0, 50), last?.message || last);
  cache.set(ck, text);
  return text;
}

async function main() {
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
    if (n % 50 === 0) console.log(n, "/", keys.length);
  }
  const outPath = path.join(L10N, `app_${fileCode}.arb`);
  fs.writeFileSync(outPath, JSON.stringify(out, null, 2) + "\n", "utf8");
  console.log("Wrote", path.basename(outPath));
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
