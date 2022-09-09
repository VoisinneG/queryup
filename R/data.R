#' Information for 1000 UniProt entries from the organism Mus musculus
#'
#' Entry names and other attributes of 1000 UniProt entries
#' in Mus musculus.
#'
#' @format A data frame with 1000 rows and 5 variables:
#' \describe{
#'   \item{Entry}{UniProt entry accession id}
#'   \item{Entry Name}{UniProt entry name}
#'   \item{Gene Names}{Gene names}
#'   \item{Organism (ID)}{Taxon ID}
#'   \item{Reviewed}{Swiss-Prot review status}
#' }
#' @source \url{https://www.uniprot.org/}
"uniprot_entries"

#' Available query fields.
#'
#' Query fields that can be used to generate queries using `queryup`
#' along with associated examples and description.
#'
#' @format A data frame with 44 rows and 3 variables:
#' \describe{
#'   \item{field}{Name of the query field}
#'   \item{example}{Example query (as appearing in the query url)}
#'   \item{description}{Description of the example query}
#' }
#' @source \url{https://www.uniprot.org/help/query-fields}
"query_fields"

#' Available return fields ("columns").
#'
#' Return fields that can be retrieved using `queryup`
#' along with their label (column "Label") as appearing in the retrieved
#' data.frame.
#'
#' @format A data frame with 287 rows and 2 variables:
#' \describe{
#'   \item{field}{Name of the returned field}
#'   \item{label}{Label of the corresponding column in the retrieved data.frame}
#' }
#' @source \url{https://www.uniprot.org/help/return_fields}
"return_fields"
