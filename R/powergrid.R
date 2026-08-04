## Aim:
##
## - take a list of parameters apply function to grid of parameters form usable
## - output in form of an array (may be converted to grid)

##' PowerGrid is an apply-like function, allowing to evaluate a function at the
##' crossings of a set of parameters. The result is saved in an array with
##' attributes that optimize further usage by functions in package
##' \code{powergrid}. In particular, performing a function iteratively (using
##' parallel computing if required) is implemented conveniently. The typical use
##' is for evaluating statistical power at a grid of assumed parameters.
##'
##' Function \code{fun} is evaluated at each combination of the argument values
##' listed in \code{pars} and its results are stored in an array of class
##' `power_array`, whose dimensions (and \code{dimnames()}) are defined by
##' \code{pars}. For this to work, the element names of \code{pars} must match
##' the argument names of \code{fun}.
##'
##'
##' ## Further arguments to \code{fun}
##'
##' If input parameters to \code{fun} are not
##' to be part of the grid, but rather further settings, these can be passed on
##' to \code{fun} through the argument \code{more_args} as a list with names
##' reflecting the arguments of \code{fun} to be set.
##'
##' ## Storing multiple outputs from \code{fun}
##'
##' You may have a function \code{fun} that returns a vector with length larger
##' than one, as long as it is a single vector. When \code{fun} returns a vector
##' with length larger than one, the power_array will have an additional
##' dimension `fun_out`, with levels named after the names of \code{fun}'s
##' return vector (if given).
##'
##' ## Non-numeric parameters
##'
##' You may want to study the effect of non-numeric parameters. This option is
##' not supported for the argument `pars`, since the essential powergrid
##' functions \code{\link{Example}}, \code{\link{PowerPlot}}, and
##' \code{\link{GridPlot}} need a direction to search. Nonetheless, you can study
##' non-numeric parameters by having function `fun` returning multiple values,
##' as described above.
##'
##' ## Evaluating a function over iterations
##'
##' If \code{n_iter} is not NA (the default) but an integer, function \code{fun}
##' is evaluated n_iter times. This will add an additional dimension 'iter' to
##' the resulting array of class `power_array`. If your simulation is heavy, you
##' may wanna set \code{parallel = TRUE} and choose the \code{n_cores}, invoking
##' parallel computing using t\code{future::future_replicate}.
##'
##' You may summarize the object with individual iterations across these
##' iterations using function \code{\link{SummarizeIterations}}. Note that both
##' summarized and non-summarized output of \code{PowerGrid} have class
##' `power_array`. The summary status is saved in the attributes. This allows
##' the `powergrid` utilities \code{\link{Example}}, \code{\link{PowerPlot}},
##' and \code{\link{GridPlot}} to do something sensible also with non-summarized
##' objects.
##'
##' ## Reproducibility
##'
##' The current status of .Random.seed is stored in the attribute `random_seed`
##' (which is a list). To reproduce a call of PowerGrid involving randomness,
##' precede new call to PowerGrid by \code{.Random.seed = attr(<your_power_array>,
##' which = 'random.seed')[[1]]}. Note that if you Refine() your power_array, the
##' .Random.seed at the moment of updating is appended to the random.seed
##' attribute. So, to reconstruct a refined power_array, run the original call
##' to `PowerGrid` after \code{.Random.seed = attr(<your_power_array>, which =
##' 'random.seed')[[1]]}, and the the call to Refine after \code{.Random_seed =
##' attr(<your_power_array>, which = 'random.seed')[[2]]}, etc.
##'
##' ## Progress bar
##'
##' By default PowerGrid does not report progress. To return the optional
##' progress bar (`progress_bar = TRUE`), the `progressr` package must be
##' installed. As required by the design of that package, the progress handler
##' must be explicitly activated before running your simulation. For that, run
##' `progressr::handlers(global = TRUE)` in the current R console (not sent to
##' the console from quarto for example).
##'
##' @title Evaluate function (iteratively) at a grid of input arguments
##' @param pars A list where each element is a numeric vector of values named as
##'   one of the arguments of \code{fun}. `fun` is applied to the full grid
##'   crossing the values of each of these parameters. If you aim to study other
##'   than numeric parameters, see details.
##' @param fun A function to be applied at each combination of
##'   \code{pars}. Arguments may contain all element names of \code{pars} and
##'   \code{more_args}. Output should always be a numeric vector, typically of
##'   length one. However, a if you want to work with multiple outpus, each can
##'   be an element of the returned numeric vector.
##' @param more_args Fixed arguments to \code{fun} that are not in
##'   \code{pars}. (internally used in \code{.mapply} for supplying argument
##'   \code{MoreArgs})
##' @param n_iter If not NA, function \code{fun} is applied \code{n_iter} times
##'   at each point in the grid defined by \code{pars}.
##' @param summarize Logical indicating whether iterations (if \code{n_iter} is
##'   given) are to be summarized by \code{summary_function}.
##' @param summary_function A function to be applied to aggregate across
##'   iterations. Defaults to \code{mean}, ignored when \code{keep_iters} ==
##'   TRUE or when \code{is.na(n_iter)}.
##' @param parallel Logical indicating whether parallel computing should be
##'   applied. If TRUE, future::future_replicate is used internally.
##' @param n_cores Passed on to future_replicate
##' @param progress_bar Logical argument to request output of iterations using
##'   a progress bar. See details section.
##' @return An array of class "power_array", with attributes containing
##'   informations about input arguments, summary status, the presence of
##'   multiple function outputs and more. This object class is handled sensibly
##'   by functions in package powergrid, including \code{\link{Example}},
##'   \code{\link{PowerPlot}}, and \code{\link{GridPlot}}.
##' @author Gilles Dutilh
##' @seealso [Refine()] for adding iterations or parameter combinations to
##'   exsiting `power_array` object, [SummarizeIterations()] for summarizing a
##'   `power_array` object containing individual iterations, [ArraySlicer()] and
##'   `[.power_array` for reducing the dimenstiona of a `power_array` object,
##'   correctly updating its attributes.
##' @examples
##' ## =======================================================
##' ## most basic use case, calculating power when
##' ## power function is available:
##' ## =======================================================
##'
##' ## Define grid of assumptions to study:
##' sse_pars = list(
##'   n = seq(from = 10, to = 60, by = 2),         # sample size
##'   delta = seq(from = 0.5, to = 1.5, by = 0.2), # effect size
##'   sd = seq(.1, .9, .2))                        # standard deviation
##'
##' ## Define function that calculates power based on these assumptions:
##' PowFun <- function(n, delta, sd){
##'   ptt = power.t.test(n = n/2, delta = delta, sd = sd,
##'                      sig.level = 0.05)
##'   return(ptt$power)
##' }
##'
##' ## Evaluate at each combination of assumptions:
##' powarr = PowerGrid(pars = sse_pars, fun = PowFun, n_iter = NA)
##' summary(powarr)
##'
##' ## =================================
##' ## Use powergrid utilities on result
##' ## =================================
##'
##' ## get required sample size n, when delta is .7, sd = .5, for achieving a
##' ## power of 90%:
##' Example(powarr, example = list(delta = .7, sd = .5), target_value = .9)
##'
##' ## Draw a figure illustrating how the required n depends on delta (given an
##' ## sd of .7):
##' PowerPlot(powarr,
##'           slicer = list(sd = .7), # slice out the plane with sd = .7
##'           target_value = .9, # set target power to 90%, defining the thick line
##'           example = list(delta = .7) # Highlight the example with arrow
##'           )
##' ## Slice out a sub-array (making sure attributes stay intact for further use in
##' ## powergrid):
##'
##' only_n20_delta1.1 =
##'   ArraySlicer(powarr, slicer = list(
##'                         n = 20,
##'                         delta = 1.1))
##' summary(only_n20_delta1.1)
##'
##' ## Indexing may also be used, but note that the name of the remaining dimension
##' ## is lost. Therefore, use ArraySlicer when you want to keep working with the
##' ## object in powergrid.
##' only_n20_delta1.1 = powarr[n = 20, delta = 1.1, ]
##' summary(only_n20_delta1.1)
##'
##' ## =======================================================
##' ## Simulation over iterations when no power
##' ## function is available
##' ## =======================================================
##'
##' ## Using the same assumptions as above
##' sse_pars = list(
##'   n = seq(from = 10, to = 60, by = 5),
##'   delta = seq(from = 0.5, to = 1.5, by = 0.2),
##'   sd = seq(.5, 1.5, .2))
##'
##' ## Define a function that results in TRUE or FALSE for a successful or
##' ## non-successful (5% significant) simulated trial:
##' PowFun <- function(n, delta, sd){
##'   x1 = rnorm(n = n/2, sd = sd)
##'   x2 = rnorm(n = n/2, mean = delta, sd = sd)
##'   t.test(x1, x2)$p.value < .05
##' }
##'
##' ## In call to PowerGrid, setting n_iter prompts PowerGrid to evaluate
##' ## the function iteratively at each combination of assumptions:
##' n_iter = 20
##' powarr = PowerGrid(pars = sse_pars, fun = PowFun,
##'                         n_iter = n_iter)
##'
##' ## By default, the iterations are summarized (by their mean), so:
##' dimnames(powarr)
##' summary(powarr) # indicates that iterations were summarized (not stored)
##'
##' ## =================================
##' ## keeping individual iterations
##' ## =================================
##'
##' ## To keep individual iterations, set summarize to FALSE:
##'
##' powarr_no_summary = PowerGrid(pars = sse_pars, fun = PowFun,
##'                                     n_iter = n_iter , summarize = FALSE)
##' dimnames(powarr_no_summary) # additional dimension "iter"
##' summary(powarr_no_summary)
##'
##' ## To summarize this object containing iterations, use the SummarizeIterations
##' ## function. Among other things, this assures that attributes relevant for
##' ## further use in powergrid's functionality are kept intact.
##'
##' powarr_summarized =
##'   SummarizeIterations(powarr_no_summary, summary_function = mean)
##' dimnames(powarr_summarized)
##' summary(powarr_summarized)
##'
##' ## This summarized `power_array` is no different from a version that was
##' ## directly summarized.
##'
##' ## Note that Example and Powerplot detect when a `power_array` object is not
##' #summarized, and behave sensibly with a warning:
##' Example(powarr_no_summary, example = list(delta = .7, sd = .5), target_value = .9)
##'
##' PowerPlot(powarr_no_summary,
##'           slicer = list(sd = .7), # slice out the plane with sd = .7
##'           target_value = .9, # set target power to 90%, defining the thick line
##'           example = list(delta = .7) # Highlight the example with arrow
##'           )
##'
##' #=======================================================
##' # Multiple outputs are automatically handled #
##' #=======================================================
##'
##' ## Parameter assumptions
##' sse_pars = list(
##'   n = seq(from = 10, to = 60, by = 2),
##'   delta = seq(from = 0.5, to = 1.5, by = 0.2),
##'   sd = seq(.5, 1.5, .2))
##'
##' ## A function with two outputs (the power at two significance levels)
##' TwoValuesFun <- function(n, delta, sd){
##'   p5 = power.t.test(n = n, delta = delta, sd = sd, sig.level = .05)$power
##'   p1 = power.t.test(n = n, delta = delta, sd = sd, sig.level = .01)$power
##'   return(c('p5' = p5, 'p1' = p1))
##' }
##'
##' powarr_two_returns = PowerGrid(sse_pars, TwoValuesFun)
##'
##' ## multiple outputs result in an additional dimension:
##' dimnames(powarr_two_returns)
##' summary(powarr_two_returns)
##'
##' ## note that you need to tell Example and other powergrid functions, which
##' ## of the outputs you are interested in:
##' Example(powarr_two_returns, example = list(delta = .7, sd = .5, fun_out = 'p1'),
##'         target_value = .9)
##'
##' PowerPlot(powarr_two_returns,
##'           slicer = list(sd = .7, fun_out = 'p1'), # slice out the plane with the
##'                                                   # output of interest
##'           target_value = .9, # set target power to 90%, defining the thick line
##'           example = list(delta = .7) # Highlight the example with arrow
##'           )
##' @importFrom methods is
##' @export
PowerGrid = function(pars, fun, more_args = NULL, n_iter = NA,
                     summarize = TRUE, summary_function = mean,
                     parallel = FALSE,
                     n_cores = future::availableCores()-1,
                     progress_bar = FALSE) {
  if(progress_bar) {

    if (!requireNamespace("progressr", quietly = TRUE)) {
      stop("Setting argument `progress_bar' to TRUE requires installation of progressr", call. = FALSE)
    }

    if (!any(names(globalCallingHandlers()) %in% "condition")) {
      warning("Requested progress bar can't be shown as global progress handlers aren't set. See details section of help file.",
              immediate. = TRUE)
    }

    ## Store the old handlers
    old_handlers <- progressr::handlers("txtprogressbar")

    ## On exit revert them
    on.exit({progressr::handlers(old_handlers)}, add = TRUE)

    progressr::handlers(progressr::handler_txtprogressbar(clear = FALSE))
  }

  ##
  ## ============================================
  ## Process arguments
  ##
  ## catch the very unlikely case someone takes e1d42fl5z7b6 as a
  ## parameter name, or a parameter name including funout_
  if ('e1d42fl5z7b6' %in% names(pars) || any(grepl('funout_', names(pars))) ||
      any(grepl('iter', names(pars)))) {
    stop('You chose one of few parameter names that are not allowed (e1d42fl5z7b6 or funout_...)')}
  ## All pars arguments of fun?
  if (!all(names(pars) %in% methods::formalArgs(fun))){
    stop("`pars` contains parameters that do not match the arguments of `fun`")
  }
  ## ============================================
  ##
  ## if in the current session there has been no random generation done, there
  ## is no .Random.seed. Therefore, create one random number (always)
  if(!exists(".Random.seed")) stats::runif(1)
  random_seed = .Random.seed
  ## ============================================
  ## fill grid
  pars_grid = expand.grid(pars)

  ## Check length of the returned output (per parameter set & iteration)
  n_funouts = length(.mapply(fun, pars_grid[1, ], MoreArgs = more_args)[[1]])

  ## Based on n_funouts make paradigms, the structure expected to be returned
  if(n_funouts >1) {
    funout_paradigm <- numeric(n_funouts)
    iter_paradigm <- matrix(numeric(1L), nrow = n_funouts, ncol = nrow(pars_grid))
  } else {
    funout_paradigm <- numeric(n_funouts)
    iter_paradigm <- numeric(nrow(pars_grid))
  }

  ## The next block of code goes through 3 routes (A1-A3) depending on whether iterations
  ## are needed, and whether parallel computation is requested.
  ## =================================
  ## Route A1) No iteration ('n_iter' not supplied)
  if(is.na(n_iter)) {
    e1d42fl5z7b6 = vapply( # the long name is to make it very unlikely
                                        # to get the same name in the grid, which
                                        # would break the xtab below.
      .mapply(fun, pars_grid, MoreArgs = more_args), I,
      FUN.VALUE = funout_paradigm)
    ## out = cbind(pars_grid, e1d42fl5z7b6)
    ## result is a n_result_vars by nrow(pars_grid) matrix
  }
  ## =================================
  ## Route A2) Series iteration ('n_iter' supplied)
  if (!is.na(n_iter) && !parallel) {

    iter <- seq_len(n_iter)
    if(progress_bar) p <- progressr::progressor(steps = n_iter)

    e1d42fl5z7b6 =
      drop(vapply(
        X = iter, function(i) {
          out <- vapply( # reshape mapply result
            .mapply(fun, pars_grid, MoreArgs = more_args), unlist,
            FUN.VALUE = funout_paradigm)

          if(progress_bar) {
            p()
          }
          return(out)
        }, FUN.VALUE = iter_paradigm)
        )
  }
  ## =================================
  ## Route A3) Parallel iteration using future_replicate
  if (!is.na(n_iter) && parallel) {
    if (!requireNamespace("future.apply", quietly = TRUE)) {
      stop("Setting argument `parallel' to TRUE requires installation of future.apply", call. = FALSE)}
    future::plan("future::multisession", workers = n_cores)

    ## Convert n_iter to a vector of iterations to iterate over
    iter <- seq_len(n_iter)

    ## If progress requested initiate a progressbar
    if(progress_bar) p <- progressr::progressor(steps = n_iter)

                                        # Three level sapply(iter, sapply(mapply( PowFun, pars)))
    e1d42fl5z7b6 = drop(future.apply::future_vapply(
                                        X = iter, function(i) {
                                          out <- vapply( # reshape mapply result
                                            .mapply(fun, pars_grid, MoreArgs = more_args), unlist,
                                            FUN.VALUE = funout_paradigm)

                                          if(progress_bar) {
                                            p()
                                          }
                                          return(out)
                                        }, future.seed = TRUE,
                                        FUN.VALUE = iter_paradigm)
                        )
  }
  ## =================================
  ## A1-A3 briefly converge and then diverge into B1-B2 depending on whether
  ## multiple outputs are returned.

  ## Route B1) One variable
  if (n_funouts == 1) {

    ## Turn grid into array
    out_array = stats::xtabs(
                         stats::as.formula(
                                  paste('e1d42fl5z7b6 ~', paste(names(pars_grid), collapse = '+'))),
                         data = pars_grid)
  }
  ##
  ## Route B2) Multiple variables, with slightly different behaviours based
  ## on where iterations present.
  if (n_funouts > 1) {

    ## first take care that pars names and funout names are not confused
    if(any(dimnames(e1d42fl5z7b6)[[1]] %in% names(pars))){
      dimnames(e1d42fl5z7b6)[[1]] =
        paste0('funout_', dimnames(e1d42fl5z7b6)[[1]])
    }
    ## if, else to control the wrangling based on whether multiple iterations present
    ## nitt is a dummy version of n_iteration which is 1 if there is no interations.
    if(!is.na(n_iter)) {
      var_order =  c(2, 1, 3)
      nitt = n_iter
    } else {
      var_order = c(2, 1)
      nitt = 1
    }
    ## put in flat format to work with xtabs later
    flat = cbind(
      as.data.frame(stats::ftable(e1d42fl5z7b6, row.vars = var_order)),
      apply(pars_grid, 2, rep, n_funouts * nitt))
    ## easiest to set dimnames before xtabs
    colnames(flat)[seq_len(length(var_order)+1)] = c(c('fun_out', 'parscom', 'iter')[var_order], 'value')
    out_array = stats::xtabs(value ~ ., data = flat[, -1])
    ## Sort such that the first dimensions are the pars
    L = names(dimnames(out_array)) %in% c('fun_out', 'iter')
    out_array = aperm(out_array, c(which(!L), which(L)))
  }

  ## Ensure the iteration dimension is correctly labelled (regardless of
  ## which route it took)
  if(!is.na(n_iter)) {
    names(dimnames(out_array))[length(dimnames(out_array))] = "iter"
    dimnames(out_array)[['iter']] = seq_along(dimnames(out_array)[['iter']])
  }

  ## set attributes of output object. Summarised is FALSE as not summarised yet
  class(out_array) = 'power_array'
  attr(out_array, which = 'sim_function') = fun
  attr(out_array, which = 'sim_function_nval') = n_funouts
  attr(out_array, which = 'pars') = pars
  attr(out_array, which = 'more_args') = more_args

  attr(out_array, which = 'summarized') = FALSE
  attr(out_array, which = 'n_iter') = n_iter
  attr(out_array, which = 'random_seed') = list("original" = random_seed)

  ## If the array has iterations, and needs summarising, summarize it
  if((!is.na(n_iter) && summarize)) {
    out_array = SummarizeIterations(out_array, summary_function = substitute(summary_function))
  }
  ## If the object never needed summarizing, it is already summarized:
  if(is.na(n_iter)) {
    attr(out_array, which = 'summarized') = TRUE
  }

  return(out_array)
}

