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
##' listed in \code{pars} and its results are stored in an array whose
##' dimensions (and \code{dimnames()}) are defined by \code{pars}. If function
##' \code{fun} returns more than one value (always as a single vector), the
##' array will have an additional dimension, with levels named after the names
##' of the returned vector (if given). If n_iter is not NA, function \code{fun}
##' is evaluated n_iter times. This will add to the resulting array an
##' additional dimension 'sim'.
##'
##' The elements of \code{pars} must match the argument names of fun. If input
##' parameters are not to be part of the grid, but rather further settings,
##' these can be passed on to \code{fun} through the argument \code{more_args}
##' as a list with names reflecting the arguments of `fun` to be set.
##'
##' @title Evaluate Function (iteratively) at Grid of Input Arguments
##' @param pars A list where each element is a vector of values named as one of
##'   the arguments of \code{fun}. `fun` is applied to the full grid crossing
##'   the values of each of these parameters.
##' @param fun Function applied at each combination of \code{pars}. Arguments
##'   may contain all element names of \code{pars} and \code{more_args}. Output
##'   should be a vector, typically of length one, but more outputs are
##'   generally handled properly in further functions of powergrid.
##' @param more_args Fixed arguments to \code{fun} that are not in
##'   \code{pars}. (internally used in \code{.mapply} for supplying argument
##'   \code{MoreArgs})
##' @param n_iter If not NA, function \code{fun} is applied \code{n_iter} times
##'   at each point in the grid defined by \code{pars}.
##' @param summarize Logical indicating whether iterations (if \code{n_iter} is
##'   given) are to be summarized by \code{summary_function}.
##' @param summary_function A function to be applied to aggregate across
##'   simulations. Defaults to \code{mean}, ignored when \code{keep_sims} ==
##'   TRUE or when \code{is.na(n_iter)}.
##' @param parallel Logical indicating whether parallel computing should be
##'   applied. If TRUE, future::future_replicate is used internally.
##' @param n_cores Passed on to future_replicate
##' @return An array of class "power_array"
##' @author Gilles Dutilh
##'
##' @examples
##' ## ============================================
##' ## most basic case, power function available:
##' ## ============================================
##' sse_pars = list(
##'   n = seq(from = 10, to = 60, by = 2),
##'   delta = seq(from = 0.5, to = 1.5, by = 0.2), ## effect size
##'   sd = seq(.1, .9, .2)) ## Standard deviation
##' PowFun <- function(n, delta, sd){
##'   ptt = power.t.test(n = n/2, delta = delta, sd = sd,
##'                      sig.level = 0.05)
##'   return(ptt$power)
##' }
##' power_array = PowerGrid(pars = sse_pars, fun = PowFun, n_iter = NA)
##' ##'
##' summary(power_array)
##'
##' ## ============================================
##' ## Multiple outputs are automatically handled
##' ## ============================================
##' TwoValuesFun <- function(n, delta, sd){
##'   p5 = power.t.test(n = n, delta = delta, sd = sd, sig.level = .05)$power
##'   p1 = power.t.test(n = n, delta = delta, sd = sd, sig.level = .01)$power
##'   return(c('p5' = p5, 'p1' = p1))
##' }
##' ##
##' sse_pars = list(
##'   n = seq(from = 10, to = 60, by = 2),
##'   delta = seq(from = 0.5, to = 1.5, by = 0.2),
##'   sd = seq(.5, 1.5, .2))
##' array_two_returns = PowerGrid(sse_pars, TwoValuesFun)
##' ## multiple outputs result in an additional dimension:
##' dimnames(array_two_returns)
##' summary(array_two_returns)
##'
##' ## ============================================
##' ## Simulations over iterations
##' ## ============================================
##' PowFun <- function(n, delta, sd){
##'   x1 = rnorm(n = n/2, sd = sd)
##'   x2 = rnorm(n = n/2, mean = delta, sd = sd)
##'   t.test(x1, x2)$p.value < .05
##' }
##' sse_pars = list(
##'   n = seq(from = 10, to = 60, by = 5),
##'   delta = seq(from = 0.5, to = 1.5, by = 0.2),
##'   sd = seq(.5, 1.5, .2))
##' ##
##' n_iter = 20
##' power_array = PowerGrid(pars = sse_pars, fun = PowFun,
##'                        n_iter = n_iter)
##' dimnames(power_array)
##' summary(power_array)
##' @export
PowerGrid = function(pars, fun, more_args = NULL, n_iter = NA,
                    summarize = TRUE, summary_function = mean,
                    parallel = FALSE,
                    n_cores = future::availableCores()-1) {
  ##
  ## ============================================
  ## Process arguments
  ##
  ## catch the very unlikely case someone takes e1d42fl5z7b6 as a
  ## parameter name, or a parameter name including funout_
  if ('e1d42fl5z7b6' %in% names(pars) || any(grepl('funout_', names(pars))) ||
      any(grepl('sim', names(pars)))) {
    stop('You chose one of few parameter names that are not allowed (e1d42fl5z7b6 or funout_...)')}
  ## All pars arguments of fun?
  if (!all(names(pars) %in% methods::formalArgs(fun))){
    stop("`pars` contains parameters that do not match the arguments of `fun`")
  }
  ## ============================================
  ## fill grid
  pars_grid = expand.grid(pars)
  ## =================================
  ## No simulation ('n_iter' not supplied)
  if(is.na(n_iter)) {
    e1d42fl5z7b6 = sapply( # the long name is to make it very unlikely
                                        # to get the same name in the grid, which
                                        # would break the xtab below.
      .mapply(fun, pars_grid, MoreArgs = more_args), function(x)x,
      simplify = "array")
    ## out = cbind(pars_grid, e1d42fl5z7b6)
    ## result is a n_result_vars by nrow(pars_grid) matrix
  }
  ##'
  ## =================================
  ## Simulation ('n_iter' supplied)
  #' allenr - TODO: Surely this should be if the parallel argument is TRUE
  #'    currently you are only testing for parallel if the parallel argument is
  #'    FALSE.
  if (!is.na(n_iter) && !parallel) {
    e1d42fl5z7b6 =
      drop(replicate(
        n_iter, sapply( # reshape mapply result
                  .mapply(fun, pars_grid, MoreArgs = more_args),
                  function(x)unlist(x))))
    if (summarize) {
      e1d42fl5z7b6 = apply(e1d42fl5z7b6,
                           1:(length(dim(e1d42fl5z7b6)) - 1), # per all but sim dim
                           summary_function, simplify = TRUE)
    }
  }
  ##'
  ## parallel using future_replicate
  if (!is.na(n_iter) && parallel) {
    if (!requireNamespace("future.apply", quietly = TRUE)) {
      stop("Setting argument `parallel' to TRUE requires installation of future.apply", call. = FALSE)}
    ## plan(strategy = future_args$plan$strategy, # 'multisession'
    ##      workers = future_args$plan$workers) # future::availableCores() - 1)
    future::plan("future::multisession", workers = n_cores)
    e1d42fl5z7b6 =
      drop(future.apply::future_replicate(
                           n_iter, sapply( # reshape mapply result
                                     .mapply(fun, pars_grid, MoreArgs = more_args),
                                     function(x)unlist(x))
                         ))
    if (summarize){
      e1d42fl5z7b6 = apply(e1d42fl5z7b6,
                           1:(length(dim(e1d42fl5z7b6)) - 1), # per all but sim dim
                           summary_function, simplify = TRUE)
    }
  }
  ## =================================
  n_funouts = length(.mapply(fun, pars_grid[1, ], MoreArgs = more_args)[[1]])
  ##'
  ## Turn grid into array
  ToArray = function(gg){
    stats::xtabs(stats::as.formula(
                          paste('gg ~', paste(names(pars_grid), collapse = '+'))), data = pars_grid)
  }
  ## Since the array resulting from .mapply may differ depending on
  ## 1) all.equal(summary_function, I) vs other summary function, vs no iterations
  ## 2) having one versus more than one result variable,
  ## I transform into an output array in the IFs below.
  ##'
  ## Simplest situation, with no iterations or summarized iterations,
  ## only one variable.
  if (n_funouts == 1 && (summarize || is.na(n_iter))) {
    out_array = ToArray(e1d42fl5z7b6)
  } # simple xtabs with pars
  ##'
  ## With no iterations or summarized iterations,
  ## but multiple variables
  if (n_funouts > 1 && (summarize || is.na(n_iter))) {
    ## first take care that pars names and funout names are not confused
    if(any(rownames(e1d42fl5z7b6) %in% names(pars))){
      rownames(e1d42fl5z7b6) =
        paste0('funout_', rownames(e1d42fl5z7b6))}
    ## transform to array
    out_array = ToArray(t(e1d42fl5z7b6))
    names(dimnames(out_array))[length(dim(out_array))] = 'fun_out'
  } # simple xtabs on transposed array
  ##'
  ## When simulations are not summarized (kept), one variable
  if (n_funouts == 1 && !summarize && !is.na(n_iter)) {
    out_array = ToArray(e1d42fl5z7b6) # so maybe merge with above
    dimnames(out_array)[length(dimnames(out_array))] = NULL
    names(dimnames(out_array))[length(dimnames(out_array))] = 'sim'
  }
  ##'
  ## When simulations are not summarized (kept), multiple variables
  if (n_funouts > 1 && !summarize && !is.na(n_iter)) {
    ## first take care that pars names and funout names are not confused
    if(any(dimnames(e1d42fl5z7b6)[[1]] %in% names(pars))){
      dimnames(e1d42fl5z7b6)[[1]] =
        paste0('funout_', dimnames(e1d42fl5z7b6)[[1]])}
    ## put in flat format to work with xtabs later
    flat = cbind(
      as.data.frame(stats::ftable(e1d42fl5z7b6, row.vars = c(2, 1, 3))),
      apply(pars_grid, 2, rep, n_funouts * n_iter))
    ## easiest to set dimnames before xtabs
    colnames(flat)[1:4] = c('parscom', 'fun_out', 'sim', 'value')
    out_array = stats::xtabs(value ~ ., data = flat[, -1])
    dimnames(out_array)[['sim']] = seq_along(dimnames(out_array)[['sim']])
    ## Sort such that the first dimensions are the pars
    dimnums = seq_along(dim(out_array))
    pardimnums = dimnums[!(dimnums %in% 1:2)]
    out_array = aperm(out_array, c(pardimnums, 1:2))
    ##'
    ##'
  }
  ##'
  ## set attributes of output object
  class(out_array) = 'power_array'
  attr(out_array, which = 'sim_function') = fun
  attr(out_array, which = 'sim_function_nval') = n_funouts
  attr(out_array, which = 'pars') = pars
  attr(out_array, which = 'more_args') = more_args
  attr(out_array, which = 'summarized') = summarize
  attr(out_array, which = 'n_iter') = n_iter
  attr(out_array, which = "summary_function") = summary_function
  attr(out_array, which = "summary_function_name") =
    ## if it has a name, take the name
    ifelse (class(substitute(summary_function)) == 'name',
            substitute(summary_function),
            ## otherwise ananymous
            "anonymous function"
            )
  attr(out_array,
       which = 'n_iter') = ifelse(is.na(n_iter), NA, n_iter)
  return(out_array)
}

