% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_uniprot_data.R
\name{clean_query}
\alias{clean_query}
\title{Accessory function removing invalid values from a query}
\usage{
clean_query(query, df)
}
\arguments{
\item{query}{list of keys corresponding to UniProt's query fields.
For example :
list("gene_exact" = c("Pik3r1", "Pik3r2") ,
"organism" = c("10090", "9606"), "reviewed" = "yes")}

\item{df}{data.frame with invalid values (in column "value") and
corresponding query field (in column "field").}
}
\value{
the input query without the invalid values
}
\description{
Accessory function removing invalid values from a query
}
