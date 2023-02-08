R package: queryup
================
Guillaume Voisinne
2023 - 02 - 08

[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/queryup)](https://cran.r-project.org/package=queryup)
[![R-CMD-check](https://github.com/VoisinneG/queryup/workflows/R-CMD-check/badge.svg)](https://github.com/VoisinneG/queryup/actions)
[![Codecov test
coverage](https://codecov.io/gh/VoisinneG/queryup/branch/master/graph/badge.svg)](https://app.codecov.io/gh/VoisinneG/queryup?branch=master)
[![CRAN mirror
downloads](https://cranlogs.r-pkg.org/badges/queryup)](https://cran.r-project.org/package=queryup/)

The `queryup` R package aims to facilitate retrieving information from
the UniProt database using R. Programmatic access to the UniProt
database is performed by submitting queries to the [UniProt website REST
API](https://www.uniprot.org/help/api_queries).

## Install

You can install the package from CRAN using:

``` r
install.packages("queryup")
```

Alternatively, you may also install the package from github using
devtools:

``` r
devtools::install_github("VoisinneG/queryup")
```

## Queries

Queries combine different fields to identify matching database entries.
Here, queries are submitted using the function `query_uniprot()`. In the
`queryup` R package, a query must be formatted as a list containing
character vectors named after existing UniProt fields (available query
fields can be found in the [API
documentation](https://www.uniprot.org/help/query-fields) or in the
package data `query_fields$field`). Different query fields must be
matched simultaneously. For instance, the following query uses the
fields *gene_exact* to return the UniProt entries of all proteins
encoded by gene *Pik3r1* :

``` r
library(queryup)
```

``` r
query <- list("gene_exact" = "Pik3r1")
df <- query_uniprot(query, show_progress = FALSE)
head(df)
```

    ##        Entry       Entry Name Gene Names Organism (ID)   Reviewed
    ## 2 A0A096MNU6 A0A096MNU6_PAPAN     PIK3R1          9555 unreviewed
    ## 3 A0A0D9RTM6 A0A0D9RTM6_CHLSB     PIK3R1         60711 unreviewed
    ## 4 A0A1S3F3Z7 A0A1S3F3Z7_DIPOR     Pik3r1         10020 unreviewed
    ## 5 A0A1U7Q814 A0A1U7Q814_MESAU     Pik3r1         10036 unreviewed
    ## 6 A0A287DCB8 A0A287DCB8_ICTTR     PIK3R1         43179 unreviewed
    ## 7 A0A2I2ZTD7 A0A2I2ZTD7_GORGO     PIK3R1          9595 unreviewed

Available query fields can be listed using the package data
`query_fields`:

``` r
query_fields$field
```

    ##  [1] "accession"                                                
    ##  [2] "active"                                                   
    ##  [3] "Refer to the page: Sequence Annotations"                  
    ##  [4] "lit_author"                                               
    ##  [5] "protein_name"                                             
    ##  [6] "chebi"                                                    
    ##  [7] "uniprot_id (/uniref), then uniref_cluster_90 (/uniprotkb)"
    ##  [8] "xrefcount_pdb (or xref_count)"                            
    ##  [9] "date_created"                                             
    ## [10] "database, xref"                                           
    ## [11] "ec"                                                       
    ## [12] "Refer to the pages: Comments or Sequence Annotations"     
    ## [13] "existence"                                                
    ## [14] "family"                                                   
    ## [15] "fragment"                                                 
    ## [16] "gene"                                                     
    ## [17] "gene_exact"                                               
    ## [18] "go"                                                       
    ## [19] "virus_host_name, virus_host_id"                           
    ## [20] "accession_id"                                             
    ## [21] "inchikey"                                                 
    ## [22] "protein_name"                                             
    ## [23] "interactor"                                               
    ## [24] "keyword"                                                  
    ## [25] "length"                                                   
    ## [26] "mass"                                                     
    ## [27] "cc_mass_spectrometry"                                     
    ## [28] "date_modified"                                            
    ## [29] "protein_name"                                             
    ## [30] "organelle"                                                
    ## [31] "organism_name, organism_id"                               
    ## [32] "plasmid"                                                  
    ## [33] "proteome"                                                 
    ## [34] "proteomecomponent"                                        
    ## [35] "sec_acc"                                                  
    ## [36] "reviewed"                                                 
    ## [37] "scope"                                                    
    ## [38] "sec_acc"                                                  
    ## [39] "sequence"                                                 
    ## [40] "date_sequence_modified"                                   
    ## [41] "strain"                                                   
    ## [42] "taxonomy_name, taxonomy_id"                               
    ## [43] "tissue"                                                   
    ## [44] "cc_webresource"

## Columns

By default, `query_uniprot()` returns a data.frame with UniProt
accession IDs, gene names, organism and Swiss-Prot review status. You
can choose which data columns to retrieve using the `columns` parameter.

``` r
df <- query_uniprot(query, 
                    columns = c("id", "sequence", "keyword", "gene_primary"),
                    show_progress = FALSE)
```

    ## Warning in (function (..., deparse.level = 1) : number of columns of result is
    ## not a multiple of vector length (arg 881)

See the [API documentation](https://www.uniprot.org/help/return_fields)
or the package data `return_fields` for all available columns. Available
returned fields can be listed using the package data `return_fields`:

``` r
head(return_fields)
```

    ##          field                      label
    ## 1    accession                      Entry
    ## 2           id                 Entry name
    ## 3   gene_names                 Gene names
    ## 4 gene_primary       Gene names (primary)
    ## 5 gene_synonym       Gene names (synonym)
    ## 6     gene_oln Gene names (ordered locus)

Note that the parameter `columns` and the name of the corresponding
column in the output data frame do not necessarily match (they
correspond to columns “field” and “label” respectively in the package
data `return_fields`).

``` r
names(df)
```

    ## [1] "Entry"                "Entry Name"           "Sequence"            
    ## [4] "Keywords"             "Gene Names (primary)"

Let’s check the sequence and the UniProt keywords corresponding to the
first entry :

``` r
as.character(df$Sequence[1])
```

    ## [1] "MSAEGYQYRALYDYKKEREEDIDLHLGDILTVNKGSLVALGFSDGQEARPEEIGWLNGYNETTGERGDFPGTYVEYIGRKKISPPTPKPRPPRPLPVAPGSSKTEADVEQQALTLPDLAEQFAPPDVAPPLLIKLVEAIEKKGLECSTLYRTQSSGNLAELRQLLDCDTASVDLEMIDVHILADAFKRYLLDLPNPVIPAAVYSEMISLAQEVQSSEEYIQLLKKLIRSPSIPHQYWLTLQYLLKHFFKLSQTSSKNLLNARVLSEIFSPMLFRFSAASSDNTENLIKVIEILISTEWNERQPAPALPPKPPKPTTVANNGMNNNMSLQDAEWYWGDISREEVNEKLRDTADGTFLVRDASTKMHGDYTLTLRKGGNNKLIKIFHRDGKYGFSDPLTFNSVVELINHYRNESLAQYNPKLDVKLLYPVSKYQQDQVVKEDNIEAVGKKLHEYNTQFQEKSREYDRLYEEYTRTSQEIQMKRTAIEAFNETIKIFEEQCQTQERYSKEYIEKFKREGNEKEIQRIMHNYDKLKSRISEIIDSRRRLEEDLKKQAAEYREIDKRMNSIKPDLIQLRKTRDQYLMWLTQKGVRQKKLNEWLGNENTEDQYSLVEDDEDLPHHDEKTWNVGSSNRNKAENLLRGKRDGTFLVRESSKQGCYACSVVVDGEVKHCVINKTATGYGFAEPYNLYSSLKELVLHYQHTSLVQHNDSLNVTLAYPVYAQDSYFIFQGNMGRMHGNGHSM"

``` r
as.character(df$Keywords[1])
```

    ## [1] "Coiled coil;Protein transport;Reference proteome;Repeat;SH2 domain;SH3 domain;Stress response;Transport"

## Combining query fields

Our first query returned many matches. We can build more specific
queries by using more than one query field. By default, matching entries
must satisfy all query fields simultaneously. Let’s retrieve the only
Swiss-Prot reviewed protein entry encoded by gene *Pik3r1* in *Homo
sapiens* (taxon: 9606):

``` r
query <- list("gene_exact" = "Pik3r1", 
              "reviewed" = "true", 
              "organism_id" = "9606")
df <- query_uniprot(query, show_progress = FALSE)
print(df)
```

    ##    Entry Entry Name  Gene Names Organism (ID) Reviewed
    ## 2 P27986 P85A_HUMAN PIK3R1 GRB1          9606 reviewed

## Multiple items per query field

It is also possible to look for entries that match different items
within a single query field. Items from a given query field are looked
for independently. Hence, the following query will return all Swiss-Prot
reviewed proteins encoded by either *Pik3r1* or *Pik3r2* in either *Mus
musculus* (taxon: 10090) or *Homo sapiens* (taxon: 9606):

``` r
query <- list("gene_exact" = c("Pik3r1", "Pik3r2"), 
              "reviewed" = "true", 
              "organism_id" = c("9606", "10090"))
df <- query_uniprot(query, show_progress = FALSE)
print(df)
```

    ##    Entry Entry Name  Gene Names Organism (ID) Reviewed
    ## 2 O00459 P85B_HUMAN      PIK3R2          9606 reviewed
    ## 3 O08908 P85B_MOUSE      Pik3r2         10090 reviewed
    ## 4 P26450 P85A_MOUSE      Pik3r1         10090 reviewed
    ## 5 P27986 P85A_HUMAN PIK3R1 GRB1          9606 reviewed

## Queries with invalid entries

If a query containing invalid entries is sent to the UniProt REST API,
an error message is returned and no information about the other
potentially valid entries can be retrieved. To overcome this limitation,
`queryup` parses the error messages and remove invalid entries from the
query. Hence, `query_uniprot()` will return information for valid
entries only :

``` r
invalid_ids <- c("P226", "CON_P22682", "REV_P47941")
valid_ids <- c("A0A0U1ZFN5", "P22682")
ids <- c(invalid_ids, valid_ids)
query <- list("accession_id" = ids)
query_uniprot(query)
```

    ## 3 invalid values were found (P226, CON_P22682, REV_P47941) and removed from the query.

    ##        Entry     Entry Name Gene Names Organism (ID)   Reviewed
    ## 2 A0A0U1ZFN5 A0A0U1ZFN5_RAT  Cbl c-Cbl         10116 unreviewed
    ## 3     P22682      CBL_MOUSE        Cbl         10090   reviewed

## Long queries

Because UniProt REST API limits the size of queries, long queries
containing more than a few hundreds entries cannot be passed in a single
request. To overcome this limitation, the `queryup` package splits long
queries into smaller ones. For instance, the dataset `uniprot_entries`
that is bundled with the `queryup` package contains information for 1000
UniProt entries. We could retrieve the ENSEMBL ids corresponding to
these entries using :

``` r
ids <- uniprot_entries$Entry
query <- list("accession_id" = ids)
columns <- c("gene_names", "xref_ensembl")
df <- query_uniprot(query, columns = columns, show_progress = FALSE)
head(df)
```

    ##        Entry                 Gene Names
    ## 2 A0A087WPF7             Auts2 Kiaa0442
    ## 3 A0A088MLT8 Iqcj-Schip1 Iqschfp Schip1
    ## 4 A0A0B4J1F4                     Arrdc4
    ## 5 A0A0B4J1G0               Fcgr4 Fcgr3a
    ## 6 A0A0G2JDV3                 Gbp6 Mpa2l
    ## 7 A0A0U1RPR8                     Gucy2d
    ##                                                                Ensembl
    ## 2 ENSMUST00000161226 [A0A087WPF7-1];ENSMUST00000161374 [A0A087WPF7-3];
    ## 3                                   ENSMUST00000182006 [A0A088MLT8-1];
    ## 4 ENSMUST00000048068 [A0A0B4J1F4-1];ENSMUST00000118110 [A0A0B4J1F4-2];
    ## 5                                                  ENSMUST00000078825;
    ## 6                                                           A0A0G2JDV3
    ## 7                                                  ENSMUST00000206435;

## Protein-protein interactions

Another usage could be to retrieve protein-protein interactions among a
set of UniProt entries:

``` r
ids <- sample(uniprot_entries$Entry, 400)
query <- list("accession_id" = ids, 
              "interactor" = ids)
columns <- "cc_interaction"
df <- query_uniprot(query = query, columns = columns, show_progress = FALSE)
head(df)
```

    ##     Entry                                         Interacts with
    ## 2  A2A259                                         Q2EG98; A2A259
    ## 3  O88273                                                 O88273
    ## 4  O88522 Q60680; O88351; O88522; Q924T7; P62991; P0CG48; P24772
    ## 21 E9Q401                 Q6PHZ2; Q9Z2I2; Q8K4S1; E9Q401; P23327