## ==================================================================
## Method for [INDEXING]
## ==================================================================
## in order to keep class and other attributes

##' Method for indexing [] of objects of class power_array. The method makes
##' sure that the resulting array is of class power_array and keeps and updates
##' the object's attributes. These attributes are needed for various functions
##' in the powergrid package to work well.
##' ##'
##' The indexing functions as normal indexing, but note that drop is
##' FALSE by default, so that the resulting array has the same
##' dimensions as the original array. The number of levels at each
##' dimension may be reduced, however.
##' ##'
##' @title indexing with [ ] for class \code{power_array}
##' @return An array of class \code{power_grid}
##' @author Gilles Dutilh
##' @param x object
##' @param ... index
##' @param drop drop
##' @seealso
##' \code{\link{PowerGrid}}
##' \code{\link{ArraySlicer}} for a different method of reducing the
##'   dimensions of an array of class power_array.
##' @examples
##' ## Define grid of assumptions to study:
##' sse_pars = list(
##'   n = seq(from = 10, to = 50, by = 20),         # sample size
##'   delta = seq(from = 0.5, to = 1.5, by = 0.5), # effect size
##'   sd = seq(.1, 1, .3))                        # standard deviation
##'
##' ## Define function that calculates power based on these assumptions:
##' PowFun <- function(n, delta, sd){
##'   ptt = power.t.test(n = n/2, delta = delta, sd = sd,
##'                      sig.level = 0.05)
##'   return(ptt$power)
##' }
##'
##' ## Evaluate at each combination of assumptions:
##' powarr = PowerGrid(pars = sse_pars, fun = PowFun, n_iter = NA)
##' powarr[2, 1, ] # gives the same as
##' powarr['30', '0.5', ]
##' @export
`[.power_array` = function(x, ..., drop = TRUE) {
  the_attributes = attributes(x)
  x = NextMethod(x)
  if (is.null(dim(x))){ # vector to become 1-dim array
    the_attributes$dim = length(x)
    the_attributes$dimnames = list('dropped_name' = NULL)
    ## If the array becomes a vector, it should get names as an attribute
    ## This is very important for FindTarget
    the_attributes$names = attr(x, "names")
  } else { # array
    the_attributes$dim = dim(x)
    the_attributes$dimnames = dimnames(x)
  }

  ## copy the current dimnames to replace the pars, but only those dimensions
  ## the have name that is in pars.
  the_attributes$pars[
                   intersect(names(the_attributes$pars),
                             names(the_attributes$dimnames))] =
    lapply(
      the_attributes$dimnames[
                       intersect(names(the_attributes$pars),
                                 names(the_attributes$dimnames))],
      as.numeric)
  if (all(names(dimnames(x)) != 'fun_out')){
    the_attributes$sim_function_nval = 1
  } else {the_attributes$sim_function_nval = length(dimnames(x)$fun_out)}
  ## if there are iters, and these are selected with index, update n_iter
  if (!the_attributes$summarized && !is.na(the_attributes$n_iter))
  {
    if (!('iter' %in% names(dimnames(x))))
    {
      the_attributes$n_iter = 1 # iter dimension dropped, stil n_iter
    } else {
      the_attributes$n_iter =
        dim(x)[
          which(names(dimnames(x)) == 'iter')]
    }
  }
  ## update pars if reduced by indexing.
  if (is.null(dimnames(x)))
  {
    x = as.array(x)
  }
  ## fill in NA for attributes that ArraySlicer can create, but indexing can't
  the_attributes$sliced_at = NA
  the_attributes$dims_left = NA
  attributes(x) = the_attributes
  return(x)
}

