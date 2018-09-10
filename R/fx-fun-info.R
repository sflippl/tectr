#' Effex Function: Information
#'
#' This function provides versatile information on the different variables.
#' [fx_output()] turns this information into a string.
#'
#' @param data A dataframe, possibly with a metaframe
#' @param topic The topic of the information
#' @param arguments for the information methods
#'
#' @export

fx_info <- function(data, topic, ...) {
  data <- data %>%
    fx_default(columns = fx_info_columns) %>%
    fx_evaluate()
  assertthat::assert_that(is.character(topic))
  lst <- purrr::map(topic, function(top) fxext_info(data, fxd("info", top), ...))
  purrr::reduce(lst, ~ dplyr::inner_join(.x, .y, by = "name"))
}

#' Effex Externals: Information
#'
#' This generic powers [fx_info()]. A new topic can be supplied by providing a
#' method for the class "fxd_info_<topic>".
#'
#' @inheritParams fx_info
#'
#' @export

fxext_info <- function(data, topic, ...) UseMethod("fxext_info", topic)

#' @rdname fxext_info
#'
#' @export

fxext_info.fxd_info <- function(data, topic, ...) {
  colname <- paste0("fxInfo_", fxd_subclass(topic))
  if(colname %in% names(metaframe(data))) {
    coltitle <-
      stringr::str_to_title(stringr::str_replace_all(fxd_subclass(topic),
                                                     stringr::coll("_"), " "))
    mf <- metaframe(data)
    mf[[coltitle]] <- mf[[colname]]
    return(dplyr::select(mf, name, !!coltitle))
  }
  stop("No method for topic ", fxd_subclass(topic), "provided")
}