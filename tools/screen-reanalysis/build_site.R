#!/usr/bin/env Rscript
# Build the static reanalysis website from reanalyses/<GSE>/ records.
#
#   Rscript tools/screen-reanalysis/build_site.R [--src reanalyses] [--out _site]
#
# Writes <out>/index.html (one row per screen), <out>/<GSE>.html (verdict,
# volcano of the primary contrast with the paper's named genes, run details,
# and the full report), <out>/site.css, and <out>/data/<GSE>/ (gene tables).
# Needs only jsonlite and commonmark, not BARCS, so CI can build it quickly.

suppressPackageStartupMessages({
  library(jsonlite)
  library(commonmark)
})
`%||%` <- function(a, b) if (is.null(a) || !length(a)) b else a
write_utf8 <- function(text, path) writeLines(enc2utf8(text), path, useBytes = TRUE)

args <- commandArgs(trailingOnly = TRUE)
option <- function(name, default) {
  hit <- match(paste0("--", name), args)
  if (is.na(hit)) default else args[[hit + 1L]]
}
src <- option("src", "reanalyses")
out <- option("out", "_site")
dir.create(file.path(out, "data"), recursive = TRUE, showWarnings = FALSE)

esc <- function(x) {
  x <- gsub("&", "&amp;", as.character(x), fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  gsub('"', "&quot;", x, fixed = TRUE)
}
fmt_p <- function(p) ifelse(is.na(p), "&mdash;", ifelse(p < 1e-3, formatC(p, format = "e", digits = 1),
                                                   formatC(p, format = "fg", digits = 2)))
status <- list(
  agree = c(label = "Agrees", icon = "&#10003;"),
  partial = c(label = "Partly agrees", icon = "&#9680;"),
  differ = c(label = "Differs", icon = "&#9888;")
)
badge <- function(agreement) {
  s <- status[[agreement]]
  sprintf('<span class="badge badge-%s"><span aria-hidden="true">%s</span> %s</span>',
          agreement, s[["icon"]], s[["label"]])
}

page <- function(title, body, description = "") {
  sprintf('<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>%s</title>
<meta name="description" content="%s">
<link rel="stylesheet" href="site.css">
</head>
<body>
<header class="top"><a class="brand" href="index.html">BARCS reanalyses</a>
<a class="ext" href="https://github.com/jeonglab-bcm/barcs">Package</a></header>
<main>
%s
</main>
<footer>Built %s with BARCS screen-reanalysis tools. Reanalyses are independent and may differ from the original authors&rsquo; intent; each page states its assumptions.</footer>
</body>
</html>
', esc(title), esc(description), body, format(Sys.Date()))
}

# ---- volcano of the primary contrast -----------------------------------------
volcano <- function(genes, named) {
  w <- 720; h <- 420; left <- 56; right <- 20; top <- 16; bottom <- 48
  genes <- genes[is.finite(genes$estimate) & is.finite(genes$p_value), ]
  genes$y <- -log10(pmax(genes$p_value, 1e-300))
  is_named <- toupper(genes$gene) %in% toupper(named)
  lim <- max(abs(stats::quantile(genes$estimate, c(0.005, 0.995))),
             abs(genes$estimate[is_named]), 0.05)
  lim <- max(pretty(c(0, lim * 1.05)))
  ymax <- max(ceiling(max(genes$y)), 2)
  sx <- function(x) left + (pmin(pmax(x, -lim), lim) + lim) / (2 * lim) * (w - left - right)
  sy <- function(y) top + (1 - y / ymax) * (h - top - bottom)

  # Background: every gene with p < 0.05 plus a fixed sample of the rest.
  set.seed(1)
  rest <- which(!is_named & genes$p_value >= 0.05)
  keep <- c(which(!is_named & genes$p_value < 0.05), rest[sample.int(length(rest), min(3000L, length(rest)))])
  bg <- genes[keep, ]
  grid_y <- pretty(c(0, ymax))
  grid_y <- grid_y[grid_y <= ymax]
  grid_x <- pretty(c(-lim, lim))
  grid_x <- grid_x[abs(grid_x) <= lim]

  parts <- c(
    sprintf('<svg class="volcano" viewBox="0 0 %d %d" role="img" aria-labelledby="vtitle vdesc">', w, h),
    '<title id="vtitle">Gene effect versus significance</title>',
    sprintf('<desc id="vdesc">%d genes; the paper&rsquo;s named genes are highlighted and labeled.</desc>', nrow(genes)),
    sprintf('<line class="grid" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/>', left, w - right, sy(grid_y), sy(grid_y)),
    sprintf('<text class="tick" x="%d" y="%.1f" text-anchor="end">%s</text>', left - 8, sy(grid_y) + 4, grid_y),
    sprintf('<line class="axis" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/>', sx(0), sx(0), top, h - bottom),
    sprintf('<line class="axis" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/>', left, w - right, sy(0), sy(0)),
    sprintf('<text class="tick" x="%.1f" y="%d" text-anchor="middle">%s</text>', sx(grid_x), h - bottom + 18, grid_x),
    sprintf('<text class="axis-label" x="%.1f" y="%d" text-anchor="middle">BARCS effect (log odds; treatment vs reference)</text>',
            (left + w - right) / 2, h - 8),
    sprintf('<text class="axis-label" transform="translate(14 %.1f) rotate(-90)" text-anchor="middle">&minus;log10 p</text>',
            (top + h - bottom) / 2)
  )
  sig <- genes$fdr < 0.10
  if (any(sig, na.rm = TRUE)) {
    cut <- max(genes$y[!sig | is.na(sig)][genes$y[!sig | is.na(sig)] < min(genes$y[which(sig)])], 0)
    yline <- sy((cut + min(genes$y[which(sig)])) / 2)
    parts <- c(parts, sprintf('<line class="threshold" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/>', left, w - right, yline, yline),
               sprintf('<text class="tick" x="%d" y="%.1f" text-anchor="end">FDR 0.10</text>', w - right, yline - 6))
  }
  parts <- c(parts, '<g class="bg">',
             sprintf('<circle cx="%.1f" cy="%.1f" r="1.8"/>', sx(bg$estimate), sy(bg$y)), '</g>')
  hits <- genes[is_named, ]
  hits <- hits[order(hits$y), ]
  placed <- matrix(numeric(), 0, 4)  # x0, x1, y0, y1 of labels already drawn
  overlaps <- function(box) any(box[1] < placed[, 2] & box[2] > placed[, 1] &
                                  box[3] < placed[, 4] & box[4] > placed[, 3])
  hits <- hits[order(-hits$y), ]
  for (i in seq_len(nrow(hits))) {
    r <- hits[i, ]
    cx <- sx(r$estimate); cy <- sy(r$y)
    width <- 7.5 * nchar(r$gene)
    label_y <- cy + 4
    anchor <- if (cx > w - 120) "end" else "start"
    box_for <- function(anchor, y) {
      x0 <- if (anchor == "end") cx - 9 - width else cx + 9
      c(x0, x0 + width, y - 11, y + 3)
    }
    if (overlaps(box_for(anchor, label_y))) {
      flipped <- if (anchor == "end") "start" else "end"
      if (!overlaps(box_for(flipped, label_y)) && (flipped == "end" || cx + 9 + width < w)) {
        anchor <- flipped
      } else {
        while (overlaps(box_for(anchor, label_y))) label_y <- label_y + 14
      }
    }
    placed <- rbind(placed, box_for(anchor, label_y))
    dx <- if (anchor == "end") -9 else 9
    parts <- c(parts, sprintf(
      '<g class="hit" tabindex="0"><title>%s: effect %.2f, p %s, FDR %s</title><circle class="hit-target" cx="%.1f" cy="%.1f" r="12"/><circle class="hit-dot" cx="%.1f" cy="%.1f" r="5"/><text class="hit-label" x="%.1f" y="%.1f" text-anchor="%s">%s</text></g>',
      esc(r$gene), r$estimate, fmt_p(r$p_value), fmt_p(r$fdr), cx, cy, cx, cy, cx + dx, label_y, anchor, esc(r$gene)))
  }
  c(parts, "</svg>")
}

# ---- read every record --------------------------------------------------------
records <- list()
for (dir in sort(list.dirs(src, recursive = FALSE))) {
  if (!file.exists(file.path(dir, "meta.json"))) next
  meta <- fromJSON(file.path(dir, "meta.json"))
  compare <- fromJSON(file.path(dir, "compare.json"))
  primary <- basename(dirname(compare$barcs_genes))
  runs <- list.dirs(file.path(dir, "results"), recursive = FALSE)
  primary_info <- file.path(dir, "results", primary, "run_info.json")
  control_calls <- if (file.exists(primary_info)) fromJSON(primary_info)$genes_empirical_fdr_0_10 else NULL
  records[[meta$gse]] <- list(dir = dir, meta = meta, compare = compare, primary = primary, runs = runs,
                              control_calls = control_calls)
}
order_key <- vapply(records, function(r) r$meta$analyzed %||% "", character(1))
records <- records[order(order_key, decreasing = TRUE)]

# ---- one page per screen ------------------------------------------------------
for (rec in records) {
  meta <- rec$meta
  data_dir <- file.path(out, "data", meta$gse)
  dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)
  run_rows <- character()
  downloads <- character()
  for (run in rec$runs) {
    info <- fromJSON(file.path(run, "run_info.json"))
    file.copy(file.path(run, "genes.csv.gz"), file.path(data_dir, paste0(basename(run), "_genes.csv.gz")),
              overwrite = TRUE)
    downloads <- c(downloads, sprintf('<li><a href="data/%s/%s_genes.csv.gz">%s gene table</a> (CSV)</li>',
                                      meta$gse, basename(run), esc(basename(run))))
    run_rows <- c(run_rows, sprintf(
      "<tr><td>%s%s</td><td><code>%s</code></td><td>%s</td><td class=\"num\">%d</td><td class=\"num\">%d</td><td class=\"num\">%s</td><td class=\"num\">%d</td><td class=\"num\">%d</td><td class=\"num\">%s</td></tr>",
      esc(info$analysis), if (basename(run) == rec$primary) " <span class=\"tag\">primary</span>" else "",
      esc(info$formula), esc(info$term), info$libraries, info$residual_df,
      formatC(info$guide_correlation %||% NA, format = "f", digits = 3),
      info$genes_fdr_0_05, info$genes_fdr_0_10,
      if (is.null(info$genes_empirical_fdr_0_10)) "&mdash;" else format(info$genes_empirical_fdr_0_10, big.mark = ",")))
  }
  genes <- utils::read.csv(file.path(rec$dir, "results", rec$primary, "genes.csv.gz"), stringsAsFactors = FALSE)
  genes <- genes[order(genes$p_value), ]
  genes$rank <- seq_len(nrow(genes))
  if (is.null(genes$empirical_fdr)) genes$empirical_fdr <- NA_real_
  named <- unlist(rec$compare$named_hits %||% character())
  hit_rows <- character()
  for (g in named) {
    r <- genes[match(toupper(g), toupper(genes$gene)), ]
    hit_rows <- c(hit_rows, if (is.na(r$gene)) sprintf("<tr><td>%s</td><td colspan=\"5\">not tested</td></tr>", esc(g)) else
      sprintf("<tr><td>%s</td><td class=\"num\">%.2f</td><td class=\"num\">%s</td><td class=\"num\">%s</td><td class=\"num\">%s</td><td class=\"num\">%s of %s</td></tr>",
              esc(r$gene), r$estimate, fmt_p(r$p_value), fmt_p(r$fdr), fmt_p(r$empirical_fdr),
              format(r$rank, big.mark = ","), format(nrow(genes), big.mark = ",")))
  }
  top <- utils::head(genes, 15L)
  top_rows <- sprintf("<tr><td>%s</td><td class=\"num\">%d</td><td class=\"num\">%.2f</td><td class=\"num\">%s</td><td class=\"num\">%s</td><td class=\"num\">%s</td></tr>",
                      esc(top$gene), top$n_guides, top$estimate, fmt_p(top$p_value), fmt_p(top$fdr), fmt_p(top$empirical_fdr))
  report <- markdown_html(paste(readLines(file.path(rec$dir, "REPORT.md"), warn = FALSE, encoding = "UTF-8"), collapse = "\n"),
                          extensions = TRUE)
  report <- sub("<h1>[^<]*</h1>\n?", "", report)  # the page already has a title
  report <- gsub("<table>", "<div class=\"table-wrap\"><table>", report, fixed = TRUE)
  report <- gsub("</table>", "</table></div>", report, fixed = TRUE)
  control_note <- '<p class="muted"><strong>Control-null FDR</strong> comes from <code>bb_gene_empirical_null()</code>: each gene is ranked against pseudo-genes built from the non-targeting guides, so it does not rely on the model&rsquo;s reference distribution. It needs at least 100 usable controls (&mdash; otherwise). It can be stricter or looser than the model FDR, and with one guide per gene its smallest possible p-value is 2&thinsp;/&thinsp;(controls&nbsp;+&nbsp;1), which can leave nothing passing.</p>'
  paper_link <- if (!is.null(meta$doi)) sprintf("https://doi.org/%s", meta$doi) else
    sprintf("https://pubmed.ncbi.nlm.nih.gov/%s/", meta$pmid)

  body <- paste(c(
    sprintf('<p class="eyebrow"><a href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=%s">%s</a> &middot; PMID <a href="https://pubmed.ncbi.nlm.nih.gov/%s/">%s</a> &middot; analyzed %s</p>',
            meta$gse, meta$gse, meta$pmid, meta$pmid, esc(meta$analyzed %||% "")),
    sprintf('<h1>%s</h1>', esc(meta$title)),
    sprintf('<p class="byline"><a href="%s"><em>%s</em> (%s)</a> &middot; %s</p>', paper_link, esc(meta$journal),
            esc(meta$published), esc(meta$model %||% "")),
    sprintf('<section class="verdict verdict-%s">%s<p>%s</p></section>', meta$agreement, badge(meta$agreement), esc(meta$verdict)),
    '<dl class="facts">',
    sprintf('<div><dt>Contrast</dt><dd>%s</dd></div>', esc(meta$contrast)),
    sprintf('<div><dt>Paper (%s)</dt><dd>%s</dd></div>', esc(meta$paper_method %||% "original method"), esc(meta$paper_calls %||% "")),
    sprintf('<div><dt>BARCS</dt><dd>%s</dd></div>', esc(meta$barcs_calls %||% "")),
    sprintf('<div><dt>Named genes</dt><dd>%s</dd></div>', esc(meta$named_hits %||% "")),
    '</dl>',
    '<h2>Primary contrast</h2>',
    sprintf('<figure class="chart">%s<figcaption>Each point is a gene (all genes with p &lt; 0.05 and a fixed sample of the rest). Highlighted: genes the paper names. Hover or focus a highlighted gene for values; full values are in the tables below.</figcaption></figure>',
            paste(volcano(genes, named), collapse = "\n")),
    if (length(hit_rows)) c('<h3>Genes the paper names</h3><div class="table-wrap"><table><thead><tr><th>Gene</th><th class="num">Effect</th><th class="num">p</th><th class="num">FDR</th><th class="num">Control-null FDR</th><th class="num">BARCS rank</th></tr></thead><tbody>',
                            hit_rows, '</tbody></table></div>'),
    '<h3>BARCS top 15</h3><div class="table-wrap"><table><thead><tr><th>Gene</th><th class="num">Guides</th><th class="num">Effect</th><th class="num">p</th><th class="num">FDR</th><th class="num">Control-null FDR</th></tr></thead><tbody>',
    top_rows, '</tbody></table></div>',
    '<h2>Runs</h2><div class="table-wrap"><table><thead><tr><th>Analysis</th><th>Model</th><th>Coefficient</th><th class="num">Libraries</th><th class="num">Residual df</th><th class="num">Guide correlation</th><th class="num">FDR 0.05</th><th class="num">FDR 0.10</th><th class="num">Control null, FDR 0.10</th></tr></thead><tbody>',
    run_rows, '</tbody></table></div>',
    control_note,
    '<h2>Report</h2><article class="report">', report, '</article>',
    '<h2>Data</h2><ul class="downloads">', downloads,
    sprintf('<li><a href="https://github.com/jeonglab-bcm/barcs/tree/main/reanalyses/%s">Design, comparison spec and report on GitHub</a></li>', meta$gse),
    '</ul>'
  ), collapse = "\n")
  write_utf8(page(paste(meta$gse, "reanalysis"), body, meta$verdict), file.path(out, paste0(meta$gse, ".html")))
}

# ---- index ----------------------------------------------------------------
counts <- table(factor(vapply(records, function(r) r$meta$agreement, character(1)), levels = names(status)))
rows <- vapply(records, function(rec) {
  m <- rec$meta
  sprintf('<tr><td>%s</td><td><a href="%s.html">%s</a></td><td><span class="paper">%s</span><span class="muted">%s %s</span></td><td>%s</td><td>%s</td><td>%s</td><td class="num">%s</td><td>%s</td></tr>',
          esc(m$analyzed %||% ""), m$gse, m$gse, esc(m$title), esc(m$journal), esc(m$published),
          esc(m$contrast), esc(m$paper_calls %||% ""), esc(m$barcs_calls %||% ""),
          if (is.null(rec$control_calls)) "&mdash;" else format(rec$control_calls, big.mark = ","),
          badge(m$agreement))
}, character(1))
tiles <- c(sprintf('<div class="tile"><span class="tile-value">%d</span><span class="tile-label">screens reanalyzed</span></div>', length(records)),
           sprintf('<div class="tile"><span class="tile-value">%d</span><span class="tile-label">%s</span></div>',
                   as.integer(counts), vapply(status, `[[`, character(1), "label")))
# Series that were checked and could not be reanalyzed, with the reason.
excluded_path <- file.path(src, "excluded.tsv")
excluded <- if (file.exists(excluded_path)) {
  utils::read.delim(excluded_path, stringsAsFactors = FALSE, quote = "", encoding = "UTF-8")
} else {
  data.frame(gse = character(), pmid = character(), title = character(), reason = character())
}
excluded <- excluded[!excluded$gse %in% names(records), , drop = FALSE]
excluded_rows <- if (nrow(excluded)) sprintf(
  '<tr><td><a href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=%s">%s</a></td><td>%s</td><td>%s</td></tr>',
  excluded$gse, excluded$gse, esc(excluded$title), esc(excluded$reason)) else character()
search_note <- if (file.exists(file.path(src, "search.json"))) {
  search <- fromJSON(file.path(src, "search.json"))
  sprintf('<p class="muted">Last search %s: %s PubMed papers linked to GEO in the previous %s days gave %s candidate series; %d reanalyzed and %d screened out below.</p>',
          esc(search$date), esc(search$papers), esc(search$days), esc(search$candidates), length(records), nrow(excluded))
} else ""

index <- paste(c(
  '<h1>Published CRISPR screens, reanalyzed with BARCS</h1>',
  '<p class="lede">Recent pooled screens with raw counts in GEO, rerun with replicate-aware beta-binomial models and compared with what each paper reported. Each page states the design, the assumptions it rests on, and where BARCS and the paper differ.</p>',
  '<div class="tiles">', tiles, '</div>',
  '<div class="table-wrap"><table class="index"><thead><tr><th>Analyzed</th><th>Series</th><th>Paper</th><th>Contrast</th><th>Paper calls</th><th>BARCS calls</th><th class="num">Control null</th><th>Verdict</th></tr></thead><tbody>',
  rows, '</tbody></table></div>',
  '<p class="muted">Agreement labels: <strong>Agrees</strong>, the paper&rsquo;s main hits are recovered at FDR 0.10; <strong>Partly agrees</strong>, some are; <strong>Differs</strong>, BARCS does not support the paper&rsquo;s main calls. A difference is a statement about what the deposited counts support, not a judgment of the follow-up biology. <strong>Control null</strong>: genes in the primary contrast at FDR 0.10 against pseudo-genes built from the non-targeting guides (&mdash; when there are fewer than 100 usable controls).</p>',
  search_note,
  if (length(excluded_rows)) c(
    sprintf('<h2>Screened out (%d)</h2>', length(excluded_rows)),
    '<p class="muted">Series the search returned that cannot be reanalyzed faithfully from what was deposited.</p>',
    '<div class="table-wrap"><table><thead><tr><th>Series</th><th>Title</th><th>Reason</th></tr></thead><tbody>',
    excluded_rows, '</tbody></table></div>')
), collapse = "\n")
write_utf8(page("BARCS reanalyses", index, "Published CRISPR screens reanalyzed with BARCS"), file.path(out, "index.html"))

write_utf8('
:root {
  color-scheme: light;
  --page: #f9f9f7; --surface: #fcfcfb; --ink: #0b0b0b; --ink-2: #52514e; --muted: #6b6a66;
  --grid: #e1e0d9; --axis: #c3c2b7; --border: rgba(11,11,11,0.10);
  --accent: #2a78d6; --bg-point: #a9a8a1;
  --good: #0ca30c; --warning: #fab219; --serious: #ec835a; --good-ink: #006300; --warning-ink: #7a5300; --serious-ink: #9a3b14;
}
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    color-scheme: dark;
    --page: #0d0d0d; --surface: #1a1a19; --ink: #ffffff; --ink-2: #c3c2b7; --muted: #a3a29a;
    --grid: #2c2c2a; --axis: #383835; --border: rgba(255,255,255,0.10);
    --accent: #3987e5; --bg-point: #5c5b57;
    --good-ink: #0ca30c; --warning-ink: #fab219; --serious-ink: #ec835a;
  }
}
:root[data-theme="dark"] {
  color-scheme: dark;
  --page: #0d0d0d; --surface: #1a1a19; --ink: #ffffff; --ink-2: #c3c2b7; --muted: #a3a29a;
  --grid: #2c2c2a; --axis: #383835; --border: rgba(255,255,255,0.10);
  --accent: #3987e5; --bg-point: #5c5b57;
  --good-ink: #0ca30c; --warning-ink: #fab219; --serious-ink: #ec835a;
}
* { box-sizing: border-box; }
body { margin: 0; background: var(--page); color: var(--ink);
  font: 16px/1.55 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; }