## ==================================================================
## Method for printing power_array
## ==================================================================

##' Method for printing objects of class power_array.
##' ##'
##' Prints a power_array as a default array with a short summary about
##' its contents.
##' @title print
##' @param x object of class power_array
##' @param ... passed on to `cat`
##' @return Nothing
##' @seealso
##' \code{\link{PowerGrid}}
##' @author Gilles Dutilh
##' @examples
##' ## Define grid of assumptions to study:
##' sse_pars = list(
##'   n = seq(from = 10, to = 50, by = 20),         # sample size
##'   delta = seq(from = 0.5, to = 1.5, by = 0.5), # effect size
##'   sd = seq(.1, 1, .3))                        # standard deviation
##'
##' ## Define function that calculates power based on these assumptions:
##' PowFun <- function(n, delta, sd){
##'   ptt = power.t.test(n = n/2, delta = delta, sd = sd,
##'                      sig.level = 0.05)
##'   return(ptt$power)
##' }
##'
##' ## Evaluate at each combination of assumptions:
##' powarr = PowerGrid(pars = sse_pars, fun = PowFun, n_iter = NA)
##' print(powarr)
##' @export
print.power_array = function(x, ...){
  print.table(x)
  note_type_created_by = paste0(
    'Array of class `power_array` created using PowerGrid',
    ## Are individual iters in object?
    ifelse(!is.na(attr(x, which = 'n_iter')) &
           !attr(x, which = 'summarized'),
           ', keeping individual iterations',
           ''),
    ## Are there multiple outputs from function?
    ifelse(attr(x, which = 'sim_function_nval') > 1,
           paste0(', containing ', attr(x, which = 'sim_function_nval'),
                  ' output values from each application of the function given in attribute `sim_function`.'), '.')
  )
  note_resulting_array =
    ## Description of resulting dimensions of object:
    ifelse(length(dim(x)) == 1,
           " One resulting dimension (dimension's name was dropped by indexing).",
           paste0('Resulting dimensions:\n ',
                  paste(names(dimnames(x)), collapse = ', '), '.')
           )
  ## If there are iterations (summarized or not), show n_iter
  note_iterations =
    ifelse(!is.na(attr(x, which = 'n_iter')),
           paste0('Results from ', attr(x, which = 'n_iter'), ' iteration',
                  ifelse(attr(x, which = 'n_iter') > 1, 's', '')),
           '' # if no iterations
           )
  ## If these are summarized, show summary function
  note_summary_function =
    ifelse(!is.na(attr(x, which = 'n_iter')) &
           attr(x, which = 'summarized'),
           paste0(" summarized by function `",
                  attr(x, which = 'summary_function_name'),
                  "` (for function definition, see attribute `summary_function`)."),
           "")
  ## print all notes together, wrapping what may be wrapped
  cat(paste0(
    PrintWrap(note_type_created_by),
    '\n ',
    note_resulting_array,
    '\n',
    PrintWrap(paste(
      note_iterations,
      note_summary_function)),
    '\n', sep = ''), ...)
}

