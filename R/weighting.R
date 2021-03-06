##' Weighted mean and variance of a vector
##'
##' Compute the weighted mean or weighted variance of a vector.
##' 
##' @aliases wtd.var
##' @param x Numeric data vector 
##' @param weights Numeric weights vector. Must be the same length as \code{x}
##' @param normwt Only for \code{wtd.var}, if \code{TRUE} then weights are normalized for the weighted count to be the same as the non-weighted one
##' @param na.rm if \code{TRUE}, delete \code{NA} values.
##' @details
##' If \code{weights} is \code{NULL}, then an uniform weighting is applied.
##' @author
##' These functions are exact copies of the \code{wtd.mean} and \code{wtd.var}
##' function from the \link[Hmisc]{wtd.stats} package. They have been created by Frank Harrell, Department of Biostatistics,
##' Vanderbilt University School of Medicine, <f.harrell@@vanderbilt.edu>.
##' @seealso
##' \code{\link{mean}},\code{\link{var}}, \code{\link{wtd.table}} and the \link{survey} package.
##' @examples
##' data(hdv2003)
##' mean(hdv2003$age)
##' wtd.mean(hdv2003$age, weights=hdv2003$poids)
##' var(hdv2003$age)
##' wtd.var(hdv2003$age, weights=hdv2003$poids)
##' @export wtd.mean wtd.var

`wtd.mean` <-
function (x, weights = NULL, normwt = "ignored", na.rm = TRUE) 
{
    if (!length(weights)) 
        return(mean(x, na.rm = na.rm))
    if (na.rm) {
        s <- !is.na(x + weights)
        x <- x[s]
        weights <- weights[s]
    }
    sum(weights * x)/sum(weights)
}

`wtd.var` <-
function (x, weights = NULL, normwt = FALSE, na.rm = TRUE) 
{
    if (!length(weights)) {
        if (na.rm) 
            x <- x[!is.na(x)]
        return(stats::var(x))
    }
    if (na.rm) {
        s <- !is.na(x + weights)
        x <- x[s]
        weights <- weights[s]
    }
    if (normwt) 
        weights <- weights * length(x)/sum(weights)
    xbar <- sum(weights * x)/sum(weights)
    sum(weights * ((x - xbar)^2))/(sum(weights) - 1)
}


#' Weighted one-way and two-way frequency tables.
#'
#' Generate weighted frequency tables, both for one-way and two-way tables.
#'
#' @param x a vector
#' @param y another optional vector for a two-way frequency table. Must be the same length as \code{x}
#' @param weights vector of weights, must be the same length as \code{x}
#' @param normwt if TRUE, normalize weights so that the total weighted count is the same as the unweighted one
#' @param na.show if TRUE, show NA count in table output
#' @param na.rm if TRUE, remove NA values before computation
#' @param digits Number of significant digits.
#' @param exclude values to remove from x and y. To exclude NA, use na.rm argument.
#' @details
#' If \code{weights} is not provided, an uniform weghting is used.
#' @return
#' If \code{y} is not provided, returns a weighted one-way frequency table
#' of \code{x}. Otherwise, returns a weighted two-way frequency table of
#' \code{x} and \code{y}
#' @seealso
#' \code{\link[Hmisc]{wtd.table}}, \command{\link{table}}, and the \link{survey} extension.
#' @examples
#' data(hdv2003)
#' wtd.table(hdv2003$sexe, weights=hdv2003$poids)
#' wtd.table(hdv2003$sexe, weights=hdv2003$poids, normwt=TRUE)
#' table(hdv2003$sexe, hdv2003$hard.rock)
#' wtd.table(hdv2003$sexe, hdv2003$hard.rock, weights=hdv2003$poids)
#' @export



`wtd.table` <-
function (x, y = NULL, weights = NULL, digits = 3, normwt = FALSE, na.rm = TRUE, na.show = FALSE, exclude = NULL) 
{
  if (is.null(weights)) weights <- rep(1, length(x))  
  if (length(x) != length(weights)) stop("x and weights lengths must be the same")
  if (!is.null(y) & (length(x) != length(y))) stop("x and y lengths must be the same")
  if (na.show) {
      x <- addNA(x)
      if (!is.null(y)) y <- addNA(y)
  }
  if (na.rm) {
     s <- !is.na(x) & !is.na(weights)
     if (!is.null(y)) s <- s & !is.na(y)
     x <- x[s, drop = FALSE]
     if (!is.null(y)) y <- y[s, drop = FALSE]
     weights <- weights[s]
  }
  if (!is.null(exclude)) {
    s <- !(x %in% exclude)
    if (!is.null(y)) s <- s & !(y %in% exclude)
    x <- factor(x[s, drop = FALSE])
    if (!is.null(y)) y <- factor(y[s, drop = FALSE])
    weights <- weights[s]
  }
  if (normwt) {
    weights <- weights * length(x)/sum(weights)
  }
  if (is.null(y)) {
    result <- tapply(weights, x, sum, simplify=TRUE)
  }
  else {
    result <- tapply(weights, list(x,y), sum, simplify=TRUE)
  }
  result[is.na(result)] <- 0
  as.table(result)
}


