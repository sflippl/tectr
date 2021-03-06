% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/a-fx-obj-aesName.R
\docType{class}
\name{AesName-class}
\alias{AesName-class}
\alias{.AesName}
\alias{xAesName-class}
\alias{.xAesName}
\alias{yAesName-class}
\alias{.yAesName}
\alias{alphaAesName-class}
\alias{.alphaAesName}
\alias{colourAesName-class}
\alias{.colourAesName}
\alias{fillAesName-class}
\alias{.fillAesName}
\alias{groupAesName-class}
\alias{.groupAesName}
\alias{shapeAesName-class}
\alias{.shapeAesName}
\alias{sizeAesName-class}
\alias{.sizeAesName}
\alias{strokeAesName-class}
\alias{.strokeAesName}
\alias{geomAesName-class}
\alias{.geomAesName}
\alias{facetAesName-class}
\alias{.facetAesName}
\alias{AesName}
\title{AesName}
\usage{
AesName(aes)
}
\arguments{
\item{aes}{The aes. If a subclass "<aes>AesName" exists, this will be
instantiated.}
}
\description{
AesName is a very small class that allows for flexible inheritance of
\code{fxext_<>}-functions (e. g. \code{\link[=fx_ext_layer_single]{fx_ext_layer_single()}}). Whereas any name may be
used, the available subclasses are:

\itemize{
\item x
}

\itemize{
\item y
}

\itemize{
\item alpha
}

\itemize{
\item colour
}

\itemize{
\item fill
}

\itemize{
\item group
}

\itemize{
\item shape
}

\itemize{
\item size
}

\itemize{
\item stroke
}

\itemize{
\item geom
}

\itemize{
\item facet (this is, of course not an actual aesthetics but it has
tasks that are similar enough)
}
}
\details{
If other aesthetics are supplied, most methods default to a neutral
element, e. g. \code{identity} in the case of \code{\link[=fx_ggplot]{fx_ggplot()}}. You can build
\code{AesName} by calling the function and you can set its subclasses by
\code{new("<subclass>AesName", ...)}. This is, however, not recommended. It is
better to use the \code{aes} argument in \code{\link[=AesName]{AesName()}}, as it defaults to generating
\code{AesName} if the \code{aes} is unknown.
}
\examples{
AesName(aes = "x")
AesName(aes = "m")
AesName(aes = "colour")

}