## ==================================================================
## Method for summary power_array
## ==================================================================

##' Offers a short summary of the power_array object, summarizing the
##' range of observed values and the grid evaluated across.
##' ##'
##' See PowerGrid for details
##' @title Summary of power_grid object.
##' @param object array of class power_grid
##' @param ... passed on to `cat`
##' @return nothing
##' @seealso
##' \code{\link{PowerGrid}}
##' @author Gilles Dutilh
##' @examples
##' ## Define grid of assumptions to study:
##' sse_pars = list(
##'   n = seq(from = 10, to = 50, by = 20),         # sample size
##'   delta = seq(from = 0.5, to = 1.5, by = 0.5), # effect size
##'   sd = seq(.1, 1, .3))                        # standard deviation
##'
##' ## Define function that calculates power based on these assumptions:
##' PowFun <- function(n, delta, sd){
##'   ptt = power.t.test(n = n/2, delta = delta, sd = sd,
##'                      sig.level = 0.05)
##'   return(ptt$power)
##' }
##'
##' ## Evaluate at each combination of assumptions:
##' powarr = PowerGrid(pars = sse_pars, fun = PowFun, n_iter = NA)
##' summary(powarr)
##' @export
summary.power_array = function(object, ...){
  aa = attributes(object)
  parnames = names(aa$dimnames[!(names(aa$dimnames) %in% c('iter', 'fun_out'))])
  if(!is.na(aa$n_iter) && aa$summarized){
    note_summary_iter =
      paste0("Containing summary over ", aa$n_iter,
             " iterations, summarized by function `",
             attr(object, which = 'summary_function_name'),
             "` (for function definition, see attribute `summary_function`).")
  } else {
    if(!is.na(aa$n_iter) && !aa$summarized){
      note_summary_iter =
        paste0('Containing output of ', aa$n_iter, ' individual iteration',
               ifelse(aa$n_iter > 1, 's', ''), '.')
    } else {
      note_summary_iter = ''
    }
  }
  note_range =
    paste0(
      " Range of values: ",
      ifelse(
        'fun_out' %in% names(dimnames(object)),
        paste0('\n',
               paste0(
                 paste0('      ', dimnames(object)$fun_out), ': ',
                 apply(apply(object, 'fun_out', range, na.rm = TRUE),
                       2, function(x)
                       {paste0(
                          '[', paste0(round(x, 2), collapse = ', '), ']')}),
                 collapse = '\n')),
        paste0('[', paste0(round(range(object, na.rm = TRUE), 2),
                           collapse = ', '), ']')
      )
    )
  note_grid =
    ifelse(all(names(aa$dimnames) == 'dropped_name'), "", # if no name for dim
           paste0(
             "\n Evaluated at:\n",
             paste(mapply(function(x, y){
               paste(format(as.list(x), width = max(nchar(parnames) + 2),
                            justify = 'right'),
                     strwrap(paste(y, collapse = ', '), width = 50),
                     collapse = '\n')},
               x = as.list(parnames), y = aa$dimnames[parnames]),
               collapse = '\n')
           )
           )
  cat(paste0(
    " Object of class: ", aa$class, "\n",
    PrintWrap(note_summary_iter),
    '\n',
    note_range,
    ' ',
    note_grid,
    '\n')
    , ...)
}

