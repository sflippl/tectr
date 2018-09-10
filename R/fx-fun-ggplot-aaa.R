#' Effex Function: Visualization
#'
#' This function creates an effectively and explicitly specified visualization
#' of several variables in line with the syntax of [ggplot2].
#'
#' Required columns in the metaframe:
#'
#' * `fxGeom_class`: What class does the geometry have?
#'
#' Columns that are used:
#'
#' * `fxGeom_nominations`: A list of nominations (see
#' [fxint_layer_complete()])
#' * `fxGeom_veto`: A function that is given a nomination and returns a logical
#' value whether to veto this nomination
#' * `fxGeom_vote`: A function that returns the amount of votes for a certain
#' nomination
#'
#' @param data A dataframe with [metaframe()] as an attribute
#' @param mapping An aesthetic mapping
#' @param ... Parameters to give on to [fx_default()]
#'
#' @export

fx_ggplot <- function(data, mapping, ...) {
  data <- fx_default(data, columns = fx_ggplot_columns)
  layers <- c(
    # At first, we add the geometric information along one dimension
    purrr::map(names(mapping), ~ fxint_layer_single(data, mapping, .)) %>%
      unlist(recursive = FALSE),
    # Then, we add the geometric information that is dependent on all dimensions
    fxint_layer_complete(data, mapping)
  )
  ggplot(data, mapping) + layers
}

#' Effex Internals: `fx-ggplot` - geometric information along one dimension

fxint_layer_single <- function(data, mapping, nam) {
  mf <- metaframe(data) %>%
    dplyr::filter(name == as.character(rlang::quo_get_expr(mapping[[nam]])))
  assertthat::assert_that(nrow(mf) == 1, "fxGeom_class" %in% colnames(mf))
  fx_geom <- fxGeom(mf[["fxGeom_class"]])
  aes_name <- AesName(nam)
  mf <- lst_mf_args(mf)
  do.call(
    fxext_layer_single,
    rlang::list2(fx_geom, aes_name, data = data, rlang::splice(mf))
  )
}

#' Effex Extendibles: `fx-ggplot` - geometric information along one dimension
#'
#' This is the extendible function for the single layer. It is dispatched
#' along the arguments `fx_geom` and `aes_name`. Arbitrary other arguments may
#' be added that should then be expected in the metaframe. It should always be
#' considered a possibility that these values are missing.
#'
#' @export

setGeneric(
  "fxext_layer_single",
  function(fx_geom, aes_name, data, ...) standardGeneric("fxext_layer_single")
)

#' @export
#'
#' @param fx_geom the [fxGeom()] object
#' @param aes_name the [aesName()] object
#'
#' @rdname fxext_layer_single

setMethod(
  "fxext_layer_single",
  signature = c(fx_geom = "fxGeom", aes_name = "AesName"),
  function(fx_geom, aes_name, data, ...) {
    args <- rlang::list2(fx_geom = fx_geom, aes_name = aes_name, data = data,
                         ...)
    c(do.call("fxext_layer_scale", args), do.call("fxext_layer_other", args))
  }
)

#' Effex Internals: `fx_ggplot` - combine all different dimensions
#'
#' This function generates the function to add an arbitrary number of layers
#' that depend on all specified layers.
#'
#' `fxint_layer_complete` is driven by three extendible functions (see
#' [?fxext_layer_complete_nominate()](here)):
#'
#' * `fxext_layer_complete_nominate` gathers the nominations
#' * `fxext_layer_complete_veto` collects the vetoes
#' * `fxext_layer_complete_vote` collects the votes
#'
#' @param data the data with the metaframe
#' @param mapping the aesthetic mapping

fxint_layer_complete <- function(data, mapping) {
  mf <- metaframe(data) %>%
    dplyr::mutate(name = as.character(name)) %>%
    dplyr::inner_join(
      dplyr::tibble(aes = names(mapping), name = get_inds(mapping)),
      by = "name")
  assertthat::assert_that("fxGeom_class" %in% colnames(mf))
  nominations <- fxint_layer_complete_nominate(data, mf)
  # Remove layers without the required aesthetics - not possible for now.
  # Removing duplicates does not make sense because every layer is a reference
  # class and therefore unique.
  # Veto the inapplicable nominees and give the other nominees the corresponding
  # votes.
  chosen_nomination <- fxint_layer_complete_vote(nominations, mf) %>%
    unlist(recursive = FALSE)
  chosen_nomination
}

#' @describeIn fxint_layer_complete Gathers the nominations.

fxint_layer_complete_nominate <- function(data, mf) {
  lst_fxGeom <- purrr::map(mf[["fxGeom_class"]], fxGeom)
  lst_aesName <- purrr::map(mf[["aes"]], AesName)
  nominations <- list()
  for(i in seq_len(nrow(mf))) {
    # Prepare any other arguments for splicing
    mf_args <- dplyr::select(mf[i, ], -aes) %>% lst_mf_args()
    # Let each aesthetic nominate its potential candidates
    new_nominations <- do.call("fxext_layer_complete_nominate",
                              rlang::list2(fx_geom = lst_fxGeom[[i]],
                                           aes_name = lst_aesName[[i]],
                                           data = data,
                                           !!!mf_args))
    purrr::walk(new_nominations, ~ assertthat::assert_that(is_nomination(.)))
    nominations <- c(nominations, new_nominations)
  }
  nominations
}

#' @describeIn fxint_layer_complete vetoes (via `fxext_layer_complete_veto`)
#' and then votes (via `fxext_layer_complete_vote`) for the nominations

