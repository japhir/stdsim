#' Progress message
#'
#' Display a progress message if `verbose` is specified
#'
#' @keywords internal
#' @param ... The message options
pm <- function(...) {
  if (is.null(getOption("verbose"))) {
    options(verbose = TRUE)
  } else if (getOption("verbose")) {
    message(...)
  }
}

#' Confidence value.
#'
#' Calculate the t-distribution confidence value of a vector.
#'
##' @param x A numeric vector.
##' @param alpha The alpha value for the confidence level.
##' @param ignore_df0 Ignore warnings if the degrees of freedom are 0.
cv <- function(x, alpha = 0.05, ignore_df0 = TRUE) {
  if ((!ignore_df0) && length(x) - 1 <= 0) {
    stop("cannot calculate confidence value, only one observation")
  } else {
    ## We already decide on whether or not to stop when df = 0.
    suppressWarnings(
      qt(1 - alpha / 2, df = length(x) - 1) *
        sd(x) / sqrt(length(x))
    )
  }
}

#' Confidence interval.
#'
#' Calculate the confidence interval of a vector.
#'
##' @param x A numeric vector.
##' @param alpha The alpha value for the confidence level.
##' @param ignore_df0 Ignore warnings if the degrees of freedom are 0.
ci <- function(x, alpha = 0.05, ignore_df0 = TRUE) {
  xbar <- mean(x)
  xcv <- cv(x, alpha, ignore_df0)
  c(fit = xbar, lwr = xbar - xcv, upr = xbar + xcv)
}
