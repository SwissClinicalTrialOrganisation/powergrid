##' @title Plot requirements for achieving a target power as a function of
##'   assumptions about two parameters
##' @description Plots how the required sample size (or any other parameter) to
##'   achieve a certain power (or other objective) depends on two furhter
##'   parameters.
##' @details In the most typical use case, the y-axis shows the *minimal* sample
##'   size required to achieve a power of *at least* \code{target_value},
##'   assuming the value of a parameter on the x-axis, and the value of another
##'   parameter represented by each line.
##'
##' The use of this function is, however, not limited to finding a minimum n to
##' achieve at least a certain power. See help of `Example` to understand the
##' use of `target_at_least` and `fin_min`.
##'
##' If the input to argument x (class `power_array`) contains iterations that
##' are not summarized, it will be summarized by `summary_function` with default
##' `mean`.
##'
##' Note that a line may stop in a corner of the plotting region, not reaching
##' the margin. This is often correct behavior, when the \code{target_value}
##' level is not reached anywhere in that corner of the parameter range. In case
##' n is on the y-axis, this may easily be solved by adding larger sample sizes
##' to the grid (consider \code{Update}), and then adjusting the y-limit to only
##' include the values of interest.
##'
##'   ### Graphical parameters
##'   Graphical parameters that are allowed as input to the functions
##'   `graphics::plot`, `graphics::lines`, `graphics::image` and `graphics::axis`,
##'   including all parametes available in par() are passed on to these functions
##'   internally. Not passed through are "x", "y", "z", "type", "at", and
##'   parameters that are explict arguments to `GridPlot`.
##'
##' @param x An object of class "power_array" (from `powergrid`).
##' @param slicer If the parameter grid of `x` has more than 3 dimensions, a
##'   3-dimensional slice must be cut out using \code{slicer}, a list whose
##'   elements define at which values (the list element value) of which
##'   parameter (the list element name) the slice should be cut.
##' @param y_par Which parameter is searched for the minimum (or maximum if
##'   find_lowest == FALSE) yielding the target value; and shown on the
##'   y-axis. If NULL, \code{y_par} is set to the first, \code{x_par} to the
##'   second, and \code{l_par} to the third dimension name of 3-dimensional
##'   array \code{x}. If you want another than the first dimension as `y_par`,
##'   you need to see `y_par`, `x_par`, and `l_par` explicitly.
##' @param x_par,l_par Which parameter is varied on the x-axis, and between
##'   lines, respectively. If none of `y_par`, `x_par` and `l_par` are given,
##'   the first, second, and third dimension of x are mapped to y_par, x_par,
##'   and l_par, respectively.
##' @param par_labels Named vector where elements names represent the parameters
##'   that are plotted, and the values set the desired labels.
##' @param example A list defining for which combination of levels of
##'   \code{l_par} and \code{x_par} an example arrow should be drawn. List
##'   element names indicate the parameter, element value indicate the values at
##'   which the example is drawn.
##' @param target_value The target power (or any other value stored in x) that
##'   should be matched.
##' @param method The method to find the required parameter values, see
##'   \code{Example} and \code{FindTarget}.
##' @param target_at_least Logical. Should \code{target_value} be minimally
##'   achieved (e.g., power), or maximially allowed (e.g., estimation
##'   uncertainty).
##' @param find_lowest Logical, indicating whether the example should be found
##'   that minimizes an assumption (e.g., minimal required n) to achieve the
##'   \code{target_value} or an example that maximizes this assumption (e.g.,
##'   maximally allowed SD).
##' @param summary_function If \code{x} is an object of class \code{power_array}
##'   where attribute \code{summarized} is FALSE (indicating individual
##'   iterations are stored in dimension \code{iter}, the iterations dimension
##'   is aggregated by \code{summary_fun}. Otherwise ignored.
##' @param col A vector with the length of \code{l_par} defining the color(s) of
##'   the lines.
##' @param lty A vector of length one or the length of \code{l_par}, defining
##'   the type of lines to be drawn.
##' @param example_text When an example is drawn, should the the required par
##'   value, and the line parameter value be printed alongside the arrow(s).
##' @param title Character string, if not \code{NULL}, replaces default figure
##'   title. Replaces `main`if specifiec by `...` .
##' @param axes Logical defining whether or not axes are drawn.
##' @param xlim,ylim See \code{?graphics::plot}.
##' @param add_legend Should the legend be automatically generated (`default =
##'   TRUE`), set to FALSE and add afterwards for more flexibility.
##' @param smooth Logical. If TRUE, a 5th order polynomial is fitted though the
##'   points constituting each line for smoothing.
##' @param ... Further arguments to \code{\link{par}}, \code{\link{plot}},
##'   \code{\link{axis}} and \code{\link{lines}}. A few exceptions (e.g. `y`)
##'   are ignored with a warning.
##' @seealso \code{\link{PowerGrid}}, \code{\link{AddExample}},
##'   \code{\link{Example}}, \code{\link{PowerPlot}} for similar plotting of
##'   just 2 parameters, at multiple power (target value) levels.
##' @return A list with graphical information to use in further plotting.
##' @author Gilles Dutilh
##' @examples
## ============================================
## Typical use case: minimal n for power
## ============================================
##' sse_pars = list(
##'   n = seq(from = 2, to = 100, by = 2),
##'   delta = seq(from = 0.1, to = 1.5, by = 0.05), ## effect size
##'   sd = seq(.1, .9, .1)) ## Standard deviation
##' PowFun = function(n, delta, sd){
##'   ptt = power.t.test(n = n/2, delta = delta, sd = sd,
##'                      sig.level = 0.05)
##'   return(ptt$power)
##' }
##' power_array = PowerGrid(pars = sse_pars, fun = PowFun, n_iter = NA)
##' GridPlot(power_array, target_value = .8)
##' ## If that's too many lines, cut out a desired number of slices
##' GridPlot(power_array,
##'          slicer = list(sd = seq(.1, .9, .2)),
##'          target_value = .8)
##'
##' ## adjust labels, add example
##' GridPlot(power_array, target_value = .9,
##'          slicer = list(sd = seq(.1, .9, .2)),
##'          y_par = 'n',
##'          x_par = 'delta',
##'          l_par = 'sd',
##'          par_labels = c('n' = 'Sample Size',
##'                         'delta' = 'Arm Difference',
##'                         'sd' = 'Standard Deviation'),
##'          example = list(sd = .7, delta = .6))
##' ## add additional examples useing AddExample. Note that these do not contain
##' ## info about the line they refer to.
##' AddExample(power_array,
##'          target_value = .9,
##'          example = list(delta = c(.5, .8), sd = c(.3, .7)),
##'          col = 3
##'          )
##'
##'
##' ## Above, GridPlot used the default: The first dimension is what you search
##' ## (often n), the 2nd and 3rd define the grid of parameters at which the
##' #search # is done. Setting this explicitly, with x, y, and l-par, it looks
##' #like:
##' GridPlot(power_array, target_value = .8,
##'          slicer = list(sd = seq(.1, .9, .2)),
##'          y_par = 'n', # search the smallest n where target value is achieved
##'          x_par = 'delta',
##'          l_par = 'sd')
##'
##' ## You may also want to have different parameters on lines and axes:
##' GridPlot(power_array, target_value = .8,
##'          y_par = 'delta', # search the smallest delta where target value is achieved
##'          x_par = 'sd',
##'          l_par = 'n')
##' ## Too many lines! Take some slices again:
##' GridPlot(power_array, target_value = .9,
##'          slicer = list(n = c(seq(10, 70, 10))),
##'          y_par = 'delta',
##'          x_par = 'sd',
##'          l_par = 'n', method = 'step')
##' @export
GridPlot = function(x,
                    slicer = NULL,
                    y_par = NULL,
                    x_par = NULL,
                    l_par = NULL,
                    example = NULL,
                    find_lowest = TRUE,
                    target_value = .9,
                    target_at_least = TRUE,
                    method = 'step',
                    summary_function = mean,
                    col = NULL,
                    lty = 1,
                    example_text = TRUE,
                    title = NULL,
                    axes = TRUE,
                    par_labels = NULL,
                    add_legend = TRUE,
                    xlim = NULL,
                    ylim = NULL,
                    smooth = FALSE,
                    ...)
{
  ## translator for labels; translates if label is available
  Trans = function(x){
    if(!is.null(par_labels)){
      for(i in seq_along(x)){
        if(x[i] %in% names(par_labels)){x[i] = par_labels[x[i]]}
      }
    }
    return(x)
  }

  ## =======================================================
  ## process power array
  ## =======================================================
  if (!inherits(x, "power_array")) stop("The object 'x' should be of class 'power_array'. ", call. = FALSE)

  x = EnsureSummarized(x, summary_function = substitute(summary_function))

  ## =======================================================
  ## take slice that should be plotted
  ## =======================================================
  ## TODO: this if structure is not needed as ArraySlicer seems to
  ## return a unchanged array if slicer = NULL, incidental behaviour though
  ## So best to keep this in (or change array slicer).
  if(!is.null(slicer)){
    sliced_x = ArraySlicer(x = x, slicer = slicer)
  } else {sliced_x = x}

  sliced_x = EnsureSingleFunOut(sliced_x, sliced = TRUE)

  CheckArrayDim(sliced_x, required_dim = 3)

  ## deal with dimensions: user may enter none, one, two, or all of x-, y, and
  ## l-par. For processing, I put them in a vector and then fill the empty
  ## elements from the remaining dimnames. By default, dim 1 on y, ddim 2 on x,
  ## and dim 3 on l.
  par_vec = character(3)
  par_vec[1] = ifelse(is.null(y_par), NA, y_par)
  par_vec[2] = ifelse(is.null(x_par), NA, x_par)
  par_vec[3] = ifelse(is.null(l_par), NA, l_par)
  dim_vec = names(dimnames(sliced_x))
  par_vec[is.na(par_vec)] = dim_vec[!dim_vec %in% par_vec]
  y_par = par_vec[1]; x_par = par_vec[2]; l_par = par_vec[3]
  ##
  ## define colors
  if (is.null(col)){
    col = grDevices::grey.colors(length(dimnames(sliced_x)[[l_par]]))
  } else {
    if (length(col) != length(dimnames(sliced_x)[[l_par]])){
      stop('Length of argument col must be equal to the number of lines to be drawn, as defined by the levels of dimension `l_par` of `x` after eventual slicing.')
    }
  }
  ## define ltys
  if (length(lty) == 1){
    lty = rep(lty, length(dimnames(sliced_x)[[l_par]]))
  } else if (length(lty) != length(dimnames(sliced_x)[[l_par]])) {
    stop('Length of argument lty must be equal to one or the number of lines to be drawn, as defined by the levels of dimension `l_par` of `x` after eventual slicing.')
  }
    
  names(col) = names(lty) = dimnames(sliced_x)[[l_par]]
  
  ## order dimensions of input, so that we plot the right dimensions
  ## against each other. Correct attributes while doing so
  attributes_x = attributes(sliced_x)
  sliced_x = aperm(sliced_x, c(y_par, x_par, l_par))
  attributes_x$dimnames = attributes(sliced_x)$dimnames
  attributes_x$dim = attributes(sliced_x)$dim
  attributes(sliced_x) = attributes_x

  ## =======================================================
  ## User graphical arguments
  ## =======================================================
  ## Allow flexible parameter specification via ellipsis
  dots = list(...)

  good_args = c(names(graphics::par()),
                names(formals(graphics::axis)),
                names(formals(graphics::plot.default)),
                names(formals(graphics::lines))
  )
  good_args = setdiff(good_args, "...")

  bad_args = setdiff(names(dots), good_args)
  if (length(bad_args) > 0) {
    warning("Only arguments to par(), axis() plot.default() and lines() can be supplied through `...` the following are ignored: ",
            paste(bad_args, collapse = ", "), call. = FALSE)
    dots[bad_args] = NULL
  }

  ## do not allow dots to override core internals
  exeption_bad_args = intersect(names(dots), c("y", "z", "type", "at"))
  if (length(exeption_bad_args) > 0) {
    warning("These arguments cannot be supplied through `...` and are ignored: ",
            paste(exeption_bad_args, collapse = ", "), call. = FALSE)
    dots[exeption_bad_args] = NULL
  }

  ## Only let lty affect certain plot characteristics, so remove from dots
  user_lty = if ("lty" %in% names(dots)) dots$lty else NULL
  dots$lty = NULL

  ## Set the labels, to user specified or using Trans()
  dots$xlab = if ("xlab" %in% names(dots)) dots$xlab else Trans(x_par)
  dots$ylab = if ("ylab" %in% names(dots)) dots$ylab else Trans(y_par)

  ## Get the plot title priority is title arg > main arg > internal
  if ("main" %in% names(dots)) {
    if (is.null(title)) title = dots$main
    dots$main = NULL
  }
  if(is.null(title)){
    title = paste0(ifelse(find_lowest, 'Minimum ', 'Maximum '),
                   Trans(y_par),
                   ' for a Power of ',
                   target_value, '')}

  ## Make lists of all the dots arguments to be passed to each function.
  par_dots = dots[intersect(names(dots),names(graphics::par()))]
  plot_dots = dots[intersect(names(dots), c(names(graphics::par()),
                                            names(formals(graphics::plot.default))))]
  axis_dots = dots[intersect(names(dots), c(names(graphics::par()),
                                            names(formals(graphics::axis))))]
  lines_dots = dots[intersect(names(dots), c(names(graphics::par()),
                                             names(formals(graphics::lines))))]
  ## The arguments to legend are a bit of a mix, so just take the basic ones.
  legend_dots = dots[intersect(names(dots), c("lwd", "lty", "cex"))]

  ## Only the legend and the lines get the specified lty
  lines_dots$lty = legend_dots$lty = user_lty



  ## =================================
  ## Prepare graph coordinates
  ## =================================
  ## find min or max to plot
  y_rec = FindTarget(sliced_x, target_value = target_value,# min or max required of
                     # y_par
                     par_to_search = y_par,
                     find_lowest = find_lowest,
                     target_at_least = target_at_least,
                     method = method)

  ## if there are only NAs in y_rec, there are no lines, explain in warning:
  if (all(is.na(y_rec))){
    warning("The target value wasn't achieved at any of the parameter combinations",
            " in x. Therefore, no lines can be drawn.", call. = FALSE)
  } else {
    ## if there are some NAs in y_rec, explain what this means
    if (any(is.na(y_rec))){
      warning("At some combinations of `x_par` and `l_par`, no `y_par` was found",
              " that yielded the required target value, which may result in lines",
              " ending abruptly. In most common use cases, you may want to ",
              "increasing the range of n.", call. = FALSE)
    }
  }
  ## declare line coordinate containers
  xvals = as.numeric(dimnames(sliced_x)[[x_par]])
  yvals = as.numeric(dimnames(sliced_x)[[y_par]])
  ## plotting limits
  if (is.null(xlim)){xlim = range(xvals)}
  if (is.null(ylim)){ylim = range(yvals)}

  ## =================================
  ## draw graph
  ## =================================
  ##
  at_x = pretty(xvals[xvals >= xlim[1] & xvals <= xlim[2]])
  at_y = pretty(yvals[yvals >= ylim[1] & yvals <= ylim[2]])
  do.call(plot, args=append(list(x=0, xlim = xlim, ylim = ylim,
                                 type = 'n', axes = FALSE), plot_dots))

  do.call(graphics::box, par_dots)
  if (axes){
    do.call(graphics::axis, args= append(list(side=1, at = at_x), axis_dots))
    do.call(graphics::axis, args= append(list(side=2, at = at_y), axis_dots))
  }

  ## Gridlines are unchanged by par arguments
  graphics::abline(v = at_x,
                   h = at_y,
                   col = grDevices::grey.colors(1, .95, .95))

  for(i in 1:ncol(y_rec)){
    ys = y_rec[, i]
    xs = as.numeric(dimnames(y_rec)[[x_par]])
    if(smooth){
      plm = stats::lm(ys ~ xs + I(xs^2) + I(xs^3) + I(xs^4) + I(xs^5))
      ys = stats::predict(plm, newdata = data.frame(xs))
    }
    do.call(graphics::lines, args = append(list(x=xs, y=ys, col = col[i],
                                                lty = lty[i]), lines_dots))
  }

  ## =================================
  ## add legend
  ## =================================
  if(add_legend) {
    do.call(graphics::legend, append(
      list(x='topright', box.lwd = 0, col = col, lty = lty,
           legend = names(col), title = Trans(l_par),
           ncol = min(length(names(col)), 3),
           bg = 'white', inset = .01),
      legend_dots))
  }
  ## =================================
  ## Add example
  ## =================================
  if(!is.null(example)){

    example_strata = as.character(example[[names(dimnames(sliced_x))[3]]])
    subset_col = col[match(example_strata, dimnames(sliced_x)[[3]])]

    do.call(AddExample, append(list(x = sliced_x,
                                    example = example,
                                    target_value = target_value,
                                    find_lowest = find_lowest,
                                    target_at_least = target_at_least,
                                    col = subset_col,
                                    example_text = example_text),
                               dots))
  }
  graphics::title(title)
  invisible(list('at_x' = at_x,
                 'at_y' = at_y,
                 'line_colors' = col))
}
