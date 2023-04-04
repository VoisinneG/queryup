#' Retrieve data from UniProt using UniProt's REST API
#'
#' @param query list of keys corresponding to UniProt's query fields.
#' For example :
#' list("gene_exact" = c("Pik3r1", "Pik3r2") ,
#' "organism" = c("10090", "9606"), "reviewed" = "yes").
#' See `query_fields` for available query fields.
#' @param base_url The base url for the UniProt REST API
#' @param columns names of UniProt data columns to retrieve.
#' Examples include "accession", "id", "gene_names", "keyword", "sequence".
#' See `return_fields` for available return fields.
#' @return a list with the following items :
#' \describe{
#'   \item{url}{the query url}
#'   \item{status}{the http status code for the request}
#'   \item{messages}{messages returned by the REST API}
#'   \item{content}{a data.frame containing the query results}
#' }
#' @import httr
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
                             base_url = "https://rest.uniprot.org/uniprotkb/",
                             columns = c("accession",
                                         "id",
                                         "gene_names",
                                         "organism_id",
                                         "reviewed")) {

  full_url <- build_query_url(query = query,
                              base_url = base_url,
                              columns = columns,
                              format = "json")

  if (is.null(full_url)) return(NULL)

  # GET response to request

  resp <- try(httr::GET(full_url), silent = TRUE)

  if (inherits(resp, "try-error")){
    message(paste0("Request failed : could not get a response \n(",
                   resp[1], ")"))
    return(NULL)
  }

  if (httr::http_type(resp) != "application/json") {
    message("Request failed : API did not return json")
    return(NULL)
  }

  content <- try(jsonlite::fromJSON(httr::content(resp,
                                        as = "text",
                                        encoding = "UTF-8"),
                                simplifyVector = FALSE),
                 silent = TRUE)


  if (! inherits(content, "list")){
    message("Request failed : could not read the response content")
    return(NULL)
  }

  messages <- unlist(content$messages)

  # check for invalid values and retry query without them
  df_invalid <- parse_messages(messages)

  if (!is.null(df_invalid)) {
    query <- clean_query(query, df_invalid)
    return(get_uniprot_data(query = query,
                            base_url = base_url,
                            columns = columns))
  }

  request_status <- httr::http_status(resp)
  request_status_code <- httr::status_code(resp)

  # request failure

  if(request_status_code != 200){

    # get message corresponding to request status
    http_message <- request_status$message

    # print an additional informative error message

      extra_message <- NULL
      n_query_items <- length(unlist(query))
      if (n_query_items > 200) {
        extra_message <- sprintf(
          "\nQuery has %s items and is probably too long.\n",
          n_query_items)
      }

      message(
        paste0(
          "\nUniProt API request failed : \n",
          paste(c(http_message, messages), collapse = "\n"),
          extra_message
        )
      )

    return(list(url = full_url,
                status = request_status_code,
                messages = c(http_message, messages),
                content = NULL))
  }

  # get query results and return them as a data.frame

  full_url <- build_query_url(query = query,
                              base_url = base_url,
                              columns = columns,
                              format = "tsv")

  resp <- try(httr::GET(full_url), silent = TRUE)

  if (inherits(resp, "try-error")){
    message(paste0("Request failed : could not get a response \n(",
                   resp[1], ")"))
    return(NULL)
  }

  if (httr::http_type(resp) != "text/plain") {
    message("Request failed : API did not return plain text")
    return(NULL)
  }

  res <- try(httr::content(resp,
                           as = "text",
                           encoding = "UTF-8"),
             silent = TRUE)

  if (!inherits(res, "character")){
    message("Request failed : could not read the response content")
    return(NULL)
  }

  entries <- strsplit(res, split = "\n")[[1]]
  df <- as.data.frame(do.call(rbind,
                              lapply(entries,
                                     function(x) {
                                       strsplit(x, split = "\t")[[1]]
                                     })))
  names <- df[1, ]
  df <- as.data.frame(df[-1, ])
  names(df) <- names

  return(list(url = full_url,
              status = request_status_code,
              messages = messages,
              content = df))

}


#' Accessory function used to build the query url
#'
#' @param query list of keys corresponding to UniProt's query fields.
#' For example :
#' list("gene_exact" = c("Pik3r1", "Pik3r2") ,
#' "organism" = c("10090", "9606"), "reviewed" = "yes")
#' @param base_url The base url for the UniProt REST API
#' @param columns names of UniProt data columns to retrieve.
#' @param format format of the response provided by the UniProt API
#' @return the query url
build_query_url <- function(query = NULL,
                            base_url = "https://rest.uniprot.org/uniprotkb/",
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
#' @param query list of keys corresponding to UniProt's query fields.
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
