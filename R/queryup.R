#' Retrieve data from uniprot using uniprot's REST API
#'
#' @param query list of keys corresponding to uniprot's query fields. For example :
#' list("gene_exact" = c("Pik3r1", "Pik3r2") , "organism" = c("10090", "9606"), "reviewed" = "yes")
#' @param columns names of uniprot data columns to retrieve. Examples include "id",
#' "genes", "keywords", "sequence"
#'
#' @return a data.frame
#' @import utils
#' @export
#'
#' @examples
#' #Getting gene names, keywords and protein sequences associated with a set of uniprot IDs.
#' ids <- c("P22682", "P47941")
#' cols <- c("id", "genes", "keywords", "sequence")
#' df <- get_uniprot_data(query = list("id" = ids), columns = cols)
#'
#' #Lists all entries describing interactions with the protein described by entry P00520.
#' df <- get_uniprot_data(query = list("interactor" = "P00520"), columns = cols)
get_uniprot_data <- function(query = NULL, columns = c("id", "organism", "reviewed" )){

  df <- NULL

  if(!is.null(query)){
    if(typeof(query) == "list"){
      formatted_queries <- sapply(1:length(query),
                                  function(x){paste(names(query)[x], ":(",
                                                    paste(query[[x]], collapse = "+or+"), ")",
                                                    sep ="")})

      url <- 'https://www.uniprot.org/uniprot/?query='
      full_query <- paste(formatted_queries, collapse = "+and+")
    }else if(typeof(query) == "character"){
      full_query <- query
    }else{
      message("Query not supported")
      return(NULL)
    }
    cols <- tolower(paste(columns, collapse = ","))
    full_url <- paste('https://www.uniprot.org/uniprot/?query=', full_query,
                      '&format=tab&columns=', cols,
                      sep = "")

    message(paste("Querying the UniProt database...\n",sep=""))

    df <- tryCatch({
      read.table(full_url,
                 sep ="\t",
                 header = TRUE,
                 quote = "")
    }, error=function(err) {
      message(
        "reading url",
        "\n    ", full_url,
        "\nfailed"
      )
      NULL
    })
  }


  return(df)

}


#' Retrieve data from uniprot using uniprot's REST API.
#' To avoid non-responsive queries, they are splitted into
#' smaller queries withat most \code{max_keys} items per query field.
#'
#' @param query list of keys corresponding to uniprot's query fields. For example :
#' list("gene_exact" = c("Pik3r1", "Pik3r2") , "organism" = c("10090", "9606"), "reviewed" = "yes")
#' @param columns names of uniprot data columns to retrieve. Examples include "id",
#' "genes", "keywords", "sequence"
#' @param max_keys maximum number of field items submitted
#' @return a data.frame
#' @export
query_uniprot <- function(query = NULL, columns = c("id", "organism", "reviewed" ), max_keys = 400 ){

  if(typeof(query) == "list"){

    for ( i in 1:length(query)){

      if(length(query[[i]]) > max_keys){

        query_split <- vector("list", 2)

        query_split[[1]] <- query
        query_split[[2]] <- query

        query_split[[1]][[i]] <- query[[i]][1:max_keys]
        query_split[[2]][[i]] <- query[[i]][(max_keys+1):length(query[[i]])]

        #query_split[[1]] <- split_query(query_split[[1]], max_keys = max_keys)
        #query_split[[2]] <- split_query(query_split[[2]], max_keys = max_keys)

        df_list <- lapply(query_split, query_uniprot, columns = columns, max_keys = max_keys)

        return(do.call(rbind, df_list))

      }
    }
  }


  return( get_uniprot_data(query, columns = columns) )

}
