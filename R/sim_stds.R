#' @include utils.R
NULL

#' Simulate standard and sample collection
#'
#' This function simulates the measurement of samples and standards based on
#' 'smpinfo' and 'stdtable' based on further arguments. It then fits a linear
#' regression through the standards (the empirical transfer function, or ETF),
#' which is then applied to the input sample values to calculate the final
#' \eqn{\Delta_{47}}{Δ[47]}-value of the sample, using inverse regression. It
#' can return all the intermediate steps to follow along, as well as a plot to
#' show how the ETF is applied.
#'
#' @param stdfreqs An integer/numeric vector with the proportion of each
#'   standard in stdtable.
#' @param stdn The total number of standard measurements to simulate.
#' @param smpn The total number of sample measurements to simulate.
#' @param stdev The standard deviation of measurements in ppm (0.001 ‰)
#' @param smpt The known temperature of the sample. Not needed in case smpinfo
#'   is provided.
#' @param input_slope The input slope of the ETF.
#' @param stdtable A [tibble][tibble::tibble-package] of standard info,
#'   generated with `make_std_table()`.
#' @param smpinfo A [tibble][tibble::tibble-package] of sample info, generated
#'   with `make_std_table()`.
#' @param out A string describing the desired output, either "none" (default),
#'   "cond", "smp", "std", "cis", "etf", "pl", or "all".
#'
#' @return Based on parameter "out", it returns either:
#' \item{none}{Nothing is returned, without warning.}
#' \item{cond}{The input conditions.}
#' \item{smp}{The full table of sample simulations.}
#' \item{std}{The full table of standard simulations.}
#' \item{cis}{The confidence intervals.}
#' \item{etf}{The empirical transfer function linear regression model.}
#' \item{pl}{The ggplot output.}
#' \item{all}{A list of the above.}
#' @export
#' @importFrom stats coef lm predict qt rnorm sd
#' @importFrom tibble tibble
#' @importFrom investr calibrate
#' @importFrom purrr safely
#' @importFrom dplyr mutate group_by summarize summarise bind_rows
#' @references Brandon M. Greenwell and Christine M. Schubert Kabban (2014)
#'   investr: An R Package for Inverse Estimation. The R Journal, 6(1), 90-100.
#'   URL http://journal.r-project.org/archive/2014-1/greenwell-kabban.pdf
#' @examples
#' library(stdsim)
#'
#' # set global output options
#' options(genplot = TRUE, verbose = TRUE)
#'
#' # generate a standard reference table
#' eth.info <- make_std_table()
#'
#' # run the simulation with the above table as input
#' sim_stds(stdfreqs = c(1, 1, 1, 1, 0), stdn = 80, smpn = 20, stdtable = eth.info)
#'
#' # more examples
#' sim_stds(c(1, 1, 1, 0, 9), smpn = 20, stdn = 300, stdtable = eth.info, smpt = 10)
#' sim_stds(stdn = 90, smpn = 10, out = "cis", stdtable = eth.info)
#' sim_stds(c(1, 1, 1, 1, 0))
#' sim_stds(c(1, 1, 9, 1, 1), smpn = 30, stdn = 100, out = "cond")
#' sim_stds(c(1, 1, 9, 0, 0), smpn = 16, stdn = 84, 50, smpt = 0, out = "cis")
#' exmp <- sim_stds(c(1, 1, 2, 1, 2), stdtable = eth.info, out = "all")
sim_stds <- function(stdfreqs = c(1, 1, 1, 1, 0),
                     stdn = 50,
                     smpn = 50,
                     stdev = 50,
                     smpt = 0,
                     input_slope = kslope,
                     stdtable = make_std_table(slope=input_slope),
                     smpinfo = make_smp_info(smpt),
                     out = "none") {
  id <- NULL
  if (is.null(getOption("verbose"))) options(verbose = TRUE)
  if (getOption("verbose")) {
    if (!requireNamespace("tictoc", quietly = TRUE))
      warning("Install package 'tictoc' for precise duration monitoring")
    else
      tictoc::tic("simulation")
  }
  pm("starting simulation")
  # parsing input
  rawstdev <- stdev * input_slope / 1e3
  nstd <- length(stdfreqs)
  n <- stdn + smpn
  if (nstd != nrow(stdtable)) {
    stop("length of stdfreqs should be equal to nstd in stdtable")
  }
  stdns <- stdfreqs / sum(stdfreqs) * stdn
  stdn <- sum(floor(stdns))

  pm("simulating sample measurements")
  cond <- list(
    stdfreqs = stdfreqs, stdn = stdn, smpn = smpn, nstd = nstd,
    n = n, stdev = stdev, stdtable = stdtable, smpinfo = smpinfo, out = out,
    # processed input:
    rawstdev = rawstdev, stdns = stdns, stdn = stdn
  )
  if (length(out) == 1 & out == "cond") {
    return(cond)
  }

  smp <- smpinfo[rep(1, smpn), ] %>% # repeat the row smpn times
    mutate(raw = rnorm(smpn, smpinfo$rawcat, rawstdev)) # generate raw

  pm("simulating standard measurements")
  pm(round(sum(stdns) - stdn), " standard measurements not simulated due to roundoff.")
  # repeat the different rownumbers of the stdtable stdns times
  numbers <- numeric(nstd)
  for (i in seq_len(nstd))
    numbers <- c(numbers, rep(i, stdns[i])) # i.e. c(1, 1, 1, 2, 2, 3, 3, 3)
  std <- stdtable[numbers, ]
  # simulate standard measurements
  std$raw <- rnorm(stdn, std$rawcat, rawstdev)
  if (length(out) == 1 & out == "std") {
    return(std)
  }

  pm("calculating empirical transfer function (ETF)")
  etf <- lm(raw ~ D47.noacid, std)
  if (length(out) == 1 & out == "etf") {
    return(etf)
  }

  ## etf_aug <- augment(etf)
  intercept <- coef(etf)[1]
  slope <- coef(etf)[2]

  pm("applying ETF to sample")
  if (is.na(slope)) {
    warning("The ETF slope could not be calculated")
    smp <- smp %>%
      mutate(D47.fromraw = (raw - intercept))
  } else {
    ## convert the y = β₀ + β₁x formula to x = (y - β₀) / β₁
    smp <- smp %>%
      mutate(D47.fromraw = (raw - intercept) / slope)
  }

  if (length(out == 1) & out == "smp") {
    return(smp)
  }

  pm("calculating summary statistics of raw values")
  cis_std <- std %>%
    group_by(id) %>%
    summarise(
      mean = mean(raw),
      lwr = ci(raw)[2], upr = ci(raw)[3],
      sd = sd(raw), cv = cv(raw)
    ) %>%
    mutate(
      dir = "raw",
      at = stdtable$D47.noacid[stdtable$id %in% std$id]
    )

  cis_smp <- smp %>%
    group_by(id) %>% # does this do anything?
    summarise(
      mean = mean(raw),
      lwr = ci(raw)[2], upr = ci(raw)[3],
      sd = sd(raw), cv = cv(raw)
    ) %>%
    mutate(dir = "raw", at = smpinfo$D47.noacid)

  pm("calculating 95% confidence intervals of regression at computed raw value in raw space")
  # uncertainty in the regression y-direction (raw) at the computed x-value
  std_ci <- predict(etf,
    newdata = data.frame(D47.noacid = mean(smp$D47.fromraw)),
    ## D47.noacid = smp$D47.fromraw),
    ## interval = "prediction")
    interval = "confidence"
  )
  # TODO: use prediction or confidence interval?
  # https://rpubs.com/aaronsc32/regression-confidence-prediction-intervals
  std_cv <- std_ci[3] - std_ci[1]
  # append to confidence intervals tibble
  cis_etf <- tibble(
    id = "etf", at = mean(smp$D47.fromraw), cv = std_cv,
    mean = std_ci[1], lwr = std_ci[2], upr = std_ci[3], dir = "raw"
  )

  pm("calculating 95% confidence intervals of sample in expected space")
  calibrate_safe <- safely(calibrate) # continue even when this fails
  cnf_smp <- calibrate_safe(etf, smp$raw,
    interval = "inversion", level = 0.95
  )
  if (is.null(cnf_smp$result)) {
    cis_acc <- tibble(
      id = "smp", mean = NA_real_,
      lwr = NA_real_, upr = NA_real_,
      cv = NA_real_,
      dir = "exp", at = cis_smp$mean
    )
  } else {
    cis_acc <- with(
      cnf_smp$result,
      tibble(
        id = "smp", mean = estimate,
        lwr = lower, upr = upper,
        cv = upper - estimate,
        dir = "exp", at = cis_smp$mean
      )
    )
  }
  # capture all the confidence intervals in one dataframe
  cis <- bind_rows(cis_std, cis_smp, cis_etf, cis_acc)
  if (length(out) == 1 & out == "cis") {
    return(cis)
  }
  if (is.null(getOption("genplot"))) options(genplot = TRUE)
  if (getOption("genplot")) {
    pm("creating plots")
    pl <- plot_sim(out=list(cond = cond, smp = smp, std = std, cis = cis, etf = etf))
    if (length(out) == 1 & out == "pl") {
      print(pl)
      return(pl)
    }
  } else {
    pl <- NULL
  }
  pm("returning output")
  if (getOption("verbose")) {
    if (requireNamespace("tictoc", quietly = TRUE))
      tictoc::toc() # simulation
  }
  switch(out,
    all = list(cond = cond, smp = smp, std = std, cis = cis, etf = etf, pl = pl),
    none = pm("No output selected"),
    return("No/Incorrect output selected")
  )
}
