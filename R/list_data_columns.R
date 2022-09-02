#' list all available data columns
#' @export
list_data_columns <- function() {
  url <- "https://www.uniprot.org/help/return_fields"
  message(paste0("See '", url, "' for all available return fields"))
}
