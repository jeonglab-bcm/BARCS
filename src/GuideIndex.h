#ifndef BARCS_GUIDE_INDEX_H
#define BARCS_GUIDE_INDEX_H

// Exact-match guide-barcode index for pooled CRISPR screen FASTQ files.
//
// Every guide in the library is encoded as a 2-bit-per-base integer and
// stored in a hash table.  Each read is scanned with a rolling k-mer of the
// library's guide length; the first window that hits the table wins.  Reads
// that do not hit in the sequenced orientation are rescanned as their reverse
// complement, and the two tallies are kept apart so that the caller can
// decide which orientation the sample was sequenced in.
//
// This is a direct descendant of the AdaptiveHash index in CB2, with the
// same base encoding, so a clean ACGT library hashes to exactly the integers
// it always did.  What differs is spelled out at each site below: a
// line-oriented FASTA parser, an explicit base table that refuses degenerate
// characters instead of silently miscoding them, a single enforced guide
// length, and reverse-complement counts that are actually returned.

#include <Rcpp.h>

#include <algorithm>
#include <fstream>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>

namespace barcs {

// The longest guide a signed 64-bit code can hold at two bits per base.
const int kMaxGuideLength = 31;

// A = 0, C = 1, T = 2, G = 3; anything else is invalid.
//
// These are exactly the values the historical ((c >> 1) & 3) trick produced
// for ACGT, so the encoding is unchanged for well-formed input.  The
// difference is that the old expression mapped every other byte into 0..3 as
// well, so a degenerate IUPAC code such as 'K' silently hashed as a 'C'.
// Here it is rejected and breaks the k-mer window instead.
inline const signed char *base_codes() {
  static signed char table[256];
  static bool ready = false;
  if (!ready) {
    std::fill(table, table + 256, static_cast<signed char>(-1));
    table[static_cast<unsigned char>('A')] = 0;
    table[static_cast<unsigned char>('a')] = 0;
    table[static_cast<unsigned char>('C')] = 1;
    table[static_cast<unsigned char>('c')] = 1;
    table[static_cast<unsigned char>('T')] = 2;
    table[static_cast<unsigned char>('t')] = 2;
    table[static_cast<unsigned char>('G')] = 3;
    table[static_cast<unsigned char>('g')] = 3;
    ready = true;
  }
  return table;
}

// Complement in code space: A(0)<->T(2), C(1)<->G(3).
inline int complement_code(int code) {
  static const int complement[4] = {2, 3, 0, 1};
  return complement[code];
}

// Read a FASTA file into parallel name/sequence vectors.
//
// Unlike the stream-token parser this replaces, it keeps only the first
// whitespace-delimited token of a header as the guide name (so headers
// carrying a description no longer swallow the sequence line) and it
// concatenates wrapped sequence lines.
inline void read_fasta(const std::string &path,
                       std::vector<std::string> *names,
                       std::vector<std::string> *sequences) {
  std::ifstream input(path.c_str());
  if (!input.is_open()) {
    Rcpp::stop("Cannot open the guide library FASTA file '%s'.", path);
  }
  std::string line;
  std::string current;
  bool open_record = false;
  while (std::getline(input, line)) {
    if (!line.empty() && line[line.size() - 1] == '\r') {
      line.erase(line.size() - 1);
    }
    if (line.empty()) {
      continue;
    }
    if (line[0] == '>') {
      if (open_record) {
        sequences->push_back(current);
      }
      std::string header = line.substr(1);
      std::istringstream header_stream(header);
      std::string name;
      header_stream >> name;
      names->push_back(name);
      current.clear();
      open_record = true;
    } else {
      if (!open_record) {
        Rcpp::stop(
            "The guide library FASTA file '%s' has sequence before its first "
            "'>' header line.",
            path);
      }
      current += line;
    }
  }
  if (open_record) {
    sequences->push_back(current);
  }
  if (names->size() != sequences->size()) {
    Rcpp::stop("The guide library FASTA file '%s' is malformed.", path);
  }
}

// The encoded guide library, plus the counts of what had to be discarded.
struct GuideLibrary {
  int guide_length;
  std::vector<std::string> name;
  std::vector<std::string> sequence;
  std::unordered_map<long long, int> position;  // code -> row of `name`
  int n_duplicate;
  int n_wrong_length;
  int n_invalid;