a { color: var(--accent); }
.top { display: flex; justify-content: space-between; align-items: center; max-width: 1080px; margin: 0 auto; padding: 16px; }
.brand { font-weight: 650; color: var(--ink); text-decoration: none; }
.ext { color: var(--ink-2); font-size: 14px; }
main { max-width: 1080px; margin: 0 auto; padding: 8px 16px 48px; }
footer { max-width: 1080px; margin: 0 auto; padding: 24px 16px 40px; color: var(--muted); font-size: 13px; border-top: 1px solid var(--border); }
h1 { font-size: clamp(24px, 4vw, 34px); line-height: 1.2; margin: 8px 0 12px; letter-spacing: -0.01em; }
h2 { font-size: 21px; margin: 40px 0 12px; }
h3 { font-size: 16px; margin: 28px 0 8px; color: var(--ink-2); }
.lede { font-size: 18px; color: var(--ink-2); max-width: 70ch; }
.eyebrow, .byline, .muted { color: var(--muted); font-size: 14px; }
.tiles { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 12px; margin: 24px 0; }
.tile { background: var(--surface); border: 1px solid var(--border); border-radius: 10px; padding: 14px 16px; display: flex; flex-direction: column; }
.tile-value { font-size: 30px; font-weight: 650; font-variant-numeric: tabular-nums; }
.tile-label { color: var(--ink-2); font-size: 14px; }
.table-wrap { overflow-x: auto; background: var(--surface); border: 1px solid var(--border); border-radius: 10px; }
table { border-collapse: collapse; width: 100%; font-size: 14px; }
th, td { text-align: left; padding: 9px 12px; border-bottom: 1px solid var(--grid); vertical-align: top; }
th { color: var(--ink-2); font-weight: 600; white-space: nowrap; }
tr:last-child td { border-bottom: 0; }
.num { text-align: right; font-variant-numeric: tabular-nums; white-space: nowrap; }
.paper { display: block; max-width: 42ch; }
table.index td:first-child { white-space: nowrap; }
.badge { display: inline-flex; gap: 6px; align-items: center; white-space: nowrap; font-size: 13px; font-weight: 600;
  border-radius: 999px; padding: 2px 10px; border: 1px solid currentColor; }
