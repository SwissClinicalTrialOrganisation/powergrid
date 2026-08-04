## This function offers two functionalities with respect to power_array
## objects:
##
## 1) to perform additional iterations (only for power_array where attr
## keep_iters = TRUE)
##
## 2) to evaluate a function on additional locations of the parameter
## grid.

##' @title Refine or extend the result of PowerGrid
##' @description Add further results to an existing power_array (created by
##'   PowerGrid or by another call of Refine), adding further values in
##'   \code{pars} and/or larger \code{n_iter}.
##' @details This function allows extending the number of iterations, as well as
##'   changing the parameter grid across which the function of interest is
##'   evaluated. Being able to do both at the same time is handy in cases where
##'   calculation takes significant time: You may first only evaluate a broad
##'   grid of parameters with a low number of iterations using PowerGrid. Then,
##'   using `Refine`, you can zoom in on a certain section of the parameter grid
##'   (and increase resolution in the focal range), and evaluate with a higher
##'   number of iterations.
##'
##'   If \code{pars == NULL}, `Refine` extends \code{old} by adding iterations
##'   \code{n_iter_add} to the existing power_array (applying the original
##'   function \code{attr(old, which = 'sim_function'}).
##'
##'   If \code{pars} is given and different from the original `pars`
##'   (\code{attr(old, which = 'pars')}), the function is evaluated at
##'   additional crossings of parameters. This means that the resulting array
##'   may have empty cells, or cells with different numbers of iterations. This
##'   is a feature, not a bug. It may result in less aesthetic plotting,
##'   however.
##'
##'   For details about handling the random seed, see \code{\link{PowerGrid}}.
##' @param old the object of class `power_array` to extend
##' @param n_iter_add the number of iterations to *add* to old
##' @param pars the new parameter grid to evaluate across
##' @param ... further arguments passed on to PowerGrid internally.
##' @return object of class `power_array`, containing old, extended by
##'   \code{pars} and/or \code{n_iter_add}.
##' @seealso \code{\link{PowerGrid}}
##' @author Gilles Dutilh
##' @examples
##' ## ============================================
##' ## very simple example with one parameter
##' ## ============================================
##' pars = list(x = 1:2)
##' fun = function(x){round(x+runif(1, 0, .2), 3)} # nonsense function
##' set.seed(1)
##' original = PowerGrid(pars = pars,
##'                      fun = fun,
##'                      n_iter = 3,
##'                      summarize = FALSE)
##' refined = Refine(original, n_iter_add = 2, pars = list(x = 2:3))
##' ## note that refined does not have each parameter sampled in each iteration
##'
##' ## ============================================
##' ## a realistic example, simply increasing n_iter
##' ## ============================================
##' PowFun <- function(n, delta){
##'   x1 = rnorm(n = n/2, sd = 1)
##'   x2 = rnorm(n = n/2, mean = delta, sd = 1)
##'   t.test(x1, x2)$p.value < .05
##' }
##' sse_pars = list(
##'   n = seq(10, 100, 5),
##'   delta = seq(.5, 1.5, .1))
##' ##
##' n_iter = 20
##' set.seed(1)
##' power_array = PowerGrid(pars = sse_pars,
##'                         fun = PowFun,
##'                         n_iter = n_iter,
##'                         summarize = FALSE)
##' summary(power_array)
##' ## add iterations
##' power_array_up = Refine(power_array, n_iter_add = 30)
##' summary(power_array_up)
##'
##' ## ============================================
##' ## Starting coarsely, then zooming in
##' ## ============================================
##' sse_pars = list(
##'   n = c(10, 50, 100, 200), # finding n "ballpark"
##'   delta = c(.5,  1, 1.5)) # finding delta "ballpark"
##' n_iter = 60
##' power_array = PowerGrid(pars = sse_pars,
##'                         fun = PowFun,
##'                         n_iter = n_iter,
##'                         summarize = FALSE)
##' summary(power_array)
##' PowerPlot(power_array)
##' ## Based on figure above, let's look at n between 50 and 100, delta around .9
##' \donttest{
##' sse_pars = list(
##'   n = seq(50, 100, 5),
##'   delta = seq(.7, 1.1, .05))
##' set.seed(1)
##' power_array_up = Refine(power_array, n_iter_add = 555, pars = sse_pars)
##' summary(power_array_up)
##' PowerPlot(power_array_up)
##'
##' ## That looks funny! It's because the default summary mean does not deal
##' ## with the empty value in the grid. Solution is in illustration below.
##'
##' ## A visual illustration of this zooming in, in three figures
##' layout(t(1:3))
##' PowerPlot(power_array, title = 'Course grid to start with')
##' PowerPlot(power_array_up, summary_function = function(x)mean(x, na.rm = TRUE),
##'           title = 'Extra samples at finer grid\n(looks funny with large empty cells)')
##' PowerPlot(power_array_up,
##'           slicer = list(n = seq(50, 100, 5),
##'                         delta = seq(.7, 1.1, .05)),
##'           summary_function = function(x)mean(x, na.rm = TRUE),
##'           title = 'Zoomed in')
##' layout(1)
##' }
##' @export
Refine = function(old, n_iter_add = 1, pars = NULL, ...){
  if (is.null(pars)) {pars = attr(old, 'pars')}
  ## save seed
  random_seed = .Random.seed
  ## copy the original attributes to add later
  copy_attr = attributes(old)
  ## number of zeros later needed for iter-dimension
  nzeros = max(ceiling(log(n_iter_add, 10)),
               ceiling(log(attr(old, 'n_iter'), 10)))
  ## Perform iterations in grid, using, where relevant, the attributes
  ## of old.
  new = PowerGrid(pars = pars,
                  fun = copy_attr$sim_function,
                  n_iter = n_iter_add,
                  more_args = copy_attr$more_args,
                  summarize = FALSE, ...)
  ## =================================
  ## The next chunk combines the old and new arrays into an array,
  ## thereby taking care that the result has missing values for eventual
  ## combinations of pars that were not evaluated in old.
  ##
  ## I use ftable to turn old and new array into grid, to correctly
  ## combine before transforming them back into an array. Note that
  ## ftable gives some funny colnaming, which I correct (rename letters
  ## to integer)
  ##
  ## Note that I reuse object name to save memory space, making code much
  ## less easy to read.
  old = stats::ftable(old, col.vars = 'iter') # flat table
  attr(old, 'col.vars')$iter = as.character(1:ncol(old))
  old = as.data.frame(old) # expanded grid pars * iterations
  new = stats::ftable(new, col.vars = 'iter') # flat table
  attr(new, 'col.vars')$iter = as.character(1:ncol(new))
  new = as.data.frame(new)# expanded grid pars * iterations
  ## Labels for iters need unique names between sets
  old$iter = paste0('old_', sprintf(paste0('%0', nzeros, '.0f'), old$iter))
  new$iter = paste0('upd_', sprintf(paste0('%0', nzeros, '.0f'), new$iter))
  new = rbind(old, new) # new now contains old as well!
  ##
  ## If pars (new) are different than pars (old) make a grid with all
  ## the possible combinations, including the ones never
  ## substantiated. Call is complicated due to memory-saving reusing of
  ## object names. For understanding, I kept the commented line below
  ## which creates exp_grid_hypo, which is then merged.
  ##
  ## exp_grid_hypo = expand.grid(lapply( exp_grid_combi[,
  ## names(exp_grid_combi) != 'Freq'], unique))
  ## !! I reuse the name 'old' below, to contain the merged version !!
  ## I do so, because I need the long version later and old's use is gone.
  old = merge(expand.grid(lapply(
    new[, names(new) != 'Freq'], unique)),
    new, all.x = TRUE)
  ## change back grid values to numeric:
  ## allenr: with multi-function out this does not take into account fun_out
  old[, seq_along(length(pars))] = sapply(old[, seq_along(length(pars))],
                                 function(x)as.numeric(as.character(x)))
  ## sort (in a rather complicated way, since we do not know the number
  ## of columns):
  old = old[do.call(order, as.data.frame(as.matrix(old[, -ncol(old)]))), ]
                                        # to have the correct grid point names
                                        # when using xtabs, change from num/fac
                                        # to character
  old[, -ncol(old)] = apply(old[, -ncol(old)], 2, as.character)
  new = stats::xtabs(Freq ~ ., data = old)
  new[as.matrix(old[is.na(old$Freq), names(old) != 'Freq'])] = NA
  dimnames(new)[-length(dimnames(new))] =
    lapply(dimnames(new)[-length(dimnames(new))],
           function(x)as.numeric(as.character(x)))
  ##
  ## =================================
  attr(new, 'call') = NULL # remove irrelevant attribute
  ## change the changed attributes
  copy_attr$dim = dim(new)
  copy_attr$dimnames = dimnames(new)
  copy_attr$n_iter = copy_attr$n_iter + n_iter_add
  copy_attr$random_seed[[length(copy_attr$random_seed) + 1]] = random_seed
  ## set attributes
  attributes(new) = copy_attr
  return(new)
}