  GuideLibrary(const std::string &path, bool verbose)
      : guide_length(0), n_duplicate(0), n_wrong_length(0), n_invalid(0) {
    std::vector<std::string> raw_name;
    std::vector<std::string> raw_sequence;
    read_fasta(path, &raw_name, &raw_sequence);
    if (raw_name.empty()) {
      Rcpp::stop("The guide library FASTA file '%s' contains no guides.",
                 path);
    }

    // A single guide length has to hold for the whole library: the scanner
    // uses one rolling window width, so a guide of any other length could
    // never be matched and, worse, would be encoded on a different scale.
    // The modal length wins and the stragglers are reported.
    std::unordered_map<int, int> length_tally;
    for (size_t i = 0; i < raw_sequence.size(); ++i) {
      length_tally[static_cast<int>(raw_sequence[i].size())]++;
    }
    int best_count = 0;
    for (std::unordered_map<int, int>::const_iterator it = length_tally.begin();
         it != length_tally.end(); ++it) {
      if (it->second > best_count ||
          (it->second == best_count && it->first > guide_length)) {
        best_count = it->second;
        guide_length = it->first;
      }
    }
    if (guide_length < 1 || guide_length > kMaxGuideLength) {
      Rcpp::stop(
          "The guide library has a guide length of %d; BARCS supports 1 to %d "
          "bases.",
          guide_length, kMaxGuideLength);
    }

    // Sequences seen more than once cannot be assigned to a single guide, so
    // every copy is dropped rather than arbitrarily crediting the first.
    std::unordered_map<std::string, int> sequence_tally;
    for (size_t i = 0; i < raw_sequence.size(); ++i) {
      if (static_cast<int>(raw_sequence[i].size()) == guide_length) {
        sequence_tally[raw_sequence[i]]++;
      }
    }

    const signed char *codes = base_codes();
    for (size_t i = 0; i < raw_sequence.size(); ++i) {
      const std::string &sequence_i = raw_sequence[i];
      if (static_cast<int>(sequence_i.size()) != guide_length) {
        ++n_wrong_length;
        continue;
      }
      if (sequence_tally[sequence_i] != 1) {
        ++n_duplicate;
        continue;
      }
      long long code = 0;
      bool valid = true;
      for (size_t j = 0; j < sequence_i.size(); ++j) {
        const signed char base =
            codes[static_cast<unsigned char>(sequence_i[j])];
        if (base < 0) {
          valid = false;
          break;
        }
        code = code * 4 + base;
      }
      if (!valid) {
        ++n_invalid;
        continue;
      }
      position[code] = static_cast<int>(name.size());
      name.push_back(raw_name[i]);
      sequence.push_back(sequence_i);
    }

    if (name.empty()) {
      Rcpp::stop(
          "No usable guides remain in '%s' after removing %d repeated, %d "
          "off-length, and %d non-ACGT sequences.",
          path, n_duplicate, n_wrong_length, n_invalid);
    }
    if (verbose) {
      Rcpp::Rcerr << "Guide length: " << guide_length << "\n"
                  << "Usable guides: " << name.size() << "\n";
      if (n_duplicate > 0) {
        Rcpp::Rcerr << "Dropped " << n_duplicate
                    << " guides with repeated sequences.\n";
      }
      if (n_wrong_length > 0) {
        Rcpp::Rcerr << "Dropped " << n_wrong_length
                    << " guides that are not " << guide_length
                    << " bases long.\n";
      }
      if (n_invalid > 0) {
        Rcpp::Rcerr << "Dropped " << n_invalid
                    << " guides containing non-ACGT characters.\n";
      }
    }
  }
};

// Per-sample tallies produced by scanning one FASTQ file.
struct ReadCounter {
  const GuideLibrary &library;
  std::vector<double> forward;
  std::vector<double> reverse;
  long long reads;
  long long forward_hits;
  long long reverse_hits;
  long long mask;

