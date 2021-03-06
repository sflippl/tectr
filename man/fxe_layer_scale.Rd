% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fx-fun-ggplot-aaa-scale.R
\docType{methods}
\name{fxe_layer_scale}
\alias{fxe_layer_scale}
\alias{fxe_layer_scale,fxGeom,AesName-method}
\alias{fxe_layer_scale,fxGeomContinuous,AesName-method}
\alias{fxe_layer_scale,fxGeomDiscrete,AesName-method}
\title{Effex External: Scale layers}
\usage{
fxe_layer_scale(fx_geom, aes_name, ...)

\S4method{fxe_layer_scale}{fxGeom,AesName}(fx_geom, aes_name, data,
  fxGeom_title = NULL, name = "", ...)

\S4method{fxe_layer_scale}{fxGeomContinuous,AesName}(fx_geom, aes_name,
  data, fxGeom_breaks = NULL, fxGeom_minor_breaks = NULL,
  fxGeom_labels = NULL, fxGeom_expand.add = NULL,
  fxGeom_expand.mult = NULL, fxGeom_na.value = NULL,
  fxGeom_trans = "identity", fxGeom_limits = NULL,
  fxGeom_pal.x_y = NULL, fxGeom_pal.alpha = NULL,
  fxGeom_pal.colour_fill = NULL, fxGeom_pal.size = NULL, ...)

\S4method{fxe_layer_scale}{fxGeomDiscrete,AesName}(fx_geom, aes_name, data,
  fxGeom_breaks = NULL, fxGeom_limits = NULL, fxGeom_drop = NULL,
  fxGeom_na.translate = NULL, fxGeom_labels = NULL,
  fxGeom_expand.add = NULL, fxGeom_expand.mult = NULL,
  fxGeom_pal.x_y = NULL, fxGeom_pal.colour_fill = NULL,
  fxGeom_pal.shape = NULL, ...)
}
\arguments{
\item{fx_geom}{An S4 class argument which inherits from \linkS4class{fxGeom}.}

\item{aes_name}{An S4 class argument which inherits from \linkS4class{AesName}.}

\item{fxGeom_title}{\code{NULL} or a character that provides the title}
}
\description{
This function provides an extendible scheme for scales for a single layer.
If some features are to be added, it is often sensible to \code{callNextMethod()}
and then add these features.
}
\section{Methods}{

\itemize{
\item \code{fx_geom = fxGeom(), aes_name = AesName()}: Adds labels and limits
}


\itemize{
\item \code{fx_geom = fxGeom("Continuous"), aes_name = AesName("")}
}


\itemize{
\item \code{fx_geom = fxGeom("Discrete"), aes_name = AesName("")}
}
}

