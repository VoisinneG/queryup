#' Retrieve data from UniProt using UniProt's REST API.
#'
#' Retrieve data from UniProt using UniProt's REST API.
#' To avoid non-responsive queries, they are split into
#' smaller queries with at most \code{max_keys} items per query field.
#' Not that it works only with queries where items within query fields are
#' collapsed with '+OR+' and different
#' query fields are collapsed with '+AND+' (see \code{query_uniprot()})
#'
#' @param query list of keys corresponding to UniProt's query fields.
#' For example :
#' query = list("gene_exact" = c("Pik3r1", "Pik3r2"),
#' "organism_id" = c("10090", "9606"), "reviewed" = "true").
#' See `query_fields` for available query fields.
#' @param base_url The base url for the UniProt REST API
#' @param columns names of UniProt data columns to retrieve.
#' Examples include "accession", "id", "genes", "keywords", "sequence".
#' See `return_fields` for available return fields.
#' @param max_keys maximum number of field items submitted
#' @param updateProgress used to display progress in shiny apps
#' @param show_progress Show progress bar
#' @return a data.frame
#' @importFrom utils setTxtProgressBar txtProgressBar
#' @export
#'
#' @examples
#' # Get the UniProt entries of all proteins encoded by gene Pik3r1
#' ids <- c("P22682", "P47941")
#' query = list("accession_id" = ids)
#' df <-  query_uniprot(query = query)
#' head(df)
query_uniprot <- function(query = NULL,
                          base_url = "https://rest.uniprot.org/uniprotkb/",
                          columns = c("accession",
                                      "id",
                                      "gene_names",
                                      "organism_id",
                                      "reviewed"),
                          max_keys = 200,
                          updateProgress = NULL,
                          show_progress = TRUE) {

  if (max_keys > 200) {
    message("Parameter 'max_keys' exceeds 200.
            Try a lower value if the request fails.")
  }

  n_max <- max_keys / length(query)

  if (typeof(query) == "list") {

    idx_long <- which(sapply(query, length) > n_max)

    if (length(idx_long) == 1) {

      r <- length(query[[idx_long]]) %% n_max
      q <- length(query[[idx_long]]) %/% n_max

      if (r > 0) q <- q + 1

      df_list <- vector("list", length = q)

      if (show_progress) {
        cat("Querying the UniProt database...\n")
        pb <- utils::txtProgressBar(min = 0, max = q, style = 3)
      }

      for (i in 1:q) {

        i_start <- (i - 1) * n_max + 1
        i_end <- min(i * n_max, length(query[[idx_long]]))
        query_short <- query
        query_short[[idx_long]] <- query[[idx_long]][i_start : i_end]

        if (is.function(updateProgress)) {
          text <- paste(i_end, " / ", length(query[[idx_long]]), sep = "")
          updateProgress(value = as.numeric(format(i / q * 100, digits = 0)),
                         detail = text)
        }

        res <- get_uniprot_data(query = query_short,
                         base_url = base_url,
                         columns = columns)

        df_list[[i]] <- res$content

        if (show_progress) utils::setTxtProgressBar(pb, i)
      }

      if (show_progress) close(pb)

      return(do.call(rbind, df_list))

    }else {

      for (i in idx_long) {
        query_split <- vector("list", 2)

        query_split[[1]] <- query
        query_split[[2]] <- query

        query_split[[1]][[i]] <- query[[i]][1:n_max]
        query_split[[2]][[i]] <- query[[i]][(n_max + 1):length(query[[i]])]

        df_list <- lapply(query_split, query_uniprot,
                          base_url = base_url,
                          columns = columns,
                          max_keys = max_keys,
                          show_progress = show_progress)

        return(do.call(rbind, df_list))
      }
    }

  }

  res <- get_uniprot_data(query = query,
                          base_url = base_url,
                          columns = columns)

  return(res$content)

}
