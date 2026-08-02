test_that("quantification returns an aligned count matrix and totals", {
  design <- data.frame(
    sample_name = c("Base1", "Base2", "High1", "High2"),
    group = c("Base", "Base", "High", "High"),
    fastq_path = toydata_path(
      c("Base1.fastq.gz", "Base2.fastq.gz",
        "High1.fastq.gz", "High2.fastq.gz")
    )
  )
  quantified <- barcs_quant(toydata_path("small_sample.fasta"), design)

  expect_s3_class(quantified, "barcs_counts")
  expect_identical(colnames(quantified$counts), design$sample_name)
  expect_identical(rownames(quantified$counts), quantified$guides$guide)
  expect_identical(quantified$library$guide_length, 20L)
  # `totals` is mapped guide reads, the model denominator, and must equal the
  # column sums of the unfiltered count matrix.
  expect_equal(
    unname(quantified$totals), unname(colSums(quantified$counts))
  )
  # `reads` counts FASTQ records and can never be smaller.
  expect_true(all(quantified$reads >= quantified$totals))
  expect_true(all(quantified$counts >= 0))
  expect_gt(sum(quantified$counts), 0)
  expect_output(print(quantified), "<barcs_counts>")
})

test_that("gzipped and plain FASTQ input give the same counts", {
  gzipped <- data.frame(
    sample_name = "Base1", fastq_path = toydata_path("Base1.fastq.gz")
  )
  plain <- data.frame(
    sample_name = "Base1", fastq_path = plain_fastq("Base1")
  )
  fasta <- toydata_path("small_sample.fasta")

  expect_equal(
    barcs_quant(fasta, gzipped)$counts,
    barcs_quant(fasta, plain)$counts
  )
})

test_that("a reverse-complemented library is counted, not silently zeroed", {
  # The predecessor implementation detected the orientation and then returned
  # the forward tally regardless, so a library sequenced on the reverse strand
  # came back with counts of nearly zero.
  fasta <- toydata_path("small_sample.fasta")
  forward <- barcs_quant(
    fasta,
    data.frame(sample_name = "fwd", fastq_path = plain_fastq("Base1"))
  )
  reversed <- barcs_quant(
    fasta,
    data.frame(
      sample_name = "rev",
      fastq_path = reverse_complement_fastq(plain_fastq("Base1"))
    )
  )

  expect_equal(unname(reversed$counts), unname(forward$counts))
  expect_true(unname(reversed$reverse_complement))
  expect_false(unname(forward$reverse_complement))
  expect_equal(unname(reversed$totals), unname(forward$totals))
})

test_that("repeated library sequences are dropped rather than misassigned", {
  # `small_sample_dup.fasta` is the clean library plus RAB_6 and RAB_7, which
  # share one sequence. A read matching it cannot be attributed to either
  # name, so both entries are dropped and the usable library collapses back
  # to exactly the clean one.
  design <- data.frame(
    sample_name = "Base1", fastq_path = toydata_path("Base1.fastq.gz")
  )
  clean <- barcs_quant(toydata_path("small_sample.fasta"), design)
  duplicated <- barcs_quant(toydata_path("small_sample_dup.fasta"), design)

  expect_identical(duplicated$library$n_duplicate, 2L)
  expect_false(anyDuplicated(duplicated$guides$sequence) > 0)
  expect_false(any(c("RAB_6", "RAB_7") %in% duplicated$guides$guide))
  expect_identical(duplicated$guides, clean$guides)
  expect_equal(duplicated$counts, clean$counts)
})

test_that("the FASTA parser handles descriptions and wrapped sequences", {
  reference <- readLines(toydata_path("small_sample.fasta"))
  headers <- reference[c(TRUE, FALSE)]
  sequences <- reference[c(FALSE, TRUE)]

  # Same library, but each header carries a description and each sequence is
  # wrapped across two lines. A whitespace-token parser reads the description
  # as the sequence and produces a garbage index.
  awkward <- tempfile(fileext = ".fasta")
  writeLines(
    unlist(Map(
      function(header, sequence) {
        c(paste(header, "| designed guide, chr1:1000-1020"),
          substr(sequence, 1, 10), substr(sequence, 11, 20))
      },
      headers, sequences
    )),
    awkward
  )

  design <- data.frame(
    sample_name = "Base1", fastq_path = toydata_path("Base1.fastq.gz")
  )
  expect_equal(
    barcs_quant(awkward, design)$counts,
    barcs_quant(toydata_path("small_sample.fasta"), design)$counts
  )
})

test_that("a guide-to-gene map is joined onto the library", {
  design <- data.frame(
    sample_name = "Base1", fastq_path = toydata_path("Base1.fastq.gz")
  )
  quantified <- barcs_quant(
    toydata_path("small_sample.fasta"), design,
    map_path = toydata_path("sg2gene.csv")
  )

  expect_true("gene" %in% names(quantified$guides))
  expect_false(anyNA(quantified$guides$gene))
  expect_identical(nrow(quantified$guides), nrow(quantified$counts))
})

