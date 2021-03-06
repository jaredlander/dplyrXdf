% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tbl_xdf.R
\name{tbl.RxXdfData}
\alias{hasTblFile}
\alias{tbl.RxFileData}
\alias{tbl.RxXdfData}
\alias{tblFile}
\alias{tblSource}
\title{Create a tbl from an Xdf file}
\usage{
\method{tbl}{RxXdfData}(data, file = NULL, hasTblFile = FALSE, ...)

\method{tbl}{RxFileData}(data, file = newTbl(data), hasTblFile = TRUE,
  stringsAsFactors = TRUE, ...)

tblFile(x)

tblSource(x)

hasTblFile(x)
}
\arguments{
\item{data}{A data source object, representing an Xdf file or another type of data file on disk. Only file data sources are supported (Xdf, SAS, SPSS, delimited text).}

\item{file}{The file to use as working storage. If \code{NULL}, a new file will be created in the R working directory when results need to be saved. Cannot be \code{NULL} for non-Xdf data sources.}

\item{hasTblFile}{Logical, has the tbl's working file been created yet?}

\item{...}{Other arguments that will be passed to \code{rxDataStep}.}

\item{stringsAsFactors}{for non-Xdf data sources, whether to import character variables as factors. Defaults to TRUE.}

\item{x}{A file data source, or a tbl wrapping the same.}
}
\value{
The \code{tbl} function returns an object of S4 class \code{tbl_xdf}, which extends \code{RxXdfdata}.

The \code{tblFile} function returns the location where the intermediate and final results of a dplyr pipeline will be stored. If the tbl has not had any results written to it yet, or if this function is called on a non-tbl data source, a random filename is returned. The \code{tblSource} function is similar but returns a full data source, encapsulating file system information.

The \code{tblFile} is deprecated; \code{tblSource} is preferred as it retains information about the file system and other parameters of the original data source.

The \code{hasTblFile} function returns TRUE if a tbl has a temporary file assigned to it (which also implies that it contains results from previous dplyr pipeline steps). It returns FALSE if no temporary file has yet been assigned, or if it is called on a non-tbl data source.
}
\description{
Create a tbl from an Xdf file
}
\details{
A tbl wraps a RevoScaleR data source, allowing you to carry out data manipulation operations without modifying the source itself. It does this by copying the data to a temporary file, normally at the first point where the data is accessed. Usually you can let dplyrXdf create the temporary file for you; this saves time by avoiding unnecessary copying. However, if you specify a filename as an explicit argument to \code{tbl}, it will create that file using \code{rxDataStep} to copy the data from the source Xdf.

As a side-effect, any datasets created in a dplyrXdf pipeline will be lost when you close your R session. If you want to keep the pipeline results, make sure you copy them to a permanent location on disk.

By default, running \code{tbl} on a non-Xdf data source will convert any character variables to factors. This is the opposite of the usual behaviour for RevoScaleR functions that read non-Xdf data, and is for performance reasons: using factors instead of character variables can speed up functions like \code{\link[RevoScaleR]{rxCube}} and \code{\link[RevoScaleR]{rxSummary}} by significant margins.
}
\section{Note}{

Many RevoScaleR functions that work with Xdf files will accept either an \code{RxXdfData} object, a character string giving the location of the file, or a data frame. The functions listed here only accept an \code{RxXdfData} object, or a tbl object wrapping the same.
}
\seealso{
\code{\link[dplyr]{tbl}}, \code{\link[RevoScaleR]{RxXdfData}}
}

