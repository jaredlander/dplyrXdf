% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tbl_xdf.R
\name{deleteXdfTbls}
\alias{deleteXdfTbls}
\title{Delete data files for xdf tbls}
\usage{
deleteXdfTbls(path = tempdir())
}
\arguments{
\item{path}{Directory where the files are located. Defaults to the R temporary directory.}
}
\description{
Delete data files for xdf tbls
}
\details{
This is a utility function to delete the files generated by dplyrXdf. By default, these files are located in the R temporary directory. Note that all xdf files in the specified location will be removed!
}

