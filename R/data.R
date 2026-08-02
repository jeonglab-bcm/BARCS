#' CRISPRn dropout screen in RT112 bladder cancer cells
#'
#' A small pooled CRISPR knockout screen comparing guide abundance before and
#' after selection, together with the reference gene sets the original study
#' used to judge a method's ranking. Its 961 guides and six libraries make it
#' fast enough for examples while still having a real dispersion structure.
#'
#' The screen has three libraries per group, so a two-group fit leaves four
#' residual degrees of freedom. That is a realistic amount of replication for
#' a published screen and a useful reminder that read depth, which is in the
#' tens of thousands per guide here, does not add any.
#'
#' @format A list with five elements:
#' \describe{
#'   \item{counts}{Integer matrix of 961 guides by 6 libraries. Row names are
#'     guide identifiers, column names are sample names.}
#'   \item{design}{Data frame with one row per library, in the column order of
#'     `counts`: `sample_name` and the two-level factor `group`, whose
#'     reference level is `"before"`.}
#'   \item{guides}{Data frame mapping each `guide` to its target `gene`.}
#'   \item{essential}{Character vector of 46 reference essential genes, which
#'     a working analysis should deplete.}
#'   \item{nonessential}{Character vector of 47 reference non-essential genes,
#'     which should not move.}
#' }
#'
#' @source Evers B, Jastrzebski K, Heijmans JPM, Grernrum W, Beijersbergen RL,
#'   Bernards R (2016). CRISPR knockout screening outperforms shRNA and
#'   CRISPRi in identifying essential genes. *Nature Biotechnology*, 34(6),
#'   631-633. \doi{10.1038/nbt.3536}
#'
#'   Repackaged from the `Evers_CRISPRn_RT112` object in the CB2 package; see
#'   `data-raw/evers_rt112.R` in the package sources for the conversion.
#'
#' @examples
#' data(evers_rt112)
#' str(evers_rt112$counts)
#' evers_rt112$design
#'
#' # Library sizes are the beta-binomial denominator.
#' colSums(evers_rt112$counts)
"evers_rt112"
