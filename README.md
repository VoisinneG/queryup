[![Travis-CI Build
Status](https://travis-ci.org/VoisinneG/queryup.svg?branch=master)](https://travis-ci.org/VoisinneG/queryup)

R package : queryup
===================

The `queryup` R package aims to facilitate retrieving information from
the UniProt database using R. Programmatic access to the UniProt
database is peformed by submitting queries to the [UniProt website REST
API](https://www.uniprot.org/help/api_queries).

Install
-------

Install the package from github using devtools:

    devtools::install_github("VoisinneG/queryup")
    library(queryup)

Queries
-------

Queries combine different fields to identify matching database entries.
Here, queries are submitted using the function `query_uniprot()`. In the
`queryup` R package, a query must be formattted as a list containing
character vectors named after existing UniProt fields. The list of all
available fields along with example queries is shown
[here](#list-of-available-query%20fields). Different query fields must
be matched simultaneously. This query will return the UniProt ids of all
proteins encoded by gene *Pik3r1*.

    query <- list( "gene_exact" = "Pik3r1" )
    df <- query_uniprot(query, columns = c("id", "genes"))
    summary(df)

    ##         Entry                     Gene.names 
    ##  A0A087WQM2:  1   PIK3R1               :214  
    ##  A0A087X689:  1   Pik3r1               : 15  
    ##  A0A096MNU6:  1   pik3r1               : 12  
    ##  A0A0A9YVC8:  1   PIK3R1 A306_00009840 :  3  
    ##  A0A0B2UIC9:  1   PIK3R1 CK820_G0034249:  3  
    ##  A0A0B8S032:  1   pik3r1 LOC557176     :  2  
    ##  (Other)   :259   (Other)              : 16

Columns
-------

By default, `query_uniprot()` returns a dataframe with protein ids, gene
names, organism and Swiss-Prot review status. You can choose which data
columns to retrieve using the `columns` parameter.

    df <- query_uniprot(query, columns = c("id", "sequence", "keywords"))

See this [section](#list-of-available-data-columns) for all availbale
UniProt data columns. Note that the parameter `column` and the name of
the corresponding column in the output dataframe do not necessarily
match.

    names(df)

    ## [1] "Entry"    "Sequence" "Keywords"

    as.character(df$Sequence[1])

    ## [1] "MSAEGYQYRALYDYKKEREEDIDLHLGDILTVNKGSLLALGFSEGEEAKPEEIGWLNGFNETTGERGDFPGTYVEYIGRKKISPPTPKPRPPRPLPVAPSPAKTESESEQQAFSLPDLTEQFTPPDVAPPILVKIVETIEKKGLEYSTLYGAQGSSSAVELRQIFECDASSSDLETFDVHTLSDALKRYILDLPNPIIPAAVYSDMISVAQEVQSSEEYAQLLKKLIRSPNIPPQYWLTLQYLLKHFLRVCQASSKNLLNARSLAEIFSPLLFKFQIASSDNTEHHIKILEVLITSEWNERQPVPALPPKPPKPNSVTNNSMNNNMSLQDAEWYWGDISREEVNEKLRDTADGTFLVRDASTKMHGDYTLTLRKGGNNKLIKIFHRDGKYGFSDPLTFNSVVELINHYRNESLAQYNPKLDVKLLYPVSKYQQDQVVKEDSIEAVGKKLHEYNTQFQEKSREYDRLYEDYTRTSQEIQMKRTAIEAFNETIKIFEEQCQTQERYSKEYIEKFKREGNDKEIQRIMHNYEKLKSRISEIVDSRRRLEEDLKKQAAEYREIDKRMNSIKPDLIQLRKTRDQYLMWLTQKGVRQKKLNEWLGNENAEDQYSMVEDDEDLPHHDERTWNVGNINRSQAENLLRGKRDGTFLVRESSKQGCYACSVVVDGEVKHCVINKTPTGYGFAEPYNLYNSLKELVLHYQHTSLVQHNDSLNVTLAYPVYAQQRR"

    as.character(df$Keywords[1])

    ## [1] "Coiled coil;Complete proteome;Reference proteome;SH2 domain;SH3 domain"

Combining query fields
----------------------

Our first query returned many matches. We can build more specific
queries by using more than one query field. By default, matching entries
must satisfy all query fields simultaneously. Let's retrieve the only
Swiss-Prot reviewed protein entry encoded by gene *Pik3r1* in *Homo
sapiens* (taxon: 9606):

    query <- list( "gene_exact" = "Pik3r1", "reviewed" = "yes", "organism" = "9606" )
    df <- query_uniprot(query)
    print(df)

    ##    Entry  Gene.names             Organism   Status
    ## 1 P27986 PIK3R1 GRB1 Homo sapiens (Human) reviewed

Multiple items per query field
------------------------------

It is also possible to look for entries that match different items
within a single query field. Items from a given query field are looked
for independently. Hence, the following query will return all Swiss-Prot
reviewed proteins encoded by either *Pik3r1* or *Pik3r2* in either *Mus
musculus* (taxon: 10090) or *Homo sapiens* (taxon: 9606):

    query <- list( "gene_exact" = c("Pik3r1", "Pik3r2"), "reviewed" = "yes", "organism" = c("9606", "10090"))
    df <- query_uniprot(query)
    print(df)

    ##    Entry  Gene.names             Organism   Status
    ## 1 P26450      Pik3r1 Mus musculus (Mouse) reviewed
    ## 2 O00459      PIK3R2 Homo sapiens (Human) reviewed
    ## 3 P27986 PIK3R1 GRB1 Homo sapiens (Human) reviewed
    ## 4 O08908      Pik3r2 Mus musculus (Mouse) reviewed

List of available query fields
------------------------------

You can view all query fields available using:

    list_query_fields()

    ##  [1] "accession"         "active"            "annotation"       
    ##  [4] "author"            "cdantigen"         "citation"         
    ##  [7] "cluster"           "count"             "created"          
    ## [10] "database"          "ec"                "evidence"         
    ## [13] "existence"         "family"            "fragment"         
    ## [16] "gene"              "gene_exact"        "goa"              
    ## [19] "host"              "id"                "inn"              
    ## [22] "interactor"        "keyword"           "length"           
    ## [25] "lineage"           "mass"              "method"           
    ## [28] "mnemonic"          "modified"          "name"             
    ## [31] "organelle"         "organism"          "plasmid"          
    ## [34] "proteome"          "proteomecomponent" "replaces"         
    ## [37] "reviewed"          "scope"             "sequence"         
    ## [40] "sequence_modified" "strain"            "taxonomy"         
    ## [43] "tissue"            "web"

See [here](https://www.uniprot.org/help/query-fields) for a more
detailed description and example queries for each field.

List of available data columns
------------------------------

You can view all data columns retrieveable using :

    list_data_columns()

    ##   [1] "id"                                      
    ##   [2] "entry name"                              
    ##   [3] "genes"                                   
    ##   [4] "genes(PREFERRED)"                        
    ##   [5] "genes(ALTERNATIVE)"                      
    ##   [6] "genes(OLN)"                              
    ##   [7] "genes(ORF)"                              
    ##   [8] "organism"                                
    ##   [9] "organism-id"                             
    ##  [10] "protein names"                           
    ##  [11] "proteome"                                
    ##  [12] "lineage(ALL)"                            
    ##  [13] "virus hosts"                             
    ##  [14] "fragment"                                
    ##  [15] "encodedon"                               
    ##  [16] "comment(ALTERNATIVE PRODUCTS)"           
    ##  [17] "comment(ERRONEOUS GENE MODEL PREDICTION)"
    ##  [18] "comment(ERRONEOUS INITIATION)"           
    ##  [19] "comment(ERRONEOUS TERMINATION)"          
    ##  [20] "comment(ERRONEOUS TRANSLATION)"          
    ##  [21] "comment(FRAMESHIFT)"                     
    ##  [22] "comment(MASS SPECTROMETRY)"              
    ##  [23] "comment(POLYMORPHISM)"                   
    ##  [24] "comment(RNA EDITING)"                    
    ##  [25] "comment(SEQUENCE CAUTION)"               
    ##  [26] "length"                                  
    ##  [27] "mass"                                    
    ##  [28] "sequence"                                
    ##  [29] "feature(ALTERNATIVE SEQUENCE)"           
    ##  [30] "feature(NATURAL VARIANT)"                
    ##  [31] "feature(NON ADJACENT RESIDUES)"          
    ##  [32] "feature(NON STANDARD RESIDUE)"           
    ##  [33] "feature(NON TERMINAL RESIDUE)"           
    ##  [34] "feature(SEQUENCE CONFLICT)"              
    ##  [35] "feature(SEQUENCE UNCERTAINTY)"           
    ##  [36] "version(sequence)"                       
    ##  [37] "ec"                                      
    ##  [38] "comment(ABSORPTION)"                     
    ##  [39] "comment(CATALYTIC ACTIVITY)"             
    ##  [40] "comment(COFACTOR)"                       
    ##  [41] "comment(ENZYME REGULATION)"              
    ##  [42] "comment(FUNCTION)"                       
    ##  [43] "comment(KINETICS)"                       
    ##  [44] "comment(PATHWAY)"                        
    ##  [45] "comment(REDOX POTENTIAL)"                
    ##  [46] "comment(TEMPERATURE DEPENDENCE)"         
    ##  [47] "comment(PH DEPENDENCE)"                  
    ##  [48] "feature(ACTIVE SITE)"                    
    ##  [49] "feature(BINDING SITE)"                   
    ##  [50] "feature(DNA BINDING)"                    
    ##  [51] "feature(METAL BINDING)"                  
    ##  [52] "feature(NP BIND)"                        
    ##  [53] "feature(SITE)"                           
    ##  [54] "annotation score"                        
    ##  [55] "features"                                
    ##  [56] "comment(CAUTION)"                        
    ##  [57] "comment(MISCELLANEOUS)"                  
    ##  [58] "keywords"                                
    ##  [59] "context"                                 
    ##  [60] "existence"                               
    ##  [61] "tools"                                   
    ##  [62] "reviewed"                                
    ##  [63] "comment(SUBUNIT)"                        
    ##  [64] "interactor"                              
    ##  [65] "comment(DEVELOPMENTAL STAGE)"            
    ##  [66] "comment(INDUCTION)"                      
    ##  [67] "comment(TISSUE SPECIFICITY)"             
    ##  [68] "go"                                      
    ##  [69] "go(biological process)"                  
    ##  [70] "go(molecular function)"                  
    ##  [71] "go(cellular component)"                  
    ##  [72] "go-id"                                   
    ##  [73] "comment(ALLERGEN)"                       
    ##  [74] "comment(BIOTECHNOLOGY)"                  
    ##  [75] "comment(DISRUPTION PHENOTYPE)"           
    ##  [76] "comment(DISEASE)"                        
    ##  [77] "comment(PHARMACEUTICAL)"                 
    ##  [78] "comment(TOXIC DOSE)"                     
    ##  [79] "comment(SUBCELLULAR LOCATION)"           
    ##  [80] "feature(INTRAMEMBRANE)"                  
    ##  [81] "feature(TOPOLOGICAL DOMAIN)"             
    ##  [82] "feature(TRANSMEMBRANE)"                  
    ##  [83] "comment(PTM)"                            
    ##  [84] "feature(CHAIN)"                          
    ##  [85] "feature(CROSS LINK)"                     
    ##  [86] "feature(DISULFIDE BOND)"                 
    ##  [87] "feature(GLYCOSYLATION)"                  
    ##  [88] "feature(INITIATOR METHIONINE)"           
    ##  [89] "feature(LIPIDATION)"                     
    ##  [90] "feature(MODIFIED RESIDUE)"               
    ##  [91] "feature(PEPTIDE)"                        
    ##  [92] "feature(PROPEPTIDE)"                     
    ##  [93] "feature(SIGNAL)"                         
    ##  [94] "feature(TRANSIT)"                        
    ##  [95] "3d"                                      
    ##  [96] "feature(BETA STRAND)"                    
    ##  [97] "feature(HELIX)"                          
    ##  [98] "feature(TURN)"                           
    ##  [99] "citationmapping"                         
    ## [100] "citation"                                
    ## [101] "created"                                 
    ## [102] "last-modified"                           
    ## [103] "sequence-modified"                       
    ## [104] "version(entry)"                          
    ## [105] "comment(DOMAIN)"                         
    ## [106] "comment(SIMILARITY)"                     
    ## [107] "families"                                
    ## [108] "feature(COILED COIL)"                    
    ## [109] "feature(COMPOSITIONAL BIAS)"             
    ## [110] "feature(DOMAIN EXTENT)"                  
    ## [111] "feature(MOTIF)"                          
    ## [112] "feature(REGION)"                         
    ## [113] "feature(REPEAT)"                         
    ## [114] "feature(ZINC FINGER)"                    
    ## [115] "lineage(all)"                            
    ## [116] "lineage(SUPERKINGDOM)"                   
    ## [117] "lineage(KINGDOM)"                        
    ## [118] "lineage(SUBKINGDOM)"                     
    ## [119] "lineage(SUPERPHYLUM)"                    
    ## [120] "lineage(PHYLUM)"                         
    ## [121] "lineage(SUBPHYLUM)"                      
    ## [122] "lineage(SUPERCLASS)"                     
    ## [123] "lineage(CLASS)"                          
    ## [124] "lineage(SUBCLASS)"                       
    ## [125] "lineage(INFRACLASS)"                     
    ## [126] "lineage(SUPERORDER)"                     
    ## [127] "lineage(ORDER)"                          
    ## [128] "lineage(SUBORDER)"                       
    ## [129] "lineage(INFRAORDER)"                     
    ## [130] "lineage(PARVORDER)"                      
    ## [131] "lineage(SUPERFAMILY)"                    
    ## [132] "lineage(FAMILY)"                         
    ## [133] "lineage(SUBFAMILY)"                      
    ## [134] "lineage(TRIBE)"                          
    ## [135] "lineage(SUBTRIBE)"                       
    ## [136] "lineage(GENUS)"                          
    ## [137] "lineage(SUBGENUS)"                       
    ## [138] "lineage(SPECIES GROUP)"                  
    ## [139] "lineage(SPECIES SUBGROUP)"               
    ## [140] "lineage(SPECIES)"                        
    ## [141] "lineage(SUBSPECIES)"                     
    ## [142] "lineage(VARIETAS)"                       
    ## [143] "lineage(FORMA)"                          
    ## [144] "lineage-id(all)"                         
    ## [145] "lineage-id(SUPERKINGDOM)"                
    ## [146] "lineage-id(KINGDOM)"                     
    ## [147] "lineage-id(SUBKINGDOM)"                  
    ## [148] "lineage-id(SUPERPHYLUM)"                 
    ## [149] "lineage-id(PHYLUM)"                      
    ## [150] "lineage-id(SUBPHYLUM)"                   
    ## [151] "lineage-id(SUPERCLASS)"                  
    ## [152] "lineage-id(CLASS)"                       
    ## [153] "lineage-id(SUBCLASS)"                    
    ## [154] "lineage-id(INFRACLASS)"                  
    ## [155] "lineage-id(SUPERORDER)"                  
    ## [156] "lineage-id(ORDER)"                       
    ## [157] "lineage-id(SUBORDER)"                    
    ## [158] "lineage-id(INFRAORDER)"                  
    ## [159] "lineage-id(PARVORDER)"                   
    ## [160] "lineage-id(SUPERFAMILY)"                 
    ## [161] "lineage-id(FAMILY)"                      
    ## [162] "lineage-id(SUBFAMILY)"                   
    ## [163] "lineage-id(TRIBE)"                       
    ## [164] "lineage-id(SUBTRIBE)"                    
    ## [165] "lineage-id(GENUS)"                       
    ## [166] "lineage-id(SUBGENUS)"                    
    ## [167] "lineage-id(SPECIES GROUP)"               
    ## [168] "lineage-id(SPECIES SUBGROUP)"            
    ## [169] "lineage-id(SPECIES)"                     
    ## [170] "lineage-id(SUBSPECIES)"                  
    ## [171] "lineage-id(VARIETAS)"                    
    ## [172] "lineage-id(FORMA)"                       
    ## [173] "database(db_abbrev)"                     
    ## [174] "database(EMBL)"

Note that the parameter `columns` and the name of the corresponding
column in the output dataframe do not necessarily match. See
[here](https://www.uniprot.org/help/uniprotkb_column_names) for a more
detailed description.