#' Weighted Crossresult
#' 
#' Generate table with multiple weighted crossresult (full sample is first column).
#' kable(), which is found in library(knitr), is recommended for use with RMarkdown.
#' 
#' @param df A data.frame that contains \code{x} and (optionally) \code{y} and \code{weight}.
#' @param x variable name (found in \code{df}). tabs(my.data, x = 'q1').
#' @param y one (or more) variable names. tabs(my.data, x = 'q1', y = c('sex', 'job')).
#' @param weight variable name for weight (found in \code{df}). 
#' @param type 'percent' (default ranges 0-100), 'proportion', or 'counts' (type of table returned).
#' @param percent if \code{TRUE}, add a percent sign after the values when printing
#' @param normwt if TRUE, normalize weights so that the total weighted count is the same as the unweighted one
#' @param na.show if TRUE, show NA count in table output
#' @param na.rm if TRUE, remove NA values before computation
#' @param exclude values to remove from x and y. To exclude NA, use na.rm argument.
#' @param digits Number of digits to display; ?format.proptab for formatting details.
#' @details tabs calls wtd.table on `\code{x}` and, as applicable, each variable named by `\code{y}`.
#' @author Pete Mohanty
#' @examples
#' data(hdv2003) 
#' tabs(hdv2003, x = "relig", y = c("qualif", "trav.imp"), weight = "poids")
#' result <- tabs(hdv2003, x = "relig", y = c("qualif", "trav.imp"), type = "counts")
#' format(result, digits = 3)
#' # library(knitr)
#' # xt <- tabs(hdv2003, x = "relig", y = c("qualif", "trav.imp"), weight = "poids")
#' # kable(format(xt))                        # to use with RMarkdown...
#' 
#' @export

`tabs` <- function(df, x, y, 
                   type = "percent", percent = FALSE,
                   weight = NULL, normwt = FALSE, 
                   na.rm = TRUE, na.show = FALSE, exclude = NULL, digits = 1){
  
  sumOne <- function(x, ...) x/sum(x, ...)
  
  if (!(type %in% c("percent", "proportion", "counts"))) {
    stop("type must either be 'percent', 'proportion', or 'counts'.")
  }
  
  if (!inherits(df, "data.frame")) {
    stop("df must be a data.frame")
  }

  if (!(x %in% names(df))) {
    stop(paste(x, 'not found in data frame.'))
  }            
  if (min(match(y, names(df), nomatch = 0L)) == 0L) {
    stop(paste(y, 'not found in data frame.'))
  } 
  if (!is.null(weight) && !(weight %in% names(df))) {
    stop(paste(weight, 'not found in data frame.'))
  } 

  w <- if (is.null(weight)) NULL else df[[weight]]
  
  result <- wtd.table(df[[x]], y = NULL, weights = w, 
                     normwt = normwt, na.rm = na.rm, na.show = na.show, exclude = exclude)
  if (type %in% c("percent", "proportion")) {
    result <- sumOne(result, na.rm = na.rm)
  }

  for (v in y) {
    tmp <- wtd.table(df[[x]], df[[v]], weights = w, 
                     normwt = normwt, na.rm = na.rm, na.show = na.show, exclude = exclude)
    if (type %in% c("percent", "proportion")) tmp <- sumOne(tmp, na.rm = na.rm)
    result <- cbind(result, tmp)
  }
  if (type == "percent") {
    result <- 100 * result
  }
  
  colnames(result)[1] <- gettext("Overall", domain = "R-questionr")
  class(result) <- c("proptab", class(result))

  attr(result, "percent") <- percent
  if (type != "percent") {
    attr(result, "percent") <- FALSE
  }
  attr(result, "digits") <- digits

  return(result)   
  
}




