R package: queryup
================
Guillaume Voisinne
2022 - 09 - 02

[![R-CMD-check](https://github.com/VoisinneG/queryup/workflows/R-CMD-check/badge.svg)](https://github.com/VoisinneG/queryup/actions)
[![Codecov test
coverage](https://codecov.io/gh/VoisinneG/queryup/branch/master/graph/badge.svg)](https://codecov.io/gh/VoisinneG/queryup?branch=master)

The `queryup` R package aims to facilitate retrieving information from
the UniProt database using R. Programmatic access to the UniProt
database is peformed by submitting queries to the [UniProt website REST
API](https://www.uniprot.org/help/api_queries).

## Install

Install the package from github using devtools:

``` r
devtools::install_github("VoisinneG/queryup")
library(queryup)
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
query <- list( "gene_exact" = "Pik3r1", "organism_id" = "9606" )
df <- query_uniprot(query, columns = c("id", "gene_names"), show_progress = FALSE)
head(df)
```

    ##        Entry       Entry Name          Gene Names
    ## 2 A0A2X0SFG1 A0A2X0SFG1_HUMAN              PIK3R1
    ## 3     P27986       P85A_HUMAN         PIK3R1 GRB1
    ## 4 A0A1D8GZE0 A0A1D8GZE0_HUMAN NR4A3 PIK3R1 fusion
    ## 5 A0A1D8GZE1 A0A1D8GZE1_HUMAN PIK3R1 NR4A3 fusion
    ## 6     E5RGI8     E5RGI8_HUMAN              PIK3R1
    ## 7     E5RHI0     E5RHI0_HUMAN              PIK3R1

## Columns

By default, `query_uniprot()` returns a dataframe with protein ids, gene
names, organism and Swiss-Prot review status. You can choose which data
columns to retrieve using the `columns` parameter.

``` r
df <- query_uniprot(query, 
                    columns = c("id", "sequence", "keyword", "gene_primary"),
                    show_progress = FALSE)
```

See this [web page](https://www.uniprot.org/help/return_fields) for all
availbale UniProt data columns. Note that the parameter `columns` and
the name of the corresponding column in the output data frame do not
necessarily match.

``` r
names(df)
```

    ## [1] "Entry"                "Entry Name"           "Sequence"            
    ## [4] "Keywords"             "Gene Names (primary)"

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

    ##    Entry Entry Name  Gene Names             Organism Reviewed
    ## 2 P27986 P85A_HUMAN PIK3R1 GRB1 Homo sapiens (Human) reviewed

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

    ##    Entry Entry Name  Gene Names             Organism Reviewed
    ## 2 O00459 P85B_HUMAN      PIK3R2 Homo sapiens (Human) reviewed
    ## 3 O08908 P85B_MOUSE      Pik3r2 Mus musculus (Mouse) reviewed
    ## 4 P26450 P85A_MOUSE      Pik3r1 Mus musculus (Mouse) reviewed
    ## 5 P27986 P85A_HUMAN PIK3R1 GRB1 Homo sapiens (Human) reviewed

## Long queries

Because UniProt REST API limits the size of queries, long queries
containing more than a few hundreds entries cannot be passed in a single
request. To overcome this limitation, the `queryup` package splits long
queries into smaller ones. For instance, the dataset `uniprot_entries`
that is bundled with the `queryup` package contains information for 1000
UniProt entries. We could get UniProt keywords for these entries using :

``` r
ids <- uniprot_entries$Entry
query <- list("accession_id" = ids)
columns <- c("gene_names", "keyword")
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
    ##                                                                                                                                                                                                               Keywords
    ## 2                                                                         Alternative splicing;Cell projection;Cytoplasm;Cytoskeleton;Nucleus;Phosphoprotein;Reference proteome;Transcription;Transcription regulation
    ## 3                                                                                                                                        Alternative splicing;Cell projection;Coiled coil;Cytoplasm;Reference proteome
    ## 4                                                                                                                   Alternative splicing;Cell membrane;Cytoplasmic vesicle;Endosome;Membrane;Reference proteome;Repeat
    ## 5 Cell membrane;Disulfide bond;Glycoprotein;IgE-binding protein;IgG-binding protein;Immunity;Immunoglobulin domain;Membrane;Phosphoprotein;Receptor;Reference proteome;Repeat;Signal;Transmembrane;Transmembrane helix
    ## 6                                                                                                               Antimicrobial;Cytoplasmic vesicle;GTP-binding;Hydrolase;Immunity;Nucleotide-binding;Reference proteome
    ## 7                                                         Cell membrane;Cell projection;cGMP biosynthesis;Disulfide bond;Lyase;Membrane;Nucleotide-binding;Reference proteome;Signal;Transmembrane;Transmembrane helix

Another usage could be to retrieve protein-protein interactions amongst
a set of UniProt entries:

``` r
ids <- sample(uniprot_entries$Entry, 400)
query <- list("accession_id" = ids, "interactor"= ids)
columns <- "cc_interaction"
df <- query_uniprot(query = query, columns = columns, show_progress = FALSE)
head(df)
```

    ##     Entry                         Interacts with
    ## 2  E9Q401 Q6PHZ2; Q9Z2I2; Q8K4S1; E9Q401; P23327
    ## 23 A2A259                         Q2EG98; A2A259
    ## 3  A2AG06                         B2RR83; Q9H6S0
    ## 4  B2RR83                                 A2AG06
    ## 5  E9QAG8                         O09106; P70288
    ## 6  O08808         Q8BKX1; O08808; P46940; P61586
