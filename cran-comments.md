## R CMD check results

0 errors | 0 warnings | 2 notes

* This is a new release.

* The check environment could not reach a time server, so it reports
  "unable to verify current time". This is environmental and not a property
  of the package.

## Test environments

* local macOS (arm64), R 4.3.3

## Notes for the reviewer

BARCS supersedes the regression layer of the CB2 package by the same
maintainer. It shares no code path with CB2 at run time and does not depend
on it. The guide-quantification index is derived from CB2's and produces
identical counts on well-formed input; the differences are listed in NEWS.md.

The bundled `evers_rt112` dataset repackages the raw counts of a published
screen (Evers et al. 2016, doi:10.1038/nbt.3536) that also ships with CB2,
converted to base-R types. The conversion script is in `data-raw/`, which is
excluded from the build.
