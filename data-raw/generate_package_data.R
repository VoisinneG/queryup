library(XML)

#### return_fields ####

path <- "data-raw/UniProtKB_return_fields_UniProt_help_UniProt.html"
tables <- XML::readHTMLTable(path, stringsAsFactors = FALSE)
data <- as.data.frame(do.call(rbind, tables))
rownames(data) <- NULL
data <- data[c(3, 1)]
names(data) <- gsub("Returned ", "", names(data), fixed = TRUE)
names(data) <- tolower(gsub("*", "", names(data), fixed = TRUE))
return_fields <- data
usethis::use_data(return_fields, overwrite = TRUE)

#### query_fields ####

path <- "data-raw/UniProtKB_query_fields_UniProt_help_UniProt.html"
tables <- XML::readHTMLTable(path, stringsAsFactors = FALSE)[[1]]
tables <- tables[-c(1, 2)]
names(tables) <- tolower(gsub("rest.uniprot.org ", "", names(tables)))
query_fields <- tables
usethis::use_data(query_fields, overwrite = TRUE)

#### uniprot_entries ####

devtools::load_all()
df <- query_uniprot(query = list("organism_id" = "10090", "reviewed" = "true"))
uniprot_entries <- df[1:1000, ]
usethis::use_data(uniprot_entries, overwrite = TRUE)