test_that("mappability is reported per sample", {
  design <- data.frame(
    sample_name = c("Base1", "High1"),
    group = c("Base", "High"),
    fastq_path = toydata_path(c("Base1.fastq.gz", "High1.fastq.gz"))
  )
  mappability <- barcs_mappability(barcs_quant(
    toydata_path("small_sample.fasta"), design
  ))

  expect_identical(nrow(mappability), 2L)
  expect_true(all(
    c("sample_name", "group", "total_reads", "mapped_reads", "mappability") %in%
      names(mappability)
  ))
  # `fastq_path` is dropped: it is a local detail, not a screen statistic.
  expect_false("fastq_path" %in% names(mappability))
  expect_true(all(mappability$mappability >= 0 &
                    mappability$mappability <= 100))
  expect_error(barcs_mappability(list()), "`barcs_counts` object")
})

test_that("forked and serial quantification agree", {
  skip_on_os("windows")
  design <- data.frame(
    sample_name = c("Base1", "Base2", "High1", "High2", "Low1"),
    fastq_path = toydata_path(
      c("Base1.fastq.gz", "Base2.fastq.gz", "High1.fastq.gz",
        "High2.fastq.gz", "Low1.fastq.gz")
    )
  )
  fasta <- toydata_path("small_sample.fasta")

  serial <- barcs_quant(fasta, design, ncores = 1L)
  forked <- barcs_quant(fasta, design, ncores = 2L)

  expect_equal(serial$counts, forked$counts)
  expect_equal(serial$totals, forked$totals)
  expect_equal(serial$reads, forked$reads)
  expect_equal(serial$reverse_complement, forked$reverse_complement)
})

test_that("barcs_quant validates its arguments", {
  fasta <- toydata_path("small_sample.fasta")
  design <- data.frame(
    sample_name = "Base1", fastq_path = toydata_path("Base1.fastq.gz")
  )

  expect_error(barcs_quant(tempfile(), design), "does not exist")
  expect_error(
    barcs_quant(fasta, data.frame(sample_name = "a")),
    "`sample_name` and `fastq_path`"
  )
  expect_error(
    barcs_quant(fasta, data.frame(sample_name = character(),
                                  fastq_path = character())),
    "at least one sample"
  )
  expect_error(
    barcs_quant(fasta, data.frame(sample_name = c("a", "a"),
                                  fastq_path = rep(design$fastq_path, 2))),
    "unique and non-missing"
  )
  expect_error(
    barcs_quant(fasta, data.frame(sample_name = "a", fastq_path = tempfile())),
    "do not exist"
  )
  expect_error(barcs_quant(fasta, design, ncores = 0), "one positive integer")
  expect_error(barcs_quant(fasta, design, map_path = tempfile()),
               "one path to an existing file")
})

test_that("a malformed guide-to-gene map is rejected", {
  fasta <- toydata_path("small_sample.fasta")
  design <- data.frame(
    sample_name = "Base1", fastq_path = toydata_path("Base1.fastq.gz")
  )

  no_gene <- tempfile(fileext = ".csv")
  write.csv(data.frame(id = "POSCTRL_1"), no_gene, row.names = FALSE)
  expect_error(
    barcs_quant(fasta, design, map_path = no_gene),
    "must contain a `gene` column"
  )

  repeated <- tempfile(fileext = ".csv")
  write.csv(
    data.frame(id = c("POSCTRL_1", "POSCTRL_1"), gene = c("A", "B")),
    repeated, row.names = FALSE
  )
  expect_error(
    barcs_quant(fasta, design, map_path = repeated),
    "same guide more than once"
  )

  wrong_extension <- tempfile(fileext = ".xlsx")
  file.create(wrong_extension)
  expect_error(
    barcs_quant(fasta, design, map_path = wrong_extension),
    "\\.csv, \\.tsv, or \\.txt"
  )

  partial <- tempfile(fileext = ".csv")
  write.csv(data.frame(id = "POSCTRL_1", gene = "POS1"), partial,
            row.names = FALSE)
  expect_warning(
    barcs_quant(fasta, design, map_path = partial),
    "have no gene in `map_path`"
  )
})

test_that("counts feed straight into the model", {
  design <- data.frame(
    sample_name = c("Base1", "Base2", "High1", "High2"),
    group = factor(c("Base", "Base", "High", "High"),
                   levels = c("Base", "High")),
    fastq_path = toydata_path(
      c("Base1.fastq.gz", "Base2.fastq.gz",
        "High1.fastq.gz", "High2.fastq.gz")
    )
  )
  quantified <- barcs_quant(toydata_path("small_sample.fasta"), design)
  screen <- bb_screen(
    counts = quantified$counts,
    totals = quantified$totals,
    data = quantified$design,
    formula = ~group,
    term = "groupHigh",
    min_total_count = 0
  )

  expect_identical(nrow(screen), nrow(quantified$counts))
  expect_true(any(screen$converged))
})
