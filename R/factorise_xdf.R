#' Convert columns in an Xdf file to factor
#'
#' @param .data A data source.
#' @param ... Variables to convert to factors.
#' @param .dots Used to work around non-standard evaluation. See the dplyr vignettes for details.
#'
#' @details
#' The selector functions listed in \code{\link[dplyr]{select}} also work with \code{factorise}. In addition, you can use the following:
#' \itemize{
#'  \item \code{all_character()}: selects all character variables
#'  \item \code{all_integer()}: selects all integer variables, ie those of type \code{"logical"} and \code{"integer"}
#'  \item \code{all_numeric()}: selects all numeric variables, ie those of type \code{"numeric"}, \code{"Date"}, \code{"POSIXct"}, \code{"logical"} and \code{"integer"}
#' }
#' If no variables are specified, all character variables will be converted to factors.
#'
#' You can specify the levels for a variable by specifying them as the value of the argument. For example, \code{factorise(*, x = c("a","b","c"))} will turn the variable \code{x} into a factor with three levels \code{a}, \code{b} and \code{c}. Any values that don't match the set of levels will be turned into NAs. In particular, this means you should include the existing levels for variables that are already factors.
#'
#' For performance reasons, factors created by \code{factorise} are not sorted; instead, the ordering of their levels will be determined by the order in which they are encountered in the data.
#'
#' The method for \code{RxXdfData} objects is a shell around \code{\link[RevoScaleR]{rxFactors}}, which is the standard RevoScaleR function for factor manipulation. For \code{RxFileData} objects, the method calls \code{\link[RevoScaleR]{rxImport}} with an appropriately constructed \code{colInfo} argument.
#'
#' @seealso
#' \code{\link[RevoScaleR]{rxFactors}}, \code{\link[RevoScaleR]{rxImport}}, \code{\link{factor}}
#'
#' \code{\link{chol}}, \code{\link{qr}}, \code{\link{svd}} for the other meaning of factorise
#' @rdname factorise
#' @export
factorise <- function(.data, ...)
{
    factorise_(.data, .dots=lazyeval::lazy_dots(...))
}


#' @rdname factorise
#' @export
factorize <- factorise


#' @rdname factorise
#' @export
factorise_ <- function(.data, ..., .dots)
{
    UseMethod("factorise_")
}


#' @rdname factorise
#' @export
factorize_ <- factorise_


#' @rdname factorise
#' @export
factorise_.RxXdfData <- function(.data, ..., .dots)
{
    dots <- lazyeval::all_dots(.dots, ..., all_named=TRUE)

    # identify Revo-specific arguments
    dots <- .rxArgs(dots)
    rxArgs <- dots$rxArgs
    exprs <- dots$exprs

    grps <- groups(.data)
    types <- varTypes(.data)
    vars <- factorise_vars(types, exprs)

    factorInfo <- c(
        sapply(vars$blankArgs, function(nam) list(varName=nam), simplify=FALSE),
        sapply(names(vars$newlevelArgs), function(nam) {
            levs <- vars$newlevelArgs[[nam]]
            if(types[nam] == "factor")
                list(newLevels=levs)
            else list(levels=levs)
        }, simplify=FALSE)
    )
    oldData <- tblSource(.data)
    if(hasTblFile(.data))
        on.exit(deleteTbl(oldData))

    cl <- quote(rxFactors(.data, factorInfo, outFile=newTbl(.data)))
    cl[names(rxArgs)] <- rxArgs

     # rxFactors is noisy when given already-existing factors; shut it up
    .data <- suppressWarnings(tbl(eval(cl), hasTblFile=TRUE))
    if(!is.null(grps))
        group_by_(.data, .dots=grps)
    else .data
}


#' @rdname factorise
#' @export
factorise_.RxFileData <- function(.data, ..., .dots)
{
    dots <- lazyeval::all_dots(.dots, ..., all_named=TRUE)

    # identify Revo-specific arguments
    dots <- .rxArgs(dots)
    rxArgs <- dots$rxArgs
    exprs <- dots$exprs

    grps <- groups(.data)
    types <- varTypes(.data)
    vars <- factorise_vars(types, exprs)

    colInfo <- sapply(names(.data), function(x) {
        if(x %in% names(vars$blankArgs))
            list(type="factor")
        else if(x %in% names(vars$newlevelArgs))
            list(type="factor", levels=as.character(vars$newlevelArgs[[x]]))
        else list(type=types[x])
    }, simplify=FALSE)

    oldData <- tblSource(.data)
    if(hasTblFile(.data))
        on.exit(deleteTbl(oldData))

    cl <- quote(rxImport(.data, newTbl(.data), colInfo=colInfo))
    cl[names(rxArgs)] <- rxArgs

    .data <- tbl(eval(cl), hasTblFile=TRUE)
    if(!is.null(grps))
        group_by_(.data, .dots=grps)
    else .data
}


factorise_vars <- function(types, args)
{
    # extra selection functions
    selectionFuncs <- list(
        all_character=function(...) vars[types %in% "character"],
        all_numeric=function(...) vars[types %in% c("numeric", "logical", "integer")],
        all_integer=function(...) vars[types %in% c("logical", "integer")]
    )

    vars <- names(types)
    if(length(args) == 0)
        return(list(blankArgs=selectionFuncs$all_character(), newlevelArgs=NULL))

    # do blank arguments and arguments specifying new factor levels separately
    # unlike select, named arguments always treated as specifying factor levels, not indices
    # blank arguments can also include variable selector functions
    isBlankArgs <- sapply(names(args), function(n) {
        e <- args[[n]]
        is.name(e) || deparse(e) == n || as.character(e[[1]]) %in% c("all_character", "all_numeric", "all_integer",
                                                                     "starts_with", "ends_with", "contains", "matches",
                                                                     "one_of", "everything")
    })
    blankArgs <- args[isBlankArgs]
    newlevelArgs <- args[!isBlankArgs]

    newArgs <- list()
    for(i in seq_along(blankArgs))
    {
        arg <- blankArgs[[i]]
        i <- match(deparse(arg), names(selectionFuncs), nomatch=0)
        if(i > 0)
        {
            arg <- lazyeval::as.lazy_dots(selectionFuncs[[i]]())
            newArgs <- c(newArgs, arg)
        }
        else newArgs <- c(newArgs, list(arg))
    }
    blankArgs <- select_vars_(vars, newArgs)
    newlevelArgs <- lapply(newlevelArgs, eval)

    list(blankArgs=blankArgs, newlevelArgs=newlevelArgs)
}

