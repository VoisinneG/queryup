#' list all available query fields
#' @export
list_query_fields <- function() {
  url <- "https://www.uniprot.org/help/query-fields"
  message(paste0("See '", url, "' for all available query fields"))
}
