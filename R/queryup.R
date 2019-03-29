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
get_uniprot_data <- function(query = NULL, columns = c("id", "genes", "organism", "reviewed" )){

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

    #message(paste("Querying the UniProt database...\n",sep=""))

    df <- tryCatch({
      read.table(full_url,
                 sep ="\t",
                 header = TRUE,
                 quote = "",
                 stringsAsFactors = FALSE
                )
    }, error=function(err) {
      stop("reading url 'https://www.uniprot.org/...' failed")
    })
  }


  return(df)

}


#' Retrieve data from uniprot using uniprot's REST API.
#'
#' Retrieve data from uniprot using uniprot's REST API.
#' To avoid non-responsive queries, they are splitted into
#' smaller queries with at most \code{max_keys} items per query field.
#' Not that it works only with queries where items within query fields are collapse with '+or+' and different
#' query fields are collapsed with '+and+' (see \code{query_uniprot()})
#'
#' @param query list of keys corresponding to uniprot's query fields. For example :
#' query = list("gene_exact" = c("Pik3r1", "Pik3r2"), "organism" = c("10090", "9606"), "reviewed" = "yes")
#' @param columns names of uniprot data columns to retrieve. Examples include "id",
#' "genes", "keywords", "sequence"
#' @param max_keys maximum number of field items submitted
#' @param updateProgress used to display progress in shiny apps
#' @return a data.frame
#' @examples
#' # Query all reviewed UniProt entries for Mus musculus:
#' query = list("organism" = c("10090"), "reviewed" = "yes")
#' df_mouse_reviewed <-  query_uniprot(query = query)
#'
#' #Splitting long queries:
#' query = list("id" = df_mouse_reviewed$Entry[1:300])
#' df <-  query_uniprot(query = query, max_keys = 50)
#' @export
query_uniprot <- function(query = NULL, columns = c("id", "genes", "organism", "reviewed" ), max_keys = 400, updateProgress = NULL){

  message(paste("Querying the UniProt database...\n",sep=""))

  if(typeof(query) == "list"){

    idx_long <- which( sapply(query, length) > max_keys )

    if(length(idx_long)==1){

      r <- length(query[[idx_long]]) %% max_keys
      q <- length(query[[idx_long]]) %/% max_keys
      if(r>0) q <- q+1
      df_list <- vector("list", length = q)
      pb <- txtProgressBar(min = 0, max = q, style = 3)

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

        setTxtProgressBar(pb, i)
      }
      close(pb)

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

#' Create a data.frame with UniProt annotations corrresponding to a set of UniProt IDs
#'
#' @param id Character vector with UniProt IDs
#' @param columns names of uniprot data columns to retrieve. Examples include "id",
#' "genes", "keywords", "sequence", "go" (use \code{list_data_columns()} to see the full list)
#' @param max_keys maximum number of field items submitted
#' @param updateProgress used to display progress in shiny apps
#' @return a data.frame
#' @examples
#' # Query all reviewed UniProt entries for Mus musculus:
#' query = list("organism" = c("10090"), "reviewed" = "yes")
#' df_mouse_reviewed <-  query_uniprot(query = query)
#' df <-  get_annotations_uniprot(id = df_mouse_reviewed$Entry[1:300], max_keys = 50)
#' @export
get_annotations_uniprot <- function(id, columns = c("genes", "keywords", "families", "go") , max_keys = 400, updateProgress = NULL){

  idx <- which(!is.na(id))

  query <- list("id" = id[idx])
  columns <- union("id", columns)

  df_annot <- tryCatch({
    query_uniprot(query = query, columns = columns, max_keys = max_keys, updateProgress = updateProgress)
  }, error = function(err){
    warning("Query failed. Please retry later.")
    NULL
  })

  if(is.null(df_annot)) return(NULL)

  idx_match <- match(id, df_annot$Entry)
  df <- data.frame(id = id, df_annot[idx_match, ])
  return(df)
}

#' list all available query fields
#'
#' Prints all available query fields as
#' listed on the \href{https://www.uniprot.org/help/query-fields}{UniProt website}.
#' @import XML
#' @import RCurl
#' @export
list_query_fields <- function(){
  theurl <- getURL('https://www.uniprot.org/help/query-fields',.opts = list(ssl.verifypeer = FALSE) )
  tables <- readHTMLTable(theurl, stringsAsFactors = FALSE)
  #tables <- list.clean(tables, fun = is.null, recursive = FALSE)
  return(tables[[1]]$Field)
}

#' list all available data columns
#'
#' Prints all available data columns as
#' listed on the \href{https://www.uniprot.org/help/uniprotkb_column_names}{UniProt website}.
#' @import XML
#' @import RCurl
#' @export
list_data_columns <- function(){
  theurl <- getURL('https://www.uniprot.org/help/uniprotkb_column_names',.opts = list(ssl.verifypeer = FALSE) )
  tables <- readHTMLTable(theurl, stringsAsFactors = FALSE)
  #tables <- list.clean(tables, fun = is.null, recursive = FALSE)
  data <- do.call(rbind, tables)
  col_names <- gsub(" ", "_", data[["Column names as displayed in URL"]], fixed = TRUE)
  return(col_names)
}
