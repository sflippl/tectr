#' @export
#'
#' @param fxGeom_assoc_vars The associated variables (for instance, confidence
#' intervals, marked by the aesthetics upper and lower, and grouping variables)
#' @param fxGeom_errorbar.threshold The maximum number of data points for
#' depicting error bars
#'
#' @rdname fxe_layer_complete_nominate
#'     + a line plot together with a shaded area for the confidence
#'     interval (the borders of the interval are given by the aesthetics upper
#'     and lower in fxGeom_assoc_vars)
#'     + a scatter plot with uncertainty lines

setMethod("fxe_layer_complete_nominate",
          signature = c(fx_geom = "fxGeomContinuousCI", aes_name = "yAesName"),
          function(fx_geom, aes_name, data, ...,
                   fxGeom_assoc_vars = NULL, fxGeom_errorbar.threshold = NULL) {
            nxt <- fxe_layer_complete_nominate(
              fxGeom("Continuous"),
              aes_name,
              data, ...)
            if(is.null(fxGeom_errorbar.threshold))
              fxGeom_errorbar.threshold <- 200
            n_row <- nrow(data)
            upper_quo <- fxGeom_assoc_vars[["upper"]]
            lower_quo <- fxGeom_assoc_vars[["lower"]]
            new_mapping <- ggplot2::aes()
            bool_errorbar <- FALSE
            # if high and low mappings are well defined, define them and set
            # bool_errorbar to true.
            grouping_quo <- fxGeom_assoc_vars[["group"]]
            if(is.null(grouping_quo)) {
              n_groups <- 1
              group_mapping <- ggplot2::aes()
            }
            else {
              grouping_var <-
                grouping_quo %>%
                rlang::quo_get_expr() %>%
                as.character()
              if(grouping_var %in% names(data)) {
                n_groups <-
                  data[[grouping_var]] %>%
                  unique() %>%
                  length()
                group_mapping <- fxGeom_assoc_vars["group"]
              }
              else {
                n_groups <- 1
                group_mapping <- ggplot2::aes()
              }
            }
            if(!is.null(upper_quo)) {
              upper_var <-
                  upper_quo %>%
                  rlang::quo_get_expr() %>%
                  as.character()
              if(upper_var %in% names(data)) {
                if(!is.null(lower_quo)) {
                  lower_var <-
                      lower_quo %>%
                      rlang::quo_get_expr() %>%
                      as.character()
                  if(lower_var %in% names(data)) {
                    new_mapping <-
                      fxGeom_assoc_vars[c("upper", "lower")] %>%
                      magrittr::set_names(c("ymax", "ymin")) %>%
                      c(ggplot2::aes(fill = NULL, colour = NULL),
                        group_mapping)
                    class(new_mapping) <- "uneval"
                    bool_errorbar <- TRUE
                  }
                }
              }
            }
            if(bool_errorbar) {
              ci_nom <-
                list(
                  nomination(
                    ggplot2::geom_line(group_mapping),
                    ggplot2::geom_ribbon(new_mapping, alpha = 0.1)
                  ),
                  nomination(
                    ggplot2::geom_step(group_mapping, na.rm = TRUE),
                    ggplot2::geom_ribbon(new_mapping, alpha = 0.1)
                  )
                )
            }
            else
              ci_nom <- NULL
            if(bool_errorbar & n_row < fxGeom_errorbar.threshold) {
              errorbar_nom <-
                list(
                  nomination(
                    ggplot2::geom_point(),
                    ggplot2::geom_linerange(mapping = new_mapping)
                  )
                )
            }
            else
              errorbar_nom <- NULL
            c(ci_nom, errorbar_nom, nxt)
          })

#' @export
#'
#' @describeIn fxe_layer_complete_vote
#'     + line plot with shaded confidence intervals: 2
#'     + [ggplot2::geom_linerange()]: 3

setMethod("fxe_layer_complete_vote",
          signature = c(fx_geom = "fxGeomContinuousCI", aes_name = "yAesName"),
          function(nomination, fx_geom, aes_name, data, ...) {
            nxt <- fxe_layer_complete_vote(
              nomination, fxGeom("Continuous"), aes_name, data, ...)
            bool_ribbon <-
              nomination %>%
              nom_layers() %>%
              purrr::map_lgl( ~ inherits(.$geom, "GeomRibbon")) %>%
              any
            bool_linerange <-
              nomination %>%
              nom_layers() %>%
              purrr::map_lgl( ~ inherits(.$geom, "GeomLinerange")) %>%
              any
            if(bool_linerange) return(3 + nxt)
            if(bool_ribbon) return(2 + nxt)
            nxt
          })