  explicit ReadCounter(const GuideLibrary &library_in)
      : library(library_in),
        forward(library_in.name.size(), 0.0),
        reverse(library_in.name.size(), 0.0),
        reads(0),
        forward_hits(0),
        reverse_hits(0),
        mask((1LL << (2 * library_in.guide_length)) - 1) {}

  // Slide a k-mer along `read`, in the given orientation, and credit the
  // first guide it matches.  Returns true when the read was assigned.
  bool scan_orientation(const std::string &read, bool reverse_complement) {
    const signed char *codes = base_codes();
    const int width = library.guide_length;
    const size_t n = read.size();
    long long code = 0;
    int filled = 0;
    for (size_t step = 0; step < n; ++step) {
      const size_t at = reverse_complement ? (n - 1 - step) : step;
      signed char base = codes[static_cast<unsigned char>(read[at])];
      if (base < 0) {
        code = 0;
        filled = 0;
        continue;
      }
      if (reverse_complement) {
        base = static_cast<signed char>(complement_code(base));
      }
      code = ((code * 4) + base) & mask;
      if (filled < width) {
        ++filled;
      }
      if (filled == width) {
        std::unordered_map<long long, int>::const_iterator hit =
            library.position.find(code);
        if (hit != library.position.end()) {
          if (reverse_complement) {
            reverse[hit->second] += 1.0;
            ++reverse_hits;
          } else {
            forward[hit->second] += 1.0;
            ++forward_hits;
          }
          return true;
        }
      }
    }
    return false;
  }

  void run(const std::string &path, bool verbose) {
    std::ifstream input(path.c_str());
    if (!input.is_open()) {
      Rcpp::stop("Cannot open the FASTQ file '%s'.", path);
    }
    if (verbose) {
      Rcpp::Rcerr << "Reading " << path << "\n";
    }
    std::string line;
    long long line_number = 0;
    while (std::getline(input, line)) {
      // A FASTQ record is four lines; the sequence is the second.
      if (line_number++ % 4 != 1) {
        continue;
      }
      if (!line.empty() && line[line.size() - 1] == '\r') {
        line.erase(line.size() - 1);
      }
      ++reads;
      if ((reads % 100000) == 0) {
        // Long FASTQ scans must stay interruptible from the R console.
        Rcpp::checkUserInterrupt();
        if (verbose && (reads % 1000000) == 0) {
          Rcpp::Rcerr << "  " << reads << " reads, mappability "
                      << (100.0 * std::max(forward_hits, reverse_hits) / reads)
                      << "%\n";
        }
      }
      if (!scan_orientation(line, false)) {
        scan_orientation(line, true);
      }
    }
    if (verbose) {
      const double mappability =
          reads > 0 ? 100.0 * std::max(forward_hits, reverse_hits) / reads : 0.0;
      Rcpp::Rcerr << "  " << reads << " reads, final mappability "
                  << mappability << "%\n";
    }
  }

  // The orientation the sample was sequenced in, chosen by whichever pass
  // matched more reads.  The earlier implementation computed this and then
  // discarded it, always returning the forward tally, so a library sequenced
  // on the reverse strand came back with counts of nearly zero.
  bool is_reverse() const { return reverse_hits > forward_hits; }

  const std::vector<double> &counts() const {
    return is_reverse() ? reverse : forward;
  }

  long long hits() const {
    return is_reverse() ? reverse_hits : forward_hits;
  }
};

}  // namespace barcs

#endif  // BARCS_GUIDE_INDEX_H