.badge-agree { color: var(--good-ink); } .badge-partial { color: var(--warning-ink); } .badge-differ { color: var(--serious-ink); }
.verdict { background: var(--surface); border: 1px solid var(--border); border-left: 4px solid; border-radius: 10px; padding: 14px 16px; margin: 20px 0; }
.verdict p { margin: 8px 0 0; }
.verdict-agree { border-left-color: var(--good); } .verdict-partial { border-left-color: var(--warning); } .verdict-differ { border-left-color: var(--serious); }
.facts { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px; margin: 0; }
.facts div { background: var(--surface); border: 1px solid var(--border); border-radius: 10px; padding: 12px 14px; }
.facts dt { color: var(--muted); font-size: 13px; } .facts dd { margin: 4px 0 0; }
.tag { font-size: 12px; color: var(--ink-2); border: 1px solid var(--border); border-radius: 6px; padding: 0 6px; margin-left: 4px; }
.chart { margin: 0; background: var(--surface); border: 1px solid var(--border); border-radius: 10px; padding: 12px; }
.chart figcaption { color: var(--muted); font-size: 13px; margin-top: 6px; }
.volcano { width: 100%; height: auto; display: block; }
.volcano .grid { stroke: var(--grid); stroke-width: 1; }
.volcano .axis { stroke: var(--axis); stroke-width: 1; }
.volcano .threshold { stroke: var(--ink-2); stroke-width: 1; stroke-dasharray: 4 4; }
.volcano .tick { fill: var(--muted); font-size: 12px; font-variant-numeric: tabular-nums; }
.volcano .axis-label { fill: var(--ink-2); font-size: 12px; }
.volcano .bg circle { fill: var(--bg-point); opacity: 0.55; }
.volcano .hit-target { fill: transparent; }
.volcano .hit-dot { fill: var(--accent); stroke: var(--surface); stroke-width: 2; }
.volcano .hit-label { fill: var(--ink); font-size: 12px; font-weight: 600; paint-order: stroke; stroke: var(--surface); stroke-width: 3px; }
.volcano .hit { cursor: default; outline: none; }
.volcano .hit:hover .hit-dot, .volcano .hit:focus .hit-dot { r: 7; }
.report { background: var(--surface); border: 1px solid var(--border); border-radius: 10px; padding: 4px 20px 12px; }
.report table { margin: 12px 0; } .report h2 { font-size: 18px; margin-top: 24px; }
.report li { margin: 4px 0; }
code { font-size: 13px; }
.downloads li { margin: 4px 0; }
@media (max-width: 600px) { th, td { padding: 8px; } .report { padding: 4px 12px 8px; } }
', file.path(out, "site.css"))
message("Site written to ", out, " (", length(records), " screens).")
