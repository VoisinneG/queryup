#' Retrieve data from uniprot using uniprot's REST API
#'
#' @param query list of keys corresponding to uniprot's query fields.
#' For example :
#' list("gene_exact" = c("Pik3r1", "Pik3r2") ,
#' "organism" = c("10090", "9606"), "reviewed" = "yes")
#' @param base_url base URL for the UniProt REST API
#' @param columns names of uniprot data columns to retrieve.
#' Examples include "accession", "id", "gene_names", "keyword", "sequence"
#' @return a data.frame
#' @importFrom RCurl getURL
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
                             print_full_query = FALSE){

  df <- NULL

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

  full_url <- paste(base_url, 'stream?query=',
                    full_query,
                    '&format=tsv',
                    '&fields=', paste(cols, sep = ","),
                    sep = "")

  if(print_full_query){
    print(full_url)
  }

  res <- try(
    RCurl::getURL(full_url), silent = TRUE)
  if( inherits(res, "try-error") ){
    message(res)
    stop(paste0("Accessing UniProt REST API at ", base_url,  " failed"))
  }

  entries <- strsplit(res, split = "\n")[[1]]

  df <- as.data.frame(do.call(rbind,
                              lapply(entries,
                                     function(x){
                                       strsplit(x, split = "\t")[[1]]
                                       })))
  names <- df[1, ]
  df <- df[-1, ]
  names(df) <- names

  return(df)

}


#' Retrieve data from uniprot using uniprot's REST API.
#'
#' Retrieve data from uniprot using uniprot's REST API.
#' To avoid non-responsive queries, they are splitted into
#' smaller queries with at most \code{max_keys} items per query field.
#' Not that it works only with queries where items within query fields are
#' collapsed with '+OR+' and different
#' query fields are collapsed with '+AND+' (see \code{query_uniprot()})
#'
#' @param query list of keys corresponding to uniprot's query fields.
#' For example :
#' query = list("gene_exact" = c("Pik3r1", "Pik3r2"),
#' "organism_id" = c("10090", "9606"), "reviewed" = "true")
#' @param columns names of uniprot data columns to retrieve.
#' Examples include "accession", "id", "genes", "keywords", "sequence".
#' @param max_keys maximum number of field items submitted
#' @param updateProgress used to display progress in shiny apps
#' @param show_progress Show progress bar
#' @return a data.frame
#' @importFrom utils setTxtProgressBar txtProgressBar
#' @export
#'
#' @examples
#' # Query all reviewed UniProt entries for Mus musculus:
#' query = list("organism_id" = c("10090"), "reviewed" = "yes")
#' df_mouse_reviewed <-  query_uniprot(query = query)
#'
#' #Splitting long queries:
#' query = list("id" = df_mouse_reviewed$Entry[1:300])
#' df <-  query_uniprot(query = query, max_keys = 50)
query_uniprot <- function(query = NULL,
                          columns = c("accession", "id", "gene_names", "organism_name", "reviewed" ),
                          max_keys = 400,
                          updateProgress = NULL,
                          show_progress = TRUE){

  if(typeof(query) == "list"){

    idx_long <- which( sapply(query, length) > max_keys )

    if(length(idx_long)==1){

      r <- length(query[[idx_long]]) %% max_keys
      q <- length(query[[idx_long]]) %/% max_keys
      if(r>0) q <- q+1
      df_list <- vector("list", length = q)

      if(show_progress) {
        cat("Querying the UniProt database...\n")
        pb <- utils::txtProgressBar(min = 0, max = q, style = 3)
      }

      for(i in 1:q){

        i_start <- (i-1)*max_keys + 1
        i_end <- i*max_keys
        query_short <- query
        query_short[[idx_long]] <- query[[idx_long]][ i_start : i_end]

        if (is.function(updateProgress)) {
          text = paste(i_end, " / ", length(query[[idx_long]]), sep = "")
          updateProgress(value = as.numeric( format(i/q*100, digits = 0) ), detail = text)
        }

        df_list[[i]] <- get_uniprot_data(query = query_short, columns = columns)

        if(show_progress) utils::setTxtProgressBar(pb, i)
      }

      if(show_progress)close(pb)

      return(do.call(rbind, df_list))

    }else{
      for(i in idx_long){
        query_split <- vector("list", 2)

        query_split[[1]] <- query
        query_split[[2]] <- query

        query_split[[1]][[i]] <- query[[i]][1:max_keys]
        query_split[[2]][[i]] <- query[[i]][(max_keys+1):length(query[[i]])]

        df_list <- lapply(query_split, query_uniprot, columns = columns, max_keys = max_keys)

        return(do.call(rbind, df_list))
      }
    }

  }

  return( get_uniprot_data(query = query, columns = columns) )

}

#' list all available query fields
#' @export
list_query_fields <- function(){
  message("See 'https://www.uniprot.org/help/query-fields' for all available query fields")
}


#' list all available data columns
#' @export
list_data_columns <- function(){
  message("See 'https://www.uniprot.org/help/return_fields' for all available query fields")
}
