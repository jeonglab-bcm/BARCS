#include "GuideIndex.h"

#include <string>
#include <vector>

//' Count guide barcodes in FASTQ files
//'
//' Compiled entry point behind [barcs_quant()]. It builds the guide index
//' once and scans each FASTQ file in turn, so the library FASTA is parsed a
//' single time no matter how many samples are supplied.
//'
//' @param library_path Path to the guide library FASTA file.
//' @param fastq_path Character vector of plain-text FASTQ paths. Compressed
//'   input must be expanded by the caller first.
//' @param verbose Write progress to the standard error stream.
//'
//' @return A list with the guide names and sequences, the guide-by-sample
//'   count matrix, per-sample read and mapped-read totals, a per-sample
//'   reverse-complement flag, the detected guide length, and the number of
//'   library entries dropped as repeated, off-length, or non-ACGT.
//'
//' @keywords internal
// [[Rcpp::export]]
Rcpp::List barcs_quant_cpp(const std::string &library_path,
                           const std::vector<std::string> &fastq_path,
                           bool verbose = false) {
  const barcs::GuideLibrary library(library_path, verbose);
  const int n_guides = static_cast<int>(library.name.size());
  const int n_samples = static_cast<int>(fastq_path.size());

  Rcpp::NumericMatrix count(n_guides, n_samples);
  Rcpp::NumericVector reads(n_samples);
  Rcpp::NumericVector mapped(n_samples);
  Rcpp::LogicalVector reverse_complement(n_samples);

  for (int j = 0; j < n_samples; ++j) {
    barcs::ReadCounter counter(library);
    counter.run(fastq_path[j], verbose);
    const std::vector<double> &sample_count = counter.counts();
    for (int i = 0; i < n_guides; ++i) {
      count(i, j) = sample_count[i];
    }
    reads[j] = static_cast<double>(counter.reads);
    mapped[j] = static_cast<double>(counter.hits());
    reverse_complement[j] = counter.is_reverse();
  }

  return Rcpp::List::create(
      Rcpp::_["guide"] = library.name,
      Rcpp::_["sequence"] = library.sequence,
      Rcpp::_["count"] = count,
      Rcpp::_["reads"] = reads,
      Rcpp::_["mapped"] = mapped,
      Rcpp::_["reverse_complement"] = reverse_complement,
      Rcpp::_["guide_length"] = library.guide_length,
      Rcpp::_["n_duplicate"] = library.n_duplicate,
      Rcpp::_["n_wrong_length"] = library.n_wrong_length,
      Rcpp::_["n_invalid"] = library.n_invalid);
}
