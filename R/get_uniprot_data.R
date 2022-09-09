#' Retrieve data from UniProt using UniProt's REST API
#'
#' @param query list of keys corresponding to UniProt's query fields.
#' For example :
#' list("gene_exact" = c("Pik3r1", "Pik3r2") ,
#' "organism" = c("10090", "9606"), "reviewed" = "yes").
#' See `query_fields` for available query fields.
#' @param columns names of UniProt data columns to retrieve.
#' Examples include "accession", "id", "gene_names", "keyword", "sequence".
#' See `return_fields` for available return fields.
#' @param print_url Boolean. Prints the complete url used for the query.
#' @param print_uniprot_messages Boolean. Prints the raw error message returned
#' by UniProt.
#' @return a list with the following items :
#' \describe{
#'   \item{url}{the query url}
#'   \item{messages}{messages returned by the REST API}
#'   \item{content}{a data.frame containing the query results}
#' }
#' @importFrom RCurl getURL
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examples
#' #Getting gene names, keywords and protein sequences for a set of UniProt IDs.
#' ids <- c("P22682", "P47941")
#' cols <- c("accession", "id", "gene_names", "keyword", "sequence")
#' query = list("accession_id" = ids)
#' df <- get_uniprot_data(query = query, columns = cols)$content
#' df
get_uniprot_data <- function(query = NULL,
                             columns = c("accession",
                                         "id",
                                         "gene_names",
                                         "organism_id",
                                         "reviewed"),
                             print_url = FALSE,
                             print_uniprot_messages = FALSE) {

  full_url <- build_query_url(query = query, columns = columns)
  if (is.null(full_url)) return(NULL)

  if (print_url) {
    message(paste0("\nQuery URL:\n",  full_url))
  }

  # Get response for query with json format
  content <- jsonlite::fromJSON(RCurl::getURL(full_url))
  messages <- content$messages

  if (print_uniprot_messages) {
    message(paste(messages, "\n"))
  }

  # check for invalid values and retry query without them
  df_invalid <- parse_messages(messages)

  if (!is.null(df_invalid)) {
    query <- clean_query(query, df_invalid)
    return(get_uniprot_data(query = query,
                            columns = columns,
                            print_url = print_url,
                            print_uniprot_messages = print_uniprot_messages))
  }

  # abort if an error message is present
  if (!is.null(messages)) {

    extra_message <- NULL
    n_query_items <- length(unlist(query))
    if (n_query_items > 300) {
      extra_message <- sprintf(
        "\nQuery has %s items and is probably too long.\n",
        n_query_items)
    }

    warning(
      paste0(
        "\nUniProt API request failed : \n",
        paste(messages, collapse = "\n"),
        extra_message
      ),
      call. = FALSE
    )

    return(list(url = full_url, messages = messages, content = NULL))
  }

  # get query results and return them as a data.frame

  full_url <- build_query_url(query = query, columns = columns, format = "tsv")
  res <- RCurl::getURL(full_url)
  entries <- strsplit(res, split = "\n")[[1]]
  df <- as.data.frame(do.call(rbind,
                              lapply(entries,
                                     function(x) {
                                       strsplit(x, split = "\t")[[1]]
                                     })))
  names <- df[1, ]
  df <- as.data.frame(df[-1, ])
  names(df) <- names

  return(list(url = full_url, messages = messages, content = df))

}


#' Accessory function used to build the query url
#'
#' @param query list of keys corresponding to UniProt's query fields.
#' For example :
#' list("gene_exact" = c("Pik3r1", "Pik3r2") ,
#' "organism" = c("10090", "9606"), "reviewed" = "yes")
#' @param columns names of UniProt data columns to retrieve.
#' @param format format of the response provided by the UniProt API
#' @return the query url
build_query_url <- function(query = NULL,
                            columns = c("accession",
                                        "id",
                                        "gene_names",
                                        "organism_name",
                                        "reviewed"),
                            format = "json") {
  # format url from function arguments
  if (typeof(query) == "list") {
    formatted_queries <- sapply(seq_along(query),
                                function(x) {
                                  paste(names(query)[x],
                                        ":(",
                                        paste(query[[x]],
                                              collapse = "+OR+"),
                                        ")",
                                        sep = "")})

    full_query <- paste(formatted_queries, collapse = "+AND+")
  }else if (typeof(query) == "character" && length(query) == 1) {
    full_query <- query
  }else {
    message("Query not supported")
    return(NULL)
  }

  if (! "accession" %in% columns) {
    columns <- c("accession", columns)
  }

  cols <- paste(columns, collapse = ",")

  base_url <- "https://rest.uniprot.org/uniprotkb/"

  full_url <- paste(base_url,
                    "stream?query=",
                    full_query,
                    "&fields=", paste(cols, sep = ","),
                    "&format=", format,
                    sep = "")

  return(full_url)

}


#' Accessory function retrieving invalid values from messages returned by
#' the UniProt API.
#'
#' @param messages character string containing the error messages returned by
#' UniProt API
#' @return a data.frame with invalid values (in column "value") and
#' corresponding query field (in column "field"). NULL if no invalid values are
#' identified.
parse_messages <- function(messages) {

  pattern <- "^The '(.+)' filter value '(.+)' has invalid format"
  matches <- regexec(pattern, messages)
  m <- do.call(rbind, regmatches(messages, matches))

  if (length(m) > 0) {
    if (dim(m)[2] == 3) {
      df_invalid_values <- as.data.frame(m)
      names(df_invalid_values) <- c("message", "field", "value")
      return(df_invalid_values)
    }
  }

  return(NULL)
}



#' Accessory function removing invalid values from a query
#'
#' @param query list of keys corresponding to uniprot's query fields.
#' For example :
#' list("gene_exact" = c("Pik3r1", "Pik3r2") ,
#' "organism" = c("10090", "9606"), "reviewed" = "yes")
#' @param df data.frame with invalid values (in column "value") and
#' corresponding query field (in column "field").
#' @return the input query without the invalid values
clean_query <- function(query, df) {

  n_invalid <- dim(df)[1]

  message(paste0(n_invalid,
                 " invalid values were found (",
                 paste0(df$value[1 : min(10, n_invalid)],
                        collapse = ", "),
                 ifelse(n_invalid > 10, ", ...", ""),
                 ")",
                 " and removed from the query.")
  )

  fields <- unique(df$field)
  for (field in fields) {
    query[[field]] <- setdiff(query[[field]],
                              df$value[df$field == field])
    if (length(query[[field]]) == 0) {
      idx_field <- which(names(query) == field)
      query <- query[-idx_field]
      message(paste0("Field '",
                     field,
                     "' with no valid entries has been removed from query."))
    }
  }
  return(query)
}