##' @title Summary of object that has individual iterations saved.
##' @description Summarizes objects of class `power_array` that have individual
##'   iterations saved.
##' @param x Object of class `power_array`
##' @param summary_function function to apply across iterations
##' @param ... Further arguments passed to 'summary_function'
##' @return An object of class `power_array`, with attributes \code{summarized =
##'   TRUE}.
##' @author Gilles Dutilh
##' @seealso
##' \code{\link{PowerGrid}}
##' @examples
##' ## iterative sse example
##' sse_pars = list(
##'   n = seq(from = 10, to = 60, by = 5),
##'   delta = seq(from = 0.5, to = 1.5, by = 0.2),
##'   sd = seq(.5, 1.5, .2))
##'
##' ## Define a function that results in TRUE or FALSE for a successful or
##' ## non-successful (5% significant) simulated trial:
##' PowFun <- function(n, delta, sd){
##'   x1 = rnorm(n = n/2, sd = sd)
##'   x2 = rnorm(n = n/2, mean = delta, sd = sd)
##'   t.test(x1, x2)$p.value < .05
##' }
##'
##' n_iter = 20
##' powarr = PowerGrid(pars = sse_pars, fun = PowFun,
##'                         n_iter = n_iter, summarize = FALSE)
##'
##' dimnames(powarr)
##' summary(powarr) # indicates that iterations were not
##' ## now summarize
##' powarr_summarized = SummarizeIterations(powarr, summary_function = mean)
##' dimnames(powarr_summarized)
##' summary(powarr_summarized) # indicates that iterations are now summarized
##' @export
SummarizeIterations = function(x, summary_function, ...){
  if(attr(x, which = 'summarized') | !inherits(x, 'power_array')){
    stop('Object x should be an object of class `power_array`, where attribute `summarized` is FALSE; containing individual iterations.')
  }
  ## to be sure the summary_function and its name is preserved, we need to
  ## explicitly cover differnt situations, and define what the to be evaluated
  ## argument to apply below is. The latter is also the opject stored in
  ## attribute "summary_function".
  if (is(summary_function, 'name')) { # function name inherited
    summary_function_name = as.character(summary_function)
    summary_function_eval = eval(summary_function)
  } else if (is(summary_function, 'call')) { # ano function inherited
    summary_function_name = 'anonymous function'
    summary_function_eval = eval(summary_function)
  } else if (is(summary_function, 'function') &
             is(substitute(summary_function), 'name')
             ) { # function name in direct SumarizeIterations use
    summary_function_name = as.character(substitute(summary_function))
    summary_function_eval = summary_function
  } else if (is(summary_function, 'function') &
             is(substitute(summary_function), 'call')
             ) { # function name in direct SumarizeIterations use
    summary_function_name = 'anonymous function'
    summary_function_eval = summary_function
  }
  aa = attributes(x)
  summarized_x = apply(x, names(dimnames(x))[names(dimnames(x)) != 'iter'],
                       summary_function_eval, ...)
  ## In case the summarizing results in only a vector, we need to transform back
  ## to array, resetting dims and dimnames
  if(is.vector(summarized_x)){
    constructed_dimnames = aa$dimnames[names(aa$dimnames) != 'iter']
    names(constructed_dimnames) = names(aa$dimnames)[names(aa$dimnames) != 'iter']
    summarized_x = as.array(summarized_x)
    dimnames(summarized_x) = constructed_dimnames
  }
  ## now, complete the new object's attributes with the old attributes
  new_attributes = attributes(summarized_x)
  for (cur_attribute in names(aa)[!(names(aa) %in% c('dim', 'dimnames'))])
    { # copy attributes
      new_attributes[[cur_attribute]] = aa[[cur_attribute]]
    }
  ## change summary-related attributes
  new_attributes$summarized = TRUE
  new_attributes$summary_function = summary_function_eval
  new_attributes$summary_function_name = summary_function_name
  attributes(summarized_x) = new_attributes
  return(summarized_x)
}


