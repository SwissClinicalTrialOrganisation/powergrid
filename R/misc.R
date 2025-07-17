
##' @title Scale to desired range
##' @description Linear scaling of a vector to a vector with a required range.
##' @param x A vector
##' @param a The desired minimum
##' @param b The desired maximum
##' @return a vector with the desired minimum and maximum
##' @author Gilles Dutilh
##' @export
ScaleRange = function(x, a, b){

  if(a > b) stop("a should be less than b")

  (b - a) * (x - min(x)) / (max(x) - min(x)) + a
}

##' @title Wrap text in printed output.
##' @description Wrap text in printed output. This function is created for
##'   convenience and also so that the width of wrapping can be set by simply
##'   changing the default here. Note that this give a leading white space to
##'   each resulting line. The is done to account for the fact that wrapping
##'   deletes the whites paces, and it actually looks good.
##' @param x A single character string
##' @param width The desired width
##' @param ... Further arguments passed to 'strwrap()'
##' @return a character string with returns placed such to achieve the desired
##'   width
##' @author Gilles Dutilh
##' @export
PrintWrap = function(x,
                     ## width = 0.5 * (getOption("width") - 3), ...){
                     width = 48, ...){
  if (x == ''){
    x
  } else {
    paste0('', paste0(strwrap(x, width = width), collapse = '\n'))
  }
}

##' @title Draw a line of dashes, or something else with a certain width.
##' @description Draw a line of dashes, or something else with a certain
##'   width. Is used in package in combination with PrintWrap.
##' @param symbol Symbol to repeat `width` times.
##' @param width The desired width (number of symbols)
##' @param ... Further arguments passed to 'strwrap()'
##' @return a character string of nchar `width`
##' @author Gilles Dutilh
##' @export
PrintDashes = function(symbol = '=', width = 48, ...)
{
  paste(rep(symbol, width), collapse = '')
}


