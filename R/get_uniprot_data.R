#' Retrieve data from uniprot using uniprot's REST API
#'
#' @param query list of keys corresponding to uniprot's query fields.
#' For example :
#' list("gene_exact" = c("Pik3r1", "Pik3r2") ,
#' "organism" = c("10090", "9606"), "reviewed" = "yes")
#' @param base_url base URL for the UniProt REST API
#' @param columns names of uniprot data columns to retrieve.
#' Examples include "accession", "id", "gene_names", "keyword", "sequence"
#' @param print_url logical. Prints the complete url used for the query.
#' @return a data.frame
#' @importFrom RCurl getURL
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examples
#' #Getting gene names, keywords and protein sequences associated with a set of uniprot IDs.
#' ids <- c("P22682", "P47941")
#' cols <- c("accession", "id", "gene_names", "keyword", "sequence")
#' df <- get_uniprot_data(query = list("accession_id" = ids), columns = cols)
#'
#' #Lists all entries describing interactions with the protein described by entry P00520.
#' df <- get_uniprot_data(query = list("interactor" = "P00520"), columns = cols)
get_uniprot_data <- function(query = NULL,
                             base_url = "https://rest.uniprot.org/uniprotkb/",
                             columns = c("accession", "id", "gene_names",
                                         "organism_name", "reviewed" ),
                             print_url = FALSE){


  # format url from function arguments
  if(typeof(query) == "list"){
    formatted_queries <- sapply(1:length(query),
                                function(x){paste(names(query)[x], ":(",
                                                  paste(query[[x]], collapse = "+OR+"), ")",
                                                  sep ="")})

    full_query <- paste(formatted_queries, collapse = "+AND+")
  }else if(typeof(query) == "character" && length(query) == 1){
    full_query <- query
  }else{
    message("Query not supported")
    return(NULL)
  }

  cols <- paste(columns, collapse = ",")

  full_url <- paste(base_url,
                    'stream?query=',
                    full_query,
                    '&fields=', paste(cols, sep = ","),
                    sep = "")

  if(print_url){
    print(full_url)
  }

  # Check for error messages
  content <- jsonlite::fromJSON(RCurl::getURL(full_url))
  messages <- content$messages

  if(!is.null(messages)){
    warning(
      sprintf(
        "\nUniProt API request failed : \n%s",
        messages
      ),
      call. = FALSE
    )

  }

  # get query results in tab separated values format
  full_url_format <- paste0(full_url, '&format=tsv')

  res <- RCurl::getURL(full_url_format)

  entries <- strsplit(res, split = "\n")[[1]]

  df <- as.data.frame(do.call(rbind,
                              lapply(entries,
                                     function(x){
                                       strsplit(x, split = "\t")[[1]]
                                     })))
  names <- df[1, ]
  df <- df[-1, ]
  names(df) <- names

  return(list(url = full_url, content = df))

}