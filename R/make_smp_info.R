#' Create a tibble with sample information.
#'
#' Create a reference table with expected values for the sample of interest.
#'
#' @param smpt The temperature from which to calculate \eqn{\Delta_{47}}{Δ[47]}
#'   values.
#' @param slope The input ETF slope.
#' @param intercept The input ETF intercept.
#' @param aff The acid fractionation factor.
#' @return A [tibble][tibble::tibble-package] of the sample name (id), colour
#'   (col), \eqn{\Delta_{47}}{Δ[47]} accepted value (D47),
#'   \eqn{\Delta_{47}}{Δ[47]} with acid fractionation subtracted, i.e.
#'   projected to 70°C (D47.noacid), the expected raw value based on the linear
#'   regression (rawcat) and the temperature in °C (temp).
#' @seealso make_std_info kslope kintercept kaff
#' @importFrom tibble tibble
#' @importFrom dplyr mutate
#' @export
make_smp_info <- function(smpt = 0, slope = kslope, intercept = kintercept,
                          aff = kaff) {
  D47 <- D47.noacid <- rawcat <- temp <- NULL
  tibble(id = "sample", col = "black", D47 = tempcal(smpt, ignorecnf = TRUE)) %>%
    mutate(D47.noacid = D47 - aff) %>% # acid fractionation
    mutate(rawcat = D47.noacid * slope + intercept) %>% # apply etf
    mutate(temp = revcal(D47, ignorecnf = TRUE)) # calculate temperatures from Δ47 values
}
