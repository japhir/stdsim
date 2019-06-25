#' Plot output of single simulation
#'
#' This function plots the simulation's output using ggplot2.
#'
#' @param out The output list of `sim_stds()` with `out="all"` specified.
#' @param input_etf Logical. Plot input ETF line.
#' @param input_pointrange Logical. Plot input pointrange with SD.
#' @param graylines Logical. Plot gray lines at input Raw and output accepted
#'   values.
#' @param violin Logical. Plot violins for sample and standard distributions.
#' @param point Logical. Plot simulation points.
#' @param point_alpha The alpha value of the points.
#' @param pointrange Logical. Plot the pointrange of the simulations.
#' @param labs Logical. Plot labels with [ggrepel][ggrepel::ggrepel-package].
#' @param fixed Logical. Fix coordinates.
#' @param idscale Logical. Set the scale and fill scales.
#' @param axlabs Logical. Set the axis labels.
#'
#' @return A ggplot object.
#'
#' @import ggplot2
#' @importFrom dplyr filter
#' @export
plot_sim <- function(out, input_etf=TRUE, input_pointrange=FALSE,
                     graylines=TRUE, violin=TRUE, point=TRUE, point_alpha=.5, pointrange=TRUE,
                     labs=TRUE, fixed=TRUE, idscale=TRUE, axlabs=TRUE) {
  D47.noacid <- rawcat <- id <- stdev <- D47.fromraw <- at <- lwr <- upr <- NULL
  pl <-  with(out, bind_rows(smp, std)) %>%
    ggplot(aes(x = D47.noacid, y = rawcat, col = id, fill=id))
  if (input_etf) {
    pl <- pl + geom_abline(intercept = kintercept, slope = kslope,
                           linetype = 2, col = "red")
  }
  if (input_pointrange) {
    pl <- pl + geom_pointrange(aes(ymin = rawcat - stdev / 1e3, ymax = rawcat + stdev / 1e3),
                               linetype = 2, alpha = .2, show.legend = FALSE)

  }
  ## add the calculated ETF
  pl <- pl +
    geom_smooth(aes(group = 1, y = raw),
                colour = "steelblue", method = "lm",
                data = out$std, fullrange = TRUE)
  if (graylines) {
    pl <- pl +
      ## add segment for mean sample
      geom_segment(aes(x = -Inf, xend = mean(D47.fromraw), y = mean(raw),
                       yend = mean(raw)),
                   data = out$smp, col = "gray", alpha = .2) +
      geom_segment(aes(x = mean(D47.fromraw), xend = mean(D47.fromraw),
                       y = mean(raw), yend = -Inf),
                   data = out$smp, col = "gray", alpha = .2)
  }
  # add the raw sample and standard measurements
  if (violin) {
    pl <- pl +
      geom_violin(aes(y = raw), col=NA, scale = "count", width = .1,
                  alpha = .5, position = position_identity())
  }
  if (point) {
    pl <- pl +
      geom_point(aes(x = D47.noacid, y = raw), shape = 1, alpha=point_alpha)
  }

  if (pointrange) {
    pl <- pl +
      ## the 95% CI for the raw values of the samples
      geom_pointrange(aes(x = at, y = mean, ymin = lwr, ymax = upr, col = id), # to omit blue vertical bar, , id != "etf"
                      data = out$cis %>% filter(dir == "raw"),
                      alpha=.6) +
      ## compared to the 95% confidence interval of the regression at this point
      ## add the converted average and 95% CI in the x-axis direction
      geom_point(aes(x = mean, y = at), data = out$cis %>% filter(dir == "exp"),
                 colour = "black") + #,
                 ## size = 3) +
      geom_errorbarh(aes(x = NULL, y = at, xmin = lwr, xmax = upr),
                     data = out$cis %>% filter(dir == "exp"), colour = "black",
                     height = 0)
                     ## size = 1.4)
  }
  ## don't use a legend but floating labels
  if (labs) {
    if (!requireNamespace("ggrepel", quietly = TRUE))
      warning("Install package 'ggrepel' for nice label positioning")
    else {
      pl <- pl +
        theme(legend.position = "none") +
        ggrepel::geom_text_repel(aes(label = id),
                                 force = 3,
                                 ## nudge_x = -.06,
                                 nudge_x = 0,
                                 nudge_y = .05,
                                 segment.colour = NA,
                                 data=with(out$cond, bind_rows(stdtable, smpinfo)))
    }
  }
  # set colour scales and axis labels
  if (fixed) {
    pl <- pl +
      coord_fixed()
  }

  if (idscale) {
    pl <- pl +
      scale_colour_manual("ID",
                          limits = c(out$cond$stdtable$id, out$cond$smpinfo$id),
                          values = c(out$cond$stdtable$col, out$cond$smpinfo$col)) +
      scale_fill_manual("ID",
                        limits = c(out$cond$stdtable$id, out$cond$smpinfo$id),
                        values = c(out$cond$stdtable$col, out$cond$smpinfo$col))
  }
  ## nice axis labeout
  if (axlabs) {
    pl <- pl +
      labs(colour = "ID", x = Delta[47] ~ "CDES" - "AFF (\u2030)",
           y = Delta[47] ~ raw ~ "(\u2030)")
  }

  # return plot
  pl
}
