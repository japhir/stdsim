#' Create reference table of standards
#'
#' Create a reference table with expected values for the standards
#'
#' @param id The names of the standards that are used in the simulations.
#' @param col The colours that these standards will have in plots.
#' @param D47_std The accepted \eqn{\Delta_{47}}{Δ[47]} values of the standards.
#' @param slope The input ETF slope.
#' @param intercept The input ETF intercept.
#' @param aff The acid fractionation factor.
#' @return A [tibble][tibble::tibble-package] of standard names (id), colours
#'   (col), \eqn{\Delta_{47}}{Δ[47]} accepted value (D47),
#'   \eqn{\Delta_{47}}{Δ47} with acid fractionation subtracted, i.e. projected
#'   to 70°C (D47.noacid), the expected raw value based on the linear
#'   regression (rawcat) and the temperature in °C (temp).
#' @importFrom tibble tibble
#' @importFrom dplyr mutate
#' @seealso make_smp_info kslope kintercept kaff
#' @export
make_std_table <- function(id = c(paste0("ETH-", 1:4), "UU1"),
                           col = c("orange", "purple", "#00B600", "blue", "#FFCD00"),
                           ## col = viridis::viridis(5),
                           # ETH accepted values from Bernasconi 2018
                           # possible UU-standard IAEA-C2 ~ 0.74?
                           # ideally as cold as possible, say 4 degrees?
                           D47_std = c(0.258, 0.256, 0.691, 0.507, tempcal(4, ignorecnf = TRUE)),
                           slope = kslope, intercept = kintercept,
                           aff = kaff) {
  D47 <- D47.noacid <- rawcat <- temp <- NULL
  tibble(id = id, col = col, D47 = D47_std) %>%
    mutate(D47.noacid = D47 - aff) %>% # subtract acid fractionation
    mutate(rawcat = D47.noacid * slope + intercept) %>% # measured values
    mutate(temp = revcal(D47, ignorecnf = TRUE)) # temperatures
}
