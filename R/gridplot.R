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
##' @param example_text When an example is drawn, should the the required par
##'   value, and the line parameter value be printed alongside the arrow(s)
##' @param title Character string, if not \code{NULL}, replaces default figure
##'   title.
##' @param xlim,ylim See \code{?graphics::plot}.
##' @param smooth Logical. If TRUE, a 5th order polynomial is fitted though the
##'   points constituting each line for smoothing.
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
##' PowFun <- function(n, delta, sd){
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
                    example_text = TRUE,
                    title = NULL,
                    par_labels = NULL,
                    xlim = NULL,
                    ylim = NULL,
                    smooth = FALSE)
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

  ## =================================
  ## process input
  ## =================================
  x = ArraySlicer(x, slicer)
  ## check number of function outputs, dimensionality and summarized status, and
  ## give feedback in warnings
  if (all(class(x) == 'power_array')) # made using powergrid functions
  {
    ## if there are multiple function returns saved in power_array, give a warning
    ## and take only the first, by setting slicing accordingly.
    if (attr(x, 'sim_function_nval') > 1) # still multiple outputs
    {
      ## assume the user want the first
      chosen_fun_out = attr(x, 'dimnames')$fun_out[1]
      x = ArraySlicer(x, slicer = list(fun_out = chosen_fun_out))
      warning(paste0("Argument 'x' contains multiple function outputs at each parameter combination (even after possible slicing with argument 'slicer'). \n*** Function output ",
                     chosen_fun_out,
                     " was automatically chosen to be plotted! ***\nTo explicitly choose a function output, do so using argument 'slicer', including 'fun_out = <output name> in that list."), call. = FALSE)
    }
    if(!attr(x, which = 'summarized')){ # if object contains iterations, first
                                        # summarize
      x = SummarizeIterations(x, summary_function)
      warning(paste0(
        "The object 'x' you supplied to GridPlot contains individual ",
        "iterations. For sensible plotting, these were automatically ",
        "summarized across iterations using the function given in ",
        "argument `summary_function`."), call. = FALSE)
      summarize_text = " (after summarizing)"
    } else {summarize_text = ""}
    ## Dimensionality
    if(length(dim(x)) != 3){
      stop(paste0(
        ifelse(is.null(slicer),
               paste0("'x' should be a 3-dimensional array", summarize_text,", but it is a "),
               paste("After slicing, 'x' should be a 3-dimensional array", summarize_text, ", but it is a ")),
        length(dim(x)), "-dimensional array instead."))
    }
  } else {
    stop("The object 'x' should be of class 'power_array'. ", call. = FALSE)
  } 

  ## deal with dimensions: user may enter none, one, two, or all of x-, y, and
  ## l-par. For processing, I put them in a vector and then fill the empty
  ## elements from the remaining dimnames. By default, dim 1 on y, ddim 2 on x,
  ## and dim 3 on l.
  par_vec = character(3)
  par_vec[1] = ifelse(is.null(y_par), NA, y_par)
  par_vec[2] = ifelse(is.null(x_par), NA, x_par)
  par_vec[3] = ifelse(is.null(l_par), NA, l_par)
  dim_vec = names(dimnames(x))
  par_vec[is.na(par_vec)] = dim_vec[!dim_vec %in% par_vec]
  y_par = par_vec[1]; x_par = par_vec[2]; l_par = par_vec[3]
  ##
  ## define colors
  if (is.null(col)){
    col = grDevices::grey.colors(length(dimnames(x)[[l_par]]))
  } else {
    if (length(col) != length(dimnames(x)[[l_par]])){
      stop('Length of argument col must be equal to the number of lines to be drawn, as defined by the levels of dimension `l_par` of `x` after eventual slicing.')
    }
  }
  names(col) = dimnames(x)[[l_par]]
  
  ## order dimensions of input, so that we plot the right dimensions
  ## against eachother. Correct attributes while doing so
  attributes_x = attributes(x)
  x = aperm(x, c(y_par, x_par, l_par))
  attributes_x$dimnames = attributes(x)$dimnames
  attributes_x$dim = attributes(x)$dim
  attributes(x) = attributes_x

  ## =================================
  ## Prepare graphical coordinates
  ## =================================
  ## find min or max to plot
  y_rec = FindTarget(x, target_value = target_value,# min or max required of
                                        # y_par
                     par_to_search = y_par,
                     find_lowest = find_lowest,
                     target_at_least = target_at_least,
                     method = method)
  ## if there are only NAs in y_rec, there are no lines, explain in warning:
  if (all(is.na(y_rec))){
    warning("The target value wasn't achieved at any of the parameter combinations in x. Therefore, no lines can be drawn.", call. = FALSE)
  } else {
  ## if there are some NAs in y_rec, explain what this means
    if (any(is.na(y_rec))){
      warning("At some combinations of `x_par` and `l_par`, no `y_par` was found that yielded the required target value, which may result in lines ending abruptly. In most common use cases, you may want to increasing the range of n.", call. = FALSE)
    }
  }
  ## declare line coordinate containers
  xvals = as.numeric(dimnames(x)[[x_par]])
  yvals = as.numeric(dimnames(x)[[y_par]])
  ## plotting limits
  if (is.null(xlim)){xlim = range(xvals)}
  if (is.null(ylim)){ylim = range(yvals)}
  ## =================================
  ## draw graph
  ## =================================
  ##
  at_x = pretty(xvals[xvals >= xlim[1] & xvals <= xlim[2]])
  at_y = pretty(yvals[yvals >= ylim[1] & yvals <= ylim[2]])
  plot(0,
       xlim = xlim,
       ylim = ylim,
       xlab = Trans(x_par), ylab = Trans(y_par), type = 'n', axes = FALSE)
  graphics::axis(1, at = at_x)
  graphics::axis(2, at = at_y, las = 1)
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
    graphics::lines(xs, ys, col = col[i], lwd = 2)}
  ## =================================
  ## add legend
  ## =================================
  graphics::legend('topright', box.lwd = 0, col = col, lwd = 2,
                   legend = names(col),
                   title = Trans(l_par), ncol = min(length(names(col)), 3),
                   bg = 'white', inset = .01)
  ## =================================
  ## Add example
  ## =================================
  if(!is.null(example)){
    ## multiple examples are possible
    y_ex = ArraySlicer(y_rec, example)
    usr = graphics::par()$usr
    x0 = grDevices::extendrange(usr[1:2], f = -.02)[1]
    y0 = grDevices::extendrange(usr[3:4], f = -.02)[1]
    arrow_col = col[as.character(example[[l_par]])] # each arrow gets color of
                                        # the relevant line
    graphics::segments(example[[x_par]], y0, example[[x_par]], y_ex, col = arrow_col)
    graphics::arrows(example[[x_par]], y_ex, x0, y_ex, length = .15, col = arrow_col)
    if (example_text){
      graphics::text(x = x0, y = y_ex,
                     labels = paste(y_ex, 'at', Trans(l_par), '=', example[[l_par]]),
                     adj = c(0, -1), col = arrow_col)
    }
  }
  if(is.null(title)){
    title = paste0(ifelse(find_lowest, 'Minimum ', 'Maximum '),
                   Trans(y_par),
                   ' for a Power of ',
                   target_value, '')}
  graphics::title(title)
  invisible(list('at_x' = at_x,
                 'at_y' = at_y,
                 'line_colors' = col))
}

