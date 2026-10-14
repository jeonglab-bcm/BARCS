# Builds the paper's gene table, split by sub-library pool.
#
# The count files are used as deposited (suppl/GSE282260_Pool{A,B,C,D}_cts.txt.gz,
# one per separately transduced sub-library pool, analyzed separately).
#
# Published table: eLife Supplementary file 1 (elife-101626-supp1-v1.xlsx,
# Sheet1) gives the paper's MAGeCK gene results for floxuridine vs untreated
# at the end point of each pool: Gene, "-log2(fold change)", "-log10(p-value)",
# "Library Subpool". Despite its header the fold-change column is negative for
# genes depleted under floxuridine (UNG -4.5, TK1 +3.4); it is written as lfc,
# and the p-value column as neglog10p. One gene name is Excel-mangled
# ("44260"); it is kept as is. Output: paper/supp1_pool{A,B,C,D}.csv.
#
#   Rscript work/GSE282260/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
xlsx <- file.path(tempdir(), "elife-101626-supp1-v1.xlsx")
utils::download.file("https://cdn.elifesciences.org/articles/101626/elife-101626-supp1-v1.xlsx",
                     xlsx, mode = "wb", quiet = TRUE)
s1 <- as.data.frame(readxl::read_excel(xlsx, sheet = "Sheet1"))
names(s1) <- c("gene", "lfc", "neglog10p", "pool")
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
for (p in c("A", "B", "C", "D")) {
  utils::write.csv(s1[s1$pool == p, c("gene", "lfc", "neglog10p")],
                   file.path(workdir, "paper", sprintf("supp1_pool%s.csv", p)), row.names = FALSE)
}
