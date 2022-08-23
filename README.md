R package: queryup
================
Guillaume Voisinne
2022 - 08 - 23

[![Travis-CI Build
Status](https://travis-ci.org/VoisinneG/queryup.svg?branch=master)](https://travis-ci.org/VoisinneG/queryup)

The `queryup` R package aims to facilitate retrieving information from
the UniProt database using R. Programmatic access to the UniProt
database is peformed by submitting queries to the [UniProt website REST
API](https://www.uniprot.org/help/api_queries).

## Install

Install the package from github using devtools:

``` r
devtools::install_github("VoisinneG/queryup")
```

## Queries

Queries combine different fields to identify matching database entries.
Here, queries are submitted using the function `query_uniprot()`. In the
`queryup` R package, a query must be formattted as a list containing
character vectors named after existing UniProt fields. The list of all
available fields along with example queries is detailed
[here](https://www.uniprot.org/help/query-fields). Different query
fields must be matched simultaneously. For instance, the following query
will return the UniProt ids of all proteins encoded by gene *Pik3r1* in
*Homo sapiens* (taxon: 9606).

``` r
library(queryup)
query <- list( "gene_exact" = "Pik3r1", "organism_id" = "9606" )
df <- query_uniprot(query, columns = c("id", "gene_names"), show_progress = FALSE)
head(df)
```

    ##         Entry Name          Gene Names
    ## 2 A0A2X0SFG1_HUMAN              PIK3R1
    ## 3       P85A_HUMAN         PIK3R1 GRB1
    ## 4 A0A1D8GZE0_HUMAN NR4A3 PIK3R1 fusion
    ## 5 A0A1D8GZE1_HUMAN PIK3R1 NR4A3 fusion
    ## 6     E5RGI8_HUMAN              PIK3R1
    ## 7     E5RHI0_HUMAN              PIK3R1

## Columns

By default, `query_uniprot()` returns a dataframe with protein ids, gene
names, organism and Swiss-Prot review status. You can choose which data
columns to retrieve using the `columns` parameter.

``` r
df <- query_uniprot(query, 
                    columns = c("id", "sequence", "keyword", "gene_primary"),
                    show_progress = FALSE)
```

See this [web page](https://www.uniprot.org/help/uniprotkb_column_names)
for all availbale UniProt data columns. Note that the parameter
`columns` and the name of the corresponding column in the output data
frame do not necessarily match.

``` r
names(df)
```

    ## [1] "Entry Name"           "Sequence"             "Keywords"            
    ## [4] "Gene Names (primary)"

``` r
as.character(df$Sequence[1])
```

    ## [1] "MSAEGYQYRALYDYKKEREEDIDLHLGDILTVNKGSLVALGFSDGQEARPEEIGWLNGYNETTGERGDFPGTYVEYIGRKKISPPTPKPRPPRPLPVAPGSSKTEADVEQQALTLPDLAEQFAPPDIAPPLLIKLVEAIEKKGLECSTLYRTQSSSNLAELRQLLDCDTPSVDLEMIDVHVLADAFKRYLLDLPNPVIPAAVYSEMISLAPEVQSSEEYIQLLKKLIRSPSIPHQYWLTLQYLLKHFFKLSQTSSKNLLNARVLSEIFSPMLFRFSAASSDNTENLIKVIEILISTEWNERQPAPALPPKPPKPTTVANNGMNNNMSLQDAEWYWGDISREEVNEKLRDTADGTFLVRDASTKMHGDYTLTLRKGGNNKLIKIFHRDGKYGFSDPLTFSSVVELINHYRNESLAQYNPKLDVKLLYPVSKYQQDQVVKEDNIEAVGKKLHEYNTQFQEKSREYDRLYEEYTRTSQEIQMKRTAIEAFNETIKIFEEQCQTQERYSKEYIEKFKREGNEKEIQRIMHNYDKLKSRISEIIDSRRRLEEDLKKQAAEYREIDKRMNSIKPDLIQLRKTRDQYLMWLTQKGVRQKKLNEWLGNENTEDQYSLVEDDEDLPHHDEKTWNVGSSNRNKAENLLRGKRDGTFLVRESSKQGCYACSVVVDGEVKHCVINKTATGYGFAEPYNLYSSLKELVLHYQHTSLVQHNDSLNVTLAYPVYAQQRR"

``` r
as.character(df$Keywords[1])
```

    ## [1] "Coiled coil;Repeat;SH2 domain;SH3 domain;Stress response"

## Combining query fields

Our first query returned many matches. We can build more specific
queries by using more than one query field. By default, matching entries
must satisfy all query fields simultaneously. Let’s retrieve the only
Swiss-Prot reviewed protein entry encoded by gene *Pik3r1* in *Homo
sapiens* (taxon: 9606):

``` r
query <- list( "gene_exact" = "Pik3r1", "reviewed" = "true", "organism_id" = "9606" )
df <- query_uniprot(query, show_progress = FALSE)
print(df)
```

    ##   Entry Name  Gene Names             Organism Reviewed
    ## 2 P85A_HUMAN PIK3R1 GRB1 Homo sapiens (Human) reviewed

## Multiple items per query field

It is also possible to look for entries that match different items
within a single query field. Items from a given query field are looked
for independently. Hence, the following query will return all Swiss-Prot
reviewed proteins encoded by either *Pik3r1* or *Pik3r2* in either *Mus
musculus* (taxon: 10090) or *Homo sapiens* (taxon: 9606):

``` r
query <- list( "gene_exact" = c("Pik3r1", "Pik3r2"), "reviewed" = "true", "organism_id" = c("9606", "10090"))
df <- query_uniprot(query, show_progress = FALSE)
print(df)
```

    ##   Entry Name  Gene Names             Organism Reviewed
    ## 2 P85B_HUMAN      PIK3R2 Homo sapiens (Human) reviewed
    ## 3 P85B_MOUSE      Pik3r2 Mus musculus (Mouse) reviewed
    ## 4 P85A_MOUSE      Pik3r1 Mus musculus (Mouse) reviewed
    ## 5 P85A_HUMAN PIK3R1 GRB1 Homo sapiens (Human) reviewed