## ==================================================================
## Method for [INDEXING]
## ==================================================================
## in order to keep class and other attributes

##' Method for indexing [] of objects of class power_array. The method
##' makes sure that the resulting array is of class power_array and
##' keeps and updates the object's attributes. These attributes are
##' needed for various functions in the powergrid package to work
##' well.
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
##' @export
`[.power_array` = function(x, ..., drop = TRUE) {
  the_attributes = attributes(x)
  x = NextMethod(x)
  if (is.null(dim(x))){ # vector to become 1-dim array
    the_attributes$dim = length(x)
    the_attributes$dimnames = list('dropped_name' = NULL)
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
  ## if there are sims, and these are selected with index, update n_iter
  if (!the_attributes$summarized && !is.na(the_attributes$n_iter))
  {
    if (!('sim' %in% names(dimnames(x))))
    {
      the_attributes$n_iter = 1 # sim dimension dropped, stil n_iter
    } else {
      the_attributes$n_iter =
        dim(x)[
          which(names(dimnames(x)) == 'sim')]
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
##' @export
##' @author Gilles Dutilh
print.power_array = function(x, ...){
  print.table(x)
  note_type_created_by = paste0(
    'Array of class `power_array` created using PowerGrid',
    ## Are individual sims in object?
    ifelse(!is.na(attr(x, which = 'n_iter')) &
           !attr(x, which = 'summarized'),
           ', keeping individual simulations',
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
  ## If there are simulations (summarized or not), show n_iter
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
##' @export
##' @author Gilles Dutilh
summary.power_array = function(object, ...){
  aa = attributes(object)
  parnames = names(aa$dimnames[!(names(aa$dimnames) %in% c('sim', 'fun_out'))])
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

##' @title Summary of object that has simulations saved.
##' @description Summarizes objects of class `power_array` that have individual
##'   simulations saved across simulations.
##' @param x Object of class `power_array`
##' @param summary_function function to apply across simulations
##' @param ... Further arguments passed to 'summary_function'
##' @return An object of class `power_array`, with attributes \code{summarized =
##'   TRUE}.
##' @author Gilles Dutilh
##' @export
SummarizeSims = function(x, summary_function, ...){
  if(attr(x, which = 'summarized') | !inherits(x, 'power_array')){
    stop('Object x should be an object of class `power_array`, where attribute `summarized` is FALSE; containing individual simulations.')
  }
  aa = attributes(x)
  summarized_x = apply(x, names(dimnames(x))[names(dimnames(x)) != 'sim'],
                       summary_function, ...)
  new_attributes = attributes(summarized_x)
  for (cur_attribute in names(aa)[!(names(aa) %in% c('dim', 'dimnames'))])
    { # copy attributes
      new_attributes[[cur_attribute]] = aa[[cur_attribute]]
    }
  ## change summary-related attributes
  new_attributes$summarized = TRUE
  new_attributes$summary_function = summary_function
  new_attributes$summary_function_name =
    ifelse (class(substitute(summary_function)) == 'name',
            substitute(summary_function),
            ## if created on the fly, it's an ananymous function
            "anonymous function"
            )
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
##' @author Gilles Dutilh
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