##' @title Transform power_array into power_df
##' @description Transforms an object of class `power_array` to a data.frame,
##'   where values are stored in column x, and all other dimensions are
##'   columns. Some may find this "more tidy" to work with.
##'
##' The class of the data.frame becomes `c("power_df", "data.frame"), enabling
##'   generics for data.frame. Note that the class "power_df" has currently no
##'   use but is included for future compatibility.
##' @param x Object of class `power_array`
##' @return An object of with classes c("power_df", "data.frame"), with the same
##'   attributes as `x`, aside from array-native attributes (dimnames, dim),
##'   plus the data.frame attributes `names` and `row_names`.
##' @seealso
##' \code{\link{PowerGrid}}
##' @author Gilles Dutilh
##' @examples
##' ## Define grid of assumptions to study:
##' sse_pars = list(
##'   n = seq(from = 10, to = 50, by = 20),         # sample size
##'   delta = seq(from = 0.5, to = 1.5, by = 0.5), # effect size
##'   sd = seq(.1, 1, .3))                        # standard deviation
##'
##' ## Define function that calculates power based on these assumptions:
##' PowFun <- function(n, delta, sd){
##'   ptt = power.t.test(n = n/2, delta = delta, sd = sd,
##'                      sig.level = 0.05)
##'   return(ptt$power)
##' }
##'
##' ## Evaluate at each combination of assumptions:
##' powarr = PowerGrid(pars = sse_pars, fun = PowFun, n_iter = NA)
##' print(PowerDF(powarr))
##' @export
PowerDF = function(x){
  flat = as.data.frame(stats::ftable(x, row.vars = seq_along(dim(x))))
  colnames(flat)[length(dim(x)) + 1] = 'x'
  aa = attributes(x)
  aa = aa[names(aa) != 'class']
  names(aa)[names(aa) == 'dimnames'] = 'orig_dimnames'
  names(aa)[names(aa) == 'dim'] = 'orig_dim'
  aa = append(attributes(flat), aa)
  attributes(flat) = aa
  class(flat) = c('power_df', class(flat))
  return(flat)
}


