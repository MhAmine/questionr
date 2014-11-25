##' One-way frequency table for multiple choices question
##'
##' This function allows to generate a frequency table from a multiple choices question.
##' The question's answers must be stored in a series of binary variables.
##' 
##' @param df data frame with the binary variables
##' @param true.codes optional list of values considered as 'true' for the tabulation
##' @param weights optional weighting vector
##' @param digits number of digits to keep in the output
##' @param freq add a percentage column 
##' @details
##' The function is applied to a series of binary variables, each one corresponding to a
##' choice of the question. For example, if the question is about seen movies among a movies
##' list, each binary variable would correspond to a movie of the list and be true or false
##' depending of the choice of the answer.
##'
##' By default, only '1' and 'TRUE' as considered as 'true' values fro the binary variables,
##' and counted in the frequency table. It is possible to specify other values to be counted
##' with the \code{true.codes} argument. Note than '1' and 'TRUE' are always considered as
##' true values even if \code{true.codes} is provided.
##' 
##' If \code{freq} is set to TRUE, a percentage column is added to the resulting table. This
##' percentage is computed by dividing the number of TRUE answers for each value by the total
##' number of (potentially weighted) observations. Thus, these percentages sum can be greater
##' than 100.
##'
##' @return Object of class table.
##' @seealso \code{\link[questionr]{cross.multi.table}}, \code{\link[questionr]{multi.split}}, \code{\link{table}}
##' @examples
##' ## Sample data frame
##' set.seed(1337)
##' sex <- sample(c("Man","Woman"),100,replace=TRUE)
##' jazz <- sample(c(0,1),100,replace=TRUE)
##' rock <- sample(c(TRUE, FALSE),100,replace=TRUE)
##' electronic <- sample(c("Y","N"),100,replace=TRUE)
##' weights <- runif(100)*2
##' df <- data.frame(sex,jazz,rock,electronic,weights)
##' ## Frequency table on 'music' variables
##' multi.table(df[,c("jazz", "rock","electronic")], true.codes=list("Y"))
##' ## Weighted frequency table on 'music' variables
##' multi.table(df[,c("jazz", "rock","electronic")], true.codes=list("Y"), weights=df$weights)
##' ## No percentages
##' multi.table(df[,c("jazz", "rock","electronic")], true.codes=list("Y"), freq=FALSE)
##' @export

multi.table <- function(df, true.codes=NULL, weights=NULL, digits=1, freq=TRUE) {
  true.codes <- c(as.list(true.codes), TRUE, 1)
  res <- as.table(sapply(df, function(v) {
    sel <- as.numeric(v %in% true.codes)
    if (!is.null(weights)) sel <- sel * weights
    sum(sel)
  }))
  if (freq) {
    if (!is.null(weights)) total <- sum(weights)
    else total <- nrow(df)
    pourc <- res / total * 100
    res <- cbind(res, pourc)
    colnames(res) <- c("n","%multi")
  }
  res <- round(res, digits)
  return(res)
}

##' Two-way frequency table between a multiple choices question and a factor
##'
##' This function allows to generate a two-way frequency table from a multiple
##' choices question and a factor. The question's answers must be stored in a
##' series of binary variables.
##' 
##' @param df data frame with the binary variables
##' @param crossvar factor to cross the multiple choices question with
##' @param weights optional weighting vector
##' @param ... arguments passed to \code{multi.table}
##' @details
##' See the \code{multi.table} help page for details on handling of the multiple
##' choices question and corresponding binary variables.
##'
##' @return Object of class table.
##' @seealso \code{\link[questionr]{multi.table}}, \code{\link[questionr]{multi.split}}, \code{\link{table}}
##' @examples
##' ## Sample data frame
##' set.seed(1337)
##' sex <- sample(c("Man","Woman"),100,replace=TRUE)
##' jazz <- sample(c(0,1),100,replace=TRUE)
##' rock <- sample(c(TRUE, FALSE),100,replace=TRUE)
##' electronic <- sample(c("Y","N"),100,replace=TRUE)
##' weights <- runif(100)*2
##' df <- data.frame(sex,jazz,rock,electronic,weights)
##' ## Two-way frequency table on 'music' variables by sex
##' cross.multi.table(df[,c("jazz", "rock","electronic")], df$sex, true.codes=list("Y"))
##' @export
 
cross.multi.table <- function(df, crossvar, weights=NULL, ...) {
  tmp <- factor(crossvar)
  if(is.null(weights))
      return(simplify2array(by(df, tmp, multi.table, ...)))
  else {
      ## (Not very elegant) fix when weights is provided
      df <- cbind(weights, df)
      res <- by(df, tmp, function(d) {
          tmpw <- d[,1]
          tmpd <- d[,-1]
          multi.table(tmpd, weights=tmpw, ...)
      })
      return(simplify2array(res))
  }
}

##' Split a multiple choices variable in a series of binary variables
##'
##' 
##' @param var variable to split
##' @param split.char character to split at
##' @param mnames names to give to the produced variabels. If NULL, the name are computed from the original variable name and the answers.
##' @details
##' This function takes as input a multiple choices variable where choices
##' are recorded as a string and separated with a fixed character. For example,
##' if the question is about the favourite colors, answers could be "red/blue",
##' "red/green/yellow", etc. This function splits the variable into as many variables
##' as the number of different choices. Each of these variables as a 1 or 0 value
##' corresponding to the choice of this answer. They are returned as a data frame.
##' ##' @return Returns a data frame.
##' @seealso \code{\link[questionr]{multi.table}}
##' @examples
##' v <- c("red/blue","green","red/green","blue/red")
##' multi.split(v)
##' ## One-way frequency table of the result
##' multi.table(multi.split(v))
##' @export

multi.split <- function (var, split.char="/", mnames = NULL) {
  vname <- deparse(substitute(var))
  lev <- levels(factor(var))
  lev <- unique(unlist(strsplit(lev, split.char)))
  if (is.null(mnames)) 
    mnames <- gsub(" ", "_", paste(vname, lev, sep = "."))
  else mnames <- paste(vname, mnames, sep = ".")
  result <- matrix(data = 0, nrow = length(var), ncol = length(lev))
  char.var <- as.character(var)
  for (i in 1:length(lev)) {
    result[grep(lev[i], char.var, fixed = TRUE), i] <- 1
  }
  result <- data.frame(result)
  colnames(result) <- mnames
  result
}