fxint_layer_complete_vote <- function(nominations, mf) {
  lst_fxGeom <- purrr::map(mf[["fxGeom_class"]], fxGeom)
  lst_aesName <- purrr::map(mf[["aes"]], AesName)
  assertthat::assert_that(length(nominations) != 0,
                          msg = "No nominations have been provided.")

  # Vetoes ----

  lgl_veto <- FALSE
  for(i in seq_len(nrow(mf))) {
    mf_args <- dplyr::select(mf[i, ], -aes) %>%
      rlang::as_list(.) %>%
      purrr::map(1)
    lgl_veto <- lgl_veto |
      purrr::map_lgl(
      nominations,
      ~ do.call("fxext_layer_complete_veto",
                rlang::list2(nomination = ., fx_geom = lst_fxGeom[[i]],
                             aes_name = lst_aesName[[i]], data = data,
                             !!!mf_args))
    )
  }
  nominations <- nominations[!lgl_veto]

  assertthat::assert_that(length(nominations) != 0,
                          msg = "Aesthetics incompatible.")

  # Votes ----

  votes <- rep(0, length(nominations))

  for(i in seq_len(nrow(mf))) {
    mf_args <- dplyr::select(mf[i, ], -aes) %>%
      rlang::as_list(.) %>%
      purrr::map(1)
    votes <- votes +
      purrr::map_dbl(
        nominations,
        ~ do.call("fxext_layer_complete_vote",
                  rlang::list2(nomination = ., fx_geom = lst_fxGeom[[i]],
                               aes_name = lst_aesName[[i]], data = data,
                               !!!mf_args))
      )
  }
  max_votes <- which(votes == max(votes))
  max_vote <- max_votes[1]
  nominations[[max_vote]]
}

#' Get names from a mapping

get_inds <- function(x) {
  purrr::map_chr(x, ~ as.character(rlang::quo_get_expr(.)))
}

#' Filter according to the required aesthetics
#'
#' If the required aesthetics cannot be either found in the mapping or in the
#' mapping of the object itself, remove the layers nomination.
#'
#' This function is superfluous for now, see [required_aes()].

filter_req_aes <- function(nominations, mapping) {
  has_req_aes <- purrr::map_lgl(
    nominations,
    ~ all(purrr::map_lgl(c(names(mapping), .$mapping) %in% required_aes(.))
    )
  )
  nominations[has_req_aes]
}

#' Effex Extendibles: `fx_ggplot` - nominate layers
#'
#' These functions drive [fxint_layer_complete()]. Provided that they fulfill
#' certain conditions they can be extended.
#'
#' @details
#' `fxext_layer_complete_nominate` returns a list of
#' [nomination()](layer nominations). The default returns either an empty
#' list or, if provided the element of the metaframe column
#' `fxGeom_nominations`.
#'
#' @seealso [fxint_layer_complete()]
#'
#' @export

setGeneric("fxext_layer_complete_nominate",
           function(fx_geom, aes_name, data, ...)
             standardGeneric("fxext_layer_complete_nominate"))

#' @export
#'
#' @rdname fxext_layer_complete_nominate

setMethod("fxext_layer_complete_nominate",
          signature = c(fx_geom = "fxGeom", aes_name = "AesName"),
          function(fx_geom, aes_name, data, ..., fxGeom_nominations = NULL) {
            if(is.null(fxGeom_nominations))
              fxGeom_nominations <- list()
            assertthat::assert_that(is.list(fxGeom_nominations))
            purrr::walk(fxGeom_nominations, is_nomination)
            fxGeom_nominations
          })

#' @rdname fxext_layer_complete_nominate
#'
#' @param nomination a [nomination()]
#'
#' @details
#' `fxext_layer_complete_veto` returns a logical value that indicates whether
#' this layer should be vetoed, i. e. removed from the nominations list. The
#' default method returns either `FALSE` or, if supplied with an element of the
#' metaframe column, it applies that function.
#'
#' @export

setGeneric("fxext_layer_complete_veto",
           function(nomination, fx_geom, aes_name, data, ...)
             standardGeneric("fxext_layer_complete_veto"))

#' @export
#'
#' @rdname fxext_layer_complete_veto

setMethod("fxext_layer_complete_veto",
          signature = c(fx_geom = "fxGeom", aes_name = "AesName"),
          function(nomination, fx_geom, aes_name, data, ...,
                   fxGeom_veto = NULL) {
            if(is.null(fxGeom_veto)) return(FALSE)
            assertthat::assert_that(is.function(fxGeom_veto))
            fxGeom_veto(nomination = nomination, ...)
          })

#' @rdname fxext_layer_complete_nominate
#'
#'

setGeneric("fxext_layer_complete_vote",
           function(nomination, fx_geom, aes_name, data, ...)
             standardGeneric("fxext_layer_complete_vote"))

#' @export
#'
#' @rdname fxext_layer_complete_vote

setMethod("fxext_layer_complete_vote",
          signature = c(fx_geom = "fxGeom", aes_name = "AesName"),
          function(nomination, fx_geom, aes_name, data, ...,
                   fxGeom_vote = NULL) {
            if(is.function(fxGeom_vote))
              return(fxGeom_vote(nomination, fx_geom = fx_geom,
                                  aes_name = aes_name, data = data))
            assertthat::assert_that(
              is.null(fxGeom_vote),
              msg = "fxGeom_vote must by type NULL or function."
            )
            0
          })