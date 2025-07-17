##' Function developed for internal use in powergrid::Example. Search
##' 2-dimensional slice of a power_array object, for a value of at least (or at
##' most) a chosen value, searching along one dimension of the slice in a chosen
##' direction, per level of the other dimension. Typically, one searches for a
##' power of at least x% along increasing sample size, thus finding the minimal
##' n for achieving a power of x, per level of another parameter, e.g., effect
##' size.
##'
##' By default, the power_slice is searched along the dimension n
##' (\code{search_par}), searching for the lowest value (\code{find_min} = TRUE)
##' where the array contains a value of at least (\code{minimal_target} = TRUE)
##' .9 (the \code{target}), thus finding the minimal sample size required to
##' achieve a power of 90%. These arguments may seem a bit confusing at first,
##' but they allow for three additional purposes:
##'
##' First, the implementation also allows to search for a value that is *at
##' most* the \code{target}, by setting \code{minimal_target} to FALSE. This may
##' be used, for example, when the aim is to find a sample size yielding a
##' confidence interval that is not bigger than some maximum width.
##'
##' Second, the implementation allows to search along another *named* dimension
##' of the power_slice than n.
##'
##' Third, the implementation allows to search for a certain target to be
##' achieved by maximizing (find_minimum = FALSE) the parameter on the searched
##' dimension. This may be used, for example, when the aim is to find the
##' maximum standard deviation at which a study's power is still acceptable.
##'
##' \code{FindTarget} may most often be implicitly called inside \code{Example},
##' \code{plot} or \code{PowerLinesPlot}.
##'
##' @title Find Target Power or Other Value
##' @param power_slice A 2- or 1- dimensional array, most commonly the result of
##'   taking a slice of an object of class \code{power_array} using
##'   \code{array_slicer}.
##' @param target The required size of the value in the power_slice
##' @param minimal_target Is the target a minimum (e.g., for power) or a maximum
##'   (e.g., the size of a confidence interval)
##' @param search_par Which parameter should be searched to achieve the required
##'   target. In the standard SSE case, this is n.
##' @param find_min Should the lowest value of search_par be found that yields a
##'   value that meets the target. For n, one searches the lowest, but for,
##'   e.g. the variance, one would search for the maximum where the target can
##'   still be achieved.
##' @param method How is the required \code{search_par} to achieve \code{target}
##'   found. Either \code{'step'}: walking in steps along \code{search_par} or
##'   \code{'lm'}: Interpolating assuming a linear relation between
##'   \code{search_par} and \code{(qnorm(x) + qnorm(1 - 0.05)) ^ 2}. Setting
##'   'lm' is inspired on the implementation in the sse package by Thomas
##'   Fabbro.
##' @return Returns the lowest (or highest if \code{find_min} == FALSE) value of
##'   \code{search_par} for which the value in \code{power_slice} is at minimum
##'   (or maximum if \code{minimal_target} == FALSE) of value \code{target}. If
##'   \code{method} == 'lm', interpolation through transformation is used.
##' @author Gilles Dutilh
##' @examples
##' ## ============================================
##' ## most basic case, power function available:
##' ## ============================================
##' sse_pars = list(
##'     n = seq(from = 10, to = 60, by = 2),
##'     delta = seq(from = 0.5, to = 1.5, by = 0.2), ## effect size
##'     sd = seq(.1, .9, .2)) ## Standard deviation
##' PowFun <- function(n, delta, sd){
##'   ptt = power.t.test(n = n/2, delta = delta, sd = sd,
##'                      sig.level = 0.05)
##'   return(ptt$power)
##' }
##' power_array = PowerGrid(pars = sse_pars, fun = PowFun, n_iter = NA)
##' ex_out = Example(power_array,
##'                  example = list(delta = .7, sd = .7),
##'                  target = .9)
##' ex_out
##' @export
FindTarget = function(power_slice,
                      target = .9,
                      minimal_target = TRUE,
                      search_par = 'n',
                      find_min = TRUE,
                      method = 'step'
                      ) {
  ## If simply finding the first step where the target is achieved:
  ## (note very pragmatic use of environmental variables)
  if (method == 'step') {
    Find = function(x) {
      search_par_grid = names(x)
      if(!find_min) {
        x = rev(x)
        search_par_grid = rev(search_par_grid)
      }
      if (minimal_target) {
        first_hit_index = match(TRUE, x >= target)
      } else {
        first_hit_index = match(TRUE, x <= target)
      }
      return(as.numeric(search_par_grid[first_hit_index]))
    }
  }
  if (method == 'lm') {
    ## Implementation of fabbrot's interpolation through
    ## transformation trick.
    if(!minimal_target | !find_min) {
      stop("Currently the lm method only supports defaults for minimal_target and find_min")
    }
    SSETrans <- function(x) {
      ## older versions: 0.5 * log((1 + x) / (1 - x)) # <== this line is
      ## a literal copy of the comment fabbrot in sse
      (stats::qnorm(x) + stats::qnorm(1 - 0.05)) ^ 2
    }
    Find = function(x) {
      pred_n = as.numeric(names(x))
      trans_pow = SSETrans(x)
      lm_out = stats::lm(pred_n[!is.infinite(trans_pow)] ~
                           trans_pow[!is.infinite(trans_pow)])
      lm_pred = stats::predict(lm_out,
                                       newdata = data.frame(
                                         trans_pow = SSETrans(target)))
      if(lm_pred %% 1 != 1) warning(paste("The output with method = 'lm' is rounded up, this makes sense for n but may not for parameters"))
      lm_pred = ceiling(lm_pred)
      return(lm_pred)
    }
  }
  ## Below functions rather funnily, maybe, I need to do some explicit argument
  ## naming...
  if(length(dim(power_slice)) %in% c(1, 0) ){ # if a one-dim array, or a vector
    Find(power_slice)
  } else { # is multidim array, you must say which parameter you want to search
           # across
    apply(power_slice,
          names(dimnames(power_slice))[
            names(dimnames(power_slice)) != search_par],
          Find)
  }
}
