R package : queryup
===================

This package aims to facilitate retrieving information from the uniprot
database using R. Programmatic access to the uniprot database is
peformed by submitting queries to the uniprot REST API. Queries combine
different fields to identify matching database entries. Here, queries
are submitted using the function `query_uniprot()`.

Installation
------------

Install the package from github using devtools:

    devtools::install_github("VoisinneG/queryup")
    library(queryup)

Queries
-------

A query is a list containing character vectors named after existing
uniprot fields. The list of all available fileds is shown below.
Different query fields must be matched simultaneously. This query will
return the uniprot ids of all proteins encoded by gene *Pik3r1*.

    query <- list( "gene_exact" = "Pik3r1" )
    df <- query_uniprot(query, columns = "id")

    ##         Entry    
    ##  A0A087WQM2:  1  
    ##  A0A087X689:  1  
    ##  A0A096MNU6:  1  
    ##  A0A0A9YVC8:  1  
    ##  A0A0B2UIC9:  1  
    ##  A0A0B8S032:  1  
    ##  (Other)   :259

We can retrieve additionnal data using the `columns` parameter.

    df <- query_uniprot(query, columns = c("id", "genes", "reviewed", "organism"))
    summary(df)

    ##         Entry                     Gene.names         Status   
    ##  A0A087WQM2:  1   PIK3R1               :214   reviewed  :  5  
    ##  A0A087X689:  1   Pik3r1               : 15   unreviewed:260  
    ##  A0A096MNU6:  1   pik3r1               : 12                   
    ##  A0A0A9YVC8:  1   PIK3R1 A306_00009840 :  3                   
    ##  A0A0B2UIC9:  1   PIK3R1 CK820_G0034249:  3                   
    ##  A0A0B8S032:  1   pik3r1 LOC557176     :  2                   
    ##  (Other)   :259   (Other)              : 16                   
    ##                                          Organism  
    ##  Homo sapiens (Human)                        : 12  
    ##  Mus musculus (Mouse)                        :  8  
    ##  Sus scrofa (Pig)                            :  8  
    ##  Nothobranchius rachovii (bluefin notho)     :  7  
    ##  Tarsius syrichta (Philippine tarsier)       :  7  
    ##  Nothobranchius furzeri (Turquoise killifish):  6  
    ##  (Other)                                     :217

Combining query fields
----------------------

Our first query returned many matches. We can build more specific
queries by using more than one query field. By default, matching entries
must satisfy all query fields simultaneously.

    query <- list( "gene_exact" = "Pik3r1", "reviewed" = "yes", "organism" = "9606" )
    df <- query_uniprot(query, columns = c("id", "genes", "organism", "reviewed"))
    summary(df)

    ##     Entry         Gene.names                 Organism      Status 
    ##  P27986:1   PIK3R1 GRB1:1    Homo sapiens (Human):1   reviewed:1

Multiple items per query field
------------------------------

It is also possible to looked for entries that match different items
within a query field. Items from a given query field are looked for
independently. The following query will return all proteins encoded by
either *Pik3r1* or *Pik3r2* in either *Mus musculus* (taxon: 10060) or
*Homo sapiens* (taxon: 9606): Hence

    query <- list( "gene_exact" = c("Pik3r1", "Pik3r2"), "organism" = c("9606", "10060"))
    df <- query_uniprot(query, columns = "id")

    ## Querying uniprot...

    summary(df)

    ##         Entry   
    ##  A0A024R7N6: 1  
    ##  A0A1D8GZE0: 1  
    ##  A0A1D8GZE1: 1  
    ##  A0A2X0SFG1: 1  
    ##  E5RGI8    : 1  
    ##  E5RHI0    : 1  
    ##  (Other)   :13

List of all available query fields
----------------------------------

Here is the list of all query fields available

<table>
<thead>
<tr class="header">
<th align="left">Field</th>
<th align="left">Example</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">accession</td>
<td align="left">accession:P62988</td>
<td align="left">Lists all entries with the primary or secondary // accession number P62988.</td>
</tr>
<tr class="even">
<td align="left">active</td>
<td align="left">active:no</td>
<td align="left">Lists all obsolete entries.</td>
</tr>
<tr class="odd">
<td align="left">annotation</td>
<td align="left">annotation:(type:non-positional) // annotation:(type:positional) // // annotation:(type:mod_res &quot;Pyrrolidone carboxylic acid&quot; evidence:experimental)</td>
<td align="left">Lists all entries with: // any general annotation (comments [CC]) // any sequence annotation (features [FT]) // at least one amino acid modified with a Pyrrolidone carboxylic acid group</td>
</tr>
<tr class="even">
<td align="left">author</td>
<td align="left">author:ashburner</td>
<td align="left">Lists all entries with at least one reference co-authored by Michael Ashburner.</td>
</tr>
<tr class="odd">
<td align="left">cdantigen</td>
<td align="left">cdantigen:CD233</td>
<td align="left">Lists all entries whose cluster of differentiation number is CD233 (see cdlist.txt).</td>
</tr>
<tr class="even">
<td align="left">citation</td>
<td align="left">citation:(&quot;intracellular structural proteins&quot;) // citation:(author:ashburner journal:nature) // citation:9169874</td>
<td align="left">Lists all entries with a literature citation: // containing the phrase &quot;intracellular structural proteins&quot; in either title or abstract // co-authored by Michael Ashburner and published in Nature // with the PubMed identifier 9169874</td>
</tr>
<tr class="odd">
<td align="left">cluster</td>
<td align="left">cluster:(uniprot:A5YMT3 identity:0.9)</td>
<td align="left">Lists all entries in the UniRef 90% identity cluster whose // representative sequence is UniProtKB entry A5YMT3 (about UniRef).</td>
</tr>
<tr class="even">
<td align="left">count</td>
<td align="left">annotation:(type:transmem count:5)annotation:(type:transmem count:[5 TO *])annotation:(type:cofactor count:[3 TO *])</td>
<td align="left">Lists all entries with: // exactly 5 transmembrane regions // 5 or more transmembrane regions // 3 or more Cofactor comments</td>
</tr>
<tr class="odd">
<td align="left">created</td>
<td align="left">created:[20121001 TO *]reviewed:yes AND created:[current TO *]</td>
<td align="left">Lists all entries created since October 1st 2012. // Lists all new UniProtKB/Swiss-Prot entries in the last release.</td>
</tr>
<tr class="even">
<td align="left">database</td>
<td align="left">database:(type:pfam) // database:(type:pdb 1aut)</td>
<td align="left">Lists all entries with: // a cross-reference to the Pfam database // a cross-reference to the PDB database entry 1aut // // (see Databases cross-referenced in UniProtKB and Database mapping)</td>
</tr>
<tr class="odd">
<td align="left">ec</td>
<td align="left">ec:3.2.1.23</td>
<td align="left">Lists all beta-galactosidases (Enzyme nomenclature database).</td>
</tr>
<tr class="even">
<td align="left">evidence</td>
<td align="left">annotation:(type:signal evidence:ECO_0000269)(type:mod_res phosphoserine evidence:ECO_0000269)annotation:(type:function AND evidence:ECO_0000255)</td>
<td align="left">Lists all entries with: // a signal sequence whose positions have been experimentally proven // experimentally proven phosphoserine sites // a function manually asserted according to rules // // (see Evidence attribution)</td>
</tr>
<tr class="odd">
<td align="left">existence</td>
<td align="left">existence:&quot;inferred from homology&quot;</td>
<td align="left">See Protein existence criteria.</td>
</tr>
<tr class="even">
<td align="left">family</td>
<td align="left">family:serpin</td>
<td align="left">Lists all entries belonging to the Serpin family of proteins (Index of protein domains and families).</td>
</tr>
<tr class="odd">
<td align="left">fragment</td>
<td align="left">fragment:yes</td>
<td align="left">Lists all entries with an incomplete sequence.</td>
</tr>
<tr class="even">
<td align="left">gene</td>
<td align="left">gene:HPSE</td>
<td align="left">Lists all entries for proteins encoded by gene HPSE, but also by HPSE2.</td>
</tr>
<tr class="odd">
<td align="left">gene_exact</td>
<td align="left">gene_exact:HPSE</td>
<td align="left">Lists all entries for proteins encoded by gene HPSE, but excluding variations like HPSE2 or HPSE_0.</td>
</tr>
<tr class="even">
<td align="left">goa</td>
<td align="left">goa:(cytoskeleton) // <a href="go:0015629" class="uri">go:0015629</a></td>
<td align="left">Lists all entries associated with: // a GO term containing the word &quot;cytoskeleton&quot; // the GO term Actin cytoskeleton and any subclasses</td>
</tr>
<tr class="odd">
<td align="left">host</td>
<td align="left">host:mouse // host:10090 // host:40674</td>
<td align="left">Lists all entries for viruses infecting: // organisms with a name containing the word &quot;mouse&quot; (including Arabidopsis thaliana (Mouse-ear cress)!) // Mus musculus (Mouse) // all mammals (all taxa classified under the taxonomy node for Mammalia)</td>
</tr>
<tr class="even">
<td align="left">id</td>
<td align="left">id:P00750</td>
<td align="left">Returns the entry with the primary // accession number P00750.</td>
</tr>
<tr class="odd">
<td align="left">inn</td>
<td align="left">inn:Anakinra</td>
<td align="left">Lists all entries whose &quot;International Nonproprietary Name&quot; is Anakinra.</td>
</tr>
<tr class="even">
<td align="left">interactor</td>
<td align="left">interactor:P00520</td>
<td align="left">Lists all entries describing interactions with the protein described by // entry P00520.</td>
</tr>
<tr class="odd">
<td align="left">keyword</td>
<td align="left">keyword:toxinkeyword:&quot;Toxin [KW-0800]&quot;</td>
<td align="left">Lists all entries associated with a keyword matching &quot;Toxin&quot; in its name or description (UniProtKB Keywords). // Lists all entries associated with the UniProtKB keyword Toxin.</td>
</tr>
<tr class="even">
<td align="left">length</td>
<td align="left">length:[500 TO 700]</td>
<td align="left">Lists all entries describing sequences of length between 500 and 700 residues.</td>
</tr>
<tr class="odd">
<td align="left">lineage</td>
<td align="left"></td>
<td align="left">This field is a synonym for the field taxonomy.</td>
</tr>
<tr class="even">
<td align="left">mass</td>
<td align="left">mass:[500000 TO *]</td>
<td align="left">Lists all entries describing sequences with a mass of at least 500,000 Da.</td>
</tr>
<tr class="odd">
<td align="left">method</td>
<td align="left">method:maldi // method:xray</td>
<td align="left">Lists all entries for proteins identified by: matrix-assisted laser // desorption/ionization (MALDI), crystallography (X-Ray). The // method field searches names of physico-chemical // identification methods in the 'Biophysicochemical properties' subsection of the 'Function' section, the 'Publications' and // 'Cross-references' sections.</td>
</tr>
<tr class="even">
<td align="left">mnemonic</td>
<td align="left">mnemonic:ATP6_HUMAN</td>
<td align="left">Lists all entries with entry name (ID) ATP6_HUMAN. Searches also // obsolete entry names (What is the difference between an // accession number (AC) and the entry name?).</td>
</tr>
<tr class="odd">
<td align="left">modified</td>
<td align="left">modified:[20120101 TO 20120301]reviewed:yes AND modified:[current TO *]</td>
<td align="left">Lists all entries that were last modified between January and March 2012. // Lists all UniProtKB/Swiss-Prot entries modified in the last release.</td>
</tr>
<tr class="even">
<td align="left">name</td>
<td align="left">name:&quot;prion protein&quot;</td>
<td align="left">Lists all entries for prion proteins.</td>
</tr>
<tr class="odd">
<td align="left">organelle</td>
<td align="left">organelle:Mitochondrion</td>
<td align="left">Lists all entries for proteins encoded by a gene of the mitochondrial // chromosome.</td>
</tr>
<tr class="even">
<td align="left">organism</td>
<td align="left">organism:&quot;Ovis aries&quot; // organism:9940 // organism:sheep</td>
<td align="left">Lists all entries for proteins expressed in sheep (first 2 examples) and // organisms whose name contains the term &quot;sheep&quot; (UniProt taxonomy).</td>
</tr>
<tr class="odd">
<td align="left">plasmid</td>
<td align="left">plasmid:ColE1</td>
<td align="left">Lists all entries for proteins encoded by a gene of plasmid ColE1 (Controlled vocabulary of plasmids).</td>
</tr>
<tr class="even">
<td align="left">proteome</td>
<td align="left">proteome:UP000005640</td>
<td align="left">Lists all entries from the human proteome.</td>
</tr>
<tr class="odd">
<td align="left">proteomecomponent</td>
<td align="left">proteomecomponent:&quot;chromosome 1&quot; and organism:9606</td>
<td align="left">Lists all entries from the human chromosome 1.</td>
</tr>
<tr class="even">
<td align="left">replaces</td>
<td align="left">replaces:P02023</td>
<td align="left">Lists all entries that were created from a merge with entry P02023 (see FAQ).</td>
</tr>
<tr class="odd">
<td align="left">reviewed</td>
<td align="left">reviewed:yes</td>
<td align="left">Lists all UniProtKB/Swiss-Prot entries (about // UniProtKB).</td>
</tr>
<tr class="even">
<td align="left">scope</td>
<td align="left">scope:mutagenesis</td>
<td align="left">Lists all entries containing a reference that was used to gather // information about mutagenesis (Entry view: &quot;Cited for&quot;, See // 'Publications' section of the user manual).</td>
</tr>
<tr class="odd">
<td align="left">sequence</td>
<td align="left">sequence:P05067-9</td>
<td align="left">Lists all entries containing a link to isoform 9 of the sequence // described in entry P05067. Allows searching by specific sequence // identifier.</td>
</tr>
<tr class="even">
<td align="left">sequence_modified</td>
<td align="left">sequence_modified:[20120101 TO 20120301]reviewed:yes AND sequence_modified:[current TO *]</td>
<td align="left">Lists all entries whose sequences were last modified between January and March 2012. // Lists all UniProtKB/Swiss-Prot entries whose sequences were modified in the last release.</td>
</tr>
<tr class="odd">
<td align="left">strain</td>
<td align="left">strain:wistar</td>
<td align="left">Lists all entries containing a reference relevant to strain wistar (Lists of strains in reference comments and Taxonomy help: organism strains).</td>
</tr>
<tr class="even">
<td align="left">taxonomy</td>
<td align="left">taxonomy:40674</td>
<td align="left">Lists all entries for proteins expressed in Mammals. This field is used to retrieve // entries for all organisms classified below a given taxonomic node (taxonomy classification).</td>
</tr>
<tr class="odd">
<td align="left">tissue</td>
<td align="left">tissue:liver</td>
<td align="left">Lists all entries containing a reference describing the protein sequence // obtained from a clone isolated from liver (Controlled vocabulary of tissues).</td>
</tr>
<tr class="even">
<td align="left">web</td>
<td align="left">web:wikipedia</td>
<td align="left">Lists all entries for proteins that are described in Wikipedia.</td>
</tr>
</tbody>
</table>

List of all unirot data columns
-------------------------------

Here is the list of all data columns retrieveable using parameter
`column`. Note that the parameter `column` and the name of the
corresponding column in the dataframe (output of `query_uniprot()`) do
not necessarily match.

<table>
<thead>
<tr class="header">
<th align="left">Column names as displayed on website</th>
<th align="left">Column names as displayed in URL</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">Entry</td>
<td align="left">id</td>
</tr>
<tr class="even">
<td align="left">Entry name</td>
<td align="left">entry name</td>
</tr>
<tr class="odd">
<td align="left">Gene names</td>
<td align="left">genes</td>
</tr>
<tr class="even">
<td align="left">Gene names (primary)</td>
<td align="left">genes(PREFERRED)</td>
</tr>
<tr class="odd">
<td align="left">Gene names (synonym)</td>
<td align="left">genes(ALTERNATIVE)</td>
</tr>
<tr class="even">
<td align="left">Gene names (ordered locus)</td>
<td align="left">genes(OLN)</td>
</tr>
<tr class="odd">
<td align="left">Gene names (ORF)</td>
<td align="left">genes(ORF)</td>
</tr>
<tr class="even">
<td align="left">Organism</td>
<td align="left">organism</td>
</tr>
<tr class="odd">
<td align="left">Organism ID</td>
<td align="left">organism-id</td>
</tr>
<tr class="even">
<td align="left">Protein names</td>
<td align="left">protein names</td>
</tr>
<tr class="odd">
<td align="left">Proteomes</td>
<td align="left">proteome</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage</td>
<td align="left">lineage(ALL)</td>
</tr>
<tr class="odd">
<td align="left">Virus hosts</td>
<td align="left">virus hosts</td>
</tr>
<tr class="even">
<td align="left">Fragment</td>
<td align="left">fragment</td>
</tr>
<tr class="odd">
<td align="left">Gene encoded by</td>
<td align="left">encodedon</td>
</tr>
<tr class="even">
<td align="left">Alternative products</td>
<td align="left">comment(ALTERNATIVE PRODUCTS)</td>
</tr>
<tr class="odd">
<td align="left">Erroneous gene model prediction</td>
<td align="left">comment(ERRONEOUS GENE MODEL PREDICTION)</td>
</tr>
<tr class="even">
<td align="left">Erroneous initiation</td>
<td align="left">comment(ERRONEOUS INITIATION)</td>
</tr>
<tr class="odd">
<td align="left">Erroneous termination</td>
<td align="left">comment(ERRONEOUS TERMINATION)</td>
</tr>
<tr class="even">
<td align="left">Erroneous translation</td>
<td align="left">comment(ERRONEOUS TRANSLATION)</td>
</tr>
<tr class="odd">
<td align="left">Frameshift</td>
<td align="left">comment(FRAMESHIFT)</td>
</tr>
<tr class="even">
<td align="left">Mass spectrometry</td>
<td align="left">comment(MASS SPECTROMETRY)</td>
</tr>
<tr class="odd">
<td align="left">Polymorphism</td>
<td align="left">comment(POLYMORPHISM)</td>
</tr>
<tr class="even">
<td align="left">RNA editing</td>
<td align="left">comment(RNA EDITING)</td>
</tr>
<tr class="odd">
<td align="left">Sequence caution</td>
<td align="left">comment(SEQUENCE CAUTION)</td>
</tr>
<tr class="even">
<td align="left">Length</td>
<td align="left">length</td>
</tr>
<tr class="odd">
<td align="left">Mass</td>
<td align="left">mass</td>
</tr>
<tr class="even">
<td align="left">Sequence</td>
<td align="left">sequence</td>
</tr>
<tr class="odd">
<td align="left">Alternative sequence</td>
<td align="left">feature(ALTERNATIVE SEQUENCE)</td>
</tr>
<tr class="even">
<td align="left">Natural variant</td>
<td align="left">feature(NATURAL VARIANT)</td>
</tr>
<tr class="odd">
<td align="left">Non-adjacent residues</td>
<td align="left">feature(NON ADJACENT RESIDUES)</td>
</tr>
<tr class="even">
<td align="left">Non-standard residue</td>
<td align="left">feature(NON STANDARD RESIDUE)</td>
</tr>
<tr class="odd">
<td align="left">Non-terminal residue</td>
<td align="left">feature(NON TERMINAL RESIDUE)</td>
</tr>
<tr class="even">
<td align="left">Sequence conflict</td>
<td align="left">feature(SEQUENCE CONFLICT)</td>
</tr>
<tr class="odd">
<td align="left">Sequence uncertainty</td>
<td align="left">feature(SEQUENCE UNCERTAINTY)</td>
</tr>
<tr class="even">
<td align="left">Sequence version</td>
<td align="left">version(sequence)</td>
</tr>
<tr class="odd">
<td align="left">EC number</td>
<td align="left">ec</td>
</tr>
<tr class="even">
<td align="left">Absorption</td>
<td align="left">comment(ABSORPTION)</td>
</tr>
<tr class="odd">
<td align="left">Catalytic activity</td>
<td align="left">comment(CATALYTIC ACTIVITY)</td>
</tr>
<tr class="even">
<td align="left">Cofactor</td>
<td align="left">comment(COFACTOR)</td>
</tr>
<tr class="odd">
<td align="left">Enzyme regulation</td>
<td align="left">comment(ENZYME REGULATION)</td>
</tr>
<tr class="even">
<td align="left">Function[CC]i</td>
<td align="left">comment(FUNCTION)</td>
</tr>
<tr class="odd">
<td align="left">Kinetics</td>
<td align="left">comment(KINETICS)</td>
</tr>
<tr class="even">
<td align="left">Pathway</td>
<td align="left">comment(PATHWAY)</td>
</tr>
<tr class="odd">
<td align="left">Redox potential</td>
<td align="left">comment(REDOX POTENTIAL)</td>
</tr>
<tr class="even">
<td align="left">Temperature dependence</td>
<td align="left">comment(TEMPERATURE DEPENDENCE)</td>
</tr>
<tr class="odd">
<td align="left">pH dependence</td>
<td align="left">comment(PH DEPENDENCE)</td>
</tr>
<tr class="even">
<td align="left">Active site</td>
<td align="left">feature(ACTIVE SITE)</td>
</tr>
<tr class="odd">
<td align="left">Binding site</td>
<td align="left">feature(BINDING SITE)</td>
</tr>
<tr class="even">
<td align="left">DNA binding</td>
<td align="left">feature(DNA BINDING)</td>
</tr>
<tr class="odd">
<td align="left">Metal binding</td>
<td align="left">feature(METAL BINDING)</td>
</tr>
<tr class="even">
<td align="left">Nucleotide binding</td>
<td align="left">feature(NP BIND)</td>
</tr>
<tr class="odd">
<td align="left">Site</td>
<td align="left">feature(SITE)</td>
</tr>
<tr class="even">
<td align="left">Annotation score</td>
<td align="left">annotation score</td>
</tr>
<tr class="odd">
<td align="left">Features</td>
<td align="left">features</td>
</tr>
<tr class="even">
<td align="left">Caution</td>
<td align="left">comment(CAUTION)</td>
</tr>
<tr class="odd">
<td align="left">Miscellaneous[CC]</td>
<td align="left">comment(MISCELLANEOUS)</td>
</tr>
<tr class="even">
<td align="left">Keywords</td>
<td align="left">keywords</td>
</tr>
<tr class="odd">
<td align="left">Matched text</td>
<td align="left">context</td>
</tr>
<tr class="even">
<td align="left">Protein existence</td>
<td align="left">existence</td>
</tr>
<tr class="odd">
<td align="left">Tools</td>
<td align="left">tools</td>
</tr>
<tr class="even">
<td align="left">Reviewed</td>
<td align="left">reviewed</td>
</tr>
<tr class="odd">
<td align="left">Subunit structure[CC]i</td>
<td align="left">comment(SUBUNIT)</td>
</tr>
<tr class="even">
<td align="left">Interacts with</td>
<td align="left">interactor</td>
</tr>
<tr class="odd">
<td align="left">Developmental stage</td>
<td align="left">comment(DEVELOPMENTAL STAGE)</td>
</tr>
<tr class="even">
<td align="left">Induction</td>
<td align="left">comment(INDUCTION)</td>
</tr>
<tr class="odd">
<td align="left">Tissue specificity</td>
<td align="left">comment(TISSUE SPECIFICITY)</td>
</tr>
<tr class="even">
<td align="left">Gene ontology (GO)</td>
<td align="left">go</td>
</tr>
<tr class="odd">
<td align="left">Gene ontology (biological process)</td>
<td align="left">go(biological process)</td>
</tr>
<tr class="even">
<td align="left">Gene ontology (molecular function)</td>
<td align="left">go(molecular function)</td>
</tr>
<tr class="odd">
<td align="left">Gene ontology (cellular component)</td>
<td align="left">go(cellular component)</td>
</tr>
<tr class="even">
<td align="left">Gene ontology IDs</td>
<td align="left">go-id</td>
</tr>
<tr class="odd">
<td align="left">Allergenic properties</td>
<td align="left">comment(ALLERGEN)</td>
</tr>
<tr class="even">
<td align="left">Biotechnological use</td>
<td align="left">comment(BIOTECHNOLOGY)</td>
</tr>
<tr class="odd">
<td align="left">Disruption phenotype</td>
<td align="left">comment(DISRUPTION PHENOTYPE)</td>
</tr>
<tr class="even">
<td align="left">Involvement in disease</td>
<td align="left">comment(DISEASE)</td>
</tr>
<tr class="odd">
<td align="left">Pharmaceutical use</td>
<td align="left">comment(PHARMACEUTICAL)</td>
</tr>
<tr class="even">
<td align="left">Toxic dose</td>
<td align="left">comment(TOXIC DOSE)</td>
</tr>
<tr class="odd">
<td align="left">Subcellular location[CC]i</td>
<td align="left">comment(SUBCELLULAR LOCATION)</td>
</tr>
<tr class="even">
<td align="left">Intramembrane</td>
<td align="left">feature(INTRAMEMBRANE)</td>
</tr>
<tr class="odd">
<td align="left">Topological domain</td>
<td align="left">feature(TOPOLOGICAL DOMAIN)</td>
</tr>
<tr class="even">
<td align="left">Transmembrane</td>
<td align="left">feature(TRANSMEMBRANE)</td>
</tr>
<tr class="odd">
<td align="left">Post-translational modification</td>
<td align="left">comment(PTM)</td>
</tr>
<tr class="even">
<td align="left">Chain</td>
<td align="left">feature(CHAIN)</td>
</tr>
<tr class="odd">
<td align="left">Cross-link</td>
<td align="left">feature(CROSS LINK)</td>
</tr>
<tr class="even">
<td align="left">Disulfide bond</td>
<td align="left">feature(DISULFIDE BOND)</td>
</tr>
<tr class="odd">
<td align="left">Glycosylation</td>
<td align="left">feature(GLYCOSYLATION)</td>
</tr>
<tr class="even">
<td align="left">Initiator methionine</td>
<td align="left">feature(INITIATOR METHIONINE)</td>
</tr>
<tr class="odd">
<td align="left">Lipidation</td>
<td align="left">feature(LIPIDATION)</td>
</tr>
<tr class="even">
<td align="left">Modified residue</td>
<td align="left">feature(MODIFIED RESIDUE)</td>
</tr>
<tr class="odd">
<td align="left">Peptide</td>
<td align="left">feature(PEPTIDE)</td>
</tr>
<tr class="even">
<td align="left">Propeptide</td>
<td align="left">feature(PROPEPTIDE)</td>
</tr>
<tr class="odd">
<td align="left">Signal peptide</td>
<td align="left">feature(SIGNAL)</td>
</tr>
<tr class="even">
<td align="left">Transit peptide</td>
<td align="left">feature(TRANSIT)</td>
</tr>
<tr class="odd">
<td align="left">3D</td>
<td align="left">3d</td>
</tr>
<tr class="even">
<td align="left">Beta strand</td>
<td align="left">feature(BETA STRAND)</td>
</tr>
<tr class="odd">
<td align="left">Helix</td>
<td align="left">feature(HELIX)</td>
</tr>
<tr class="even">
<td align="left">Turn</td>
<td align="left">feature(TURN)</td>
</tr>
<tr class="odd">
<td align="left">Mapped PubMed ID</td>
<td align="left">citationmapping</td>
</tr>
<tr class="even">
<td align="left">PubMed ID</td>
<td align="left">citation</td>
</tr>
<tr class="odd">
<td align="left">Date of creation</td>
<td align="left">created</td>
</tr>
<tr class="even">
<td align="left">Date of last modification</td>
<td align="left">last-modified</td>
</tr>
<tr class="odd">
<td align="left">Date of last sequence modification</td>
<td align="left">sequence-modified</td>
</tr>
<tr class="even">
<td align="left">Entry version</td>
<td align="left">version(entry)</td>
</tr>
<tr class="odd">
<td align="left">Domain[CC]</td>
<td align="left">comment(DOMAIN)</td>
</tr>
<tr class="even">
<td align="left">Sequence similarities</td>
<td align="left">comment(SIMILARITY)</td>
</tr>
<tr class="odd">
<td align="left">Protein families</td>
<td align="left">families</td>
</tr>
<tr class="even">
<td align="left">Coiled coil</td>
<td align="left">feature(COILED COIL)</td>
</tr>
<tr class="odd">
<td align="left">Compositional bias</td>
<td align="left">feature(COMPOSITIONAL BIAS)</td>
</tr>
<tr class="even">
<td align="left">Domain[FT]</td>
<td align="left">feature(DOMAIN EXTENT)</td>
</tr>
<tr class="odd">
<td align="left">Motif</td>
<td align="left">feature(MOTIF)</td>
</tr>
<tr class="even">
<td align="left">Region</td>
<td align="left">feature(REGION)</td>
</tr>
<tr class="odd">
<td align="left">Repeat</td>
<td align="left">feature(REPEAT)</td>
</tr>
<tr class="even">
<td align="left">Zinc finger</td>
<td align="left">feature(ZINC FINGER)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (all)</td>
<td align="left">lineage(all)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (SUPERKINGDOM)</td>
<td align="left">lineage(SUPERKINGDOM)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (KINGDOM)</td>
<td align="left">lineage(KINGDOM)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (SUBKINGDOM)</td>
<td align="left">lineage(SUBKINGDOM)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (SUPERPHYLUM)</td>
<td align="left">lineage(SUPERPHYLUM)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (PHYLUM)</td>
<td align="left">lineage(PHYLUM)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (SUBPHYLUM)</td>
<td align="left">lineage(SUBPHYLUM)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (SUPERCLASS)</td>
<td align="left">lineage(SUPERCLASS)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (CLASS)</td>
<td align="left">lineage(CLASS)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (SUBCLASS)</td>
<td align="left">lineage(SUBCLASS)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (INFRACLASS)</td>
<td align="left">lineage(INFRACLASS)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (SUPERORDER)</td>
<td align="left">lineage(SUPERORDER)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (ORDER)</td>
<td align="left">lineage(ORDER)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (SUBORDER)</td>
<td align="left">lineage(SUBORDER)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (INFRAORDER)</td>
<td align="left">lineage(INFRAORDER)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (PARVORDER)</td>
<td align="left">lineage(PARVORDER)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (SUPERFAMILY)</td>
<td align="left">lineage(SUPERFAMILY)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (FAMILY)</td>
<td align="left">lineage(FAMILY)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (SUBFAMILY)</td>
<td align="left">lineage(SUBFAMILY)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (TRIBE)</td>
<td align="left">lineage(TRIBE)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (SUBTRIBE)</td>
<td align="left">lineage(SUBTRIBE)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (GENUS)</td>
<td align="left">lineage(GENUS)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (SUBGENUS)</td>
<td align="left">lineage(SUBGENUS)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (SPECIES GROUP)</td>
<td align="left">lineage(SPECIES GROUP)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (SPECIES SUBGROUP)</td>
<td align="left">lineage(SPECIES SUBGROUP)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (SPECIES)</td>
<td align="left">lineage(SPECIES)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (SUBSPECIES)</td>
<td align="left">lineage(SUBSPECIES)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic lineage (VARIETAS)</td>
<td align="left">lineage(VARIETAS)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic lineage (FORMA)</td>
<td align="left">lineage(FORMA)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (all)</td>
<td align="left">lineage-id(all)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (SUPERKINGDOM)</td>
<td align="left">lineage-id(SUPERKINGDOM)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (KINGDOM)</td>
<td align="left">lineage-id(KINGDOM)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (SUBKINGDOM)</td>
<td align="left">lineage-id(SUBKINGDOM)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (SUPERPHYLUM)</td>
<td align="left">lineage-id(SUPERPHYLUM)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (PHYLUM)</td>
<td align="left">lineage-id(PHYLUM)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (SUBPHYLUM)</td>
<td align="left">lineage-id(SUBPHYLUM)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (SUPERCLASS)</td>
<td align="left">lineage-id(SUPERCLASS)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (CLASS)</td>
<td align="left">lineage-id(CLASS)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (SUBCLASS)</td>
<td align="left">lineage-id(SUBCLASS)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (INFRACLASS)</td>
<td align="left">lineage-id(INFRACLASS)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (SUPERORDER)</td>
<td align="left">lineage-id(SUPERORDER)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (ORDER)</td>
<td align="left">lineage-id(ORDER)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (SUBORDER)</td>
<td align="left">lineage-id(SUBORDER)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (INFRAORDER)</td>
<td align="left">lineage-id(INFRAORDER)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (PARVORDER)</td>
<td align="left">lineage-id(PARVORDER)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (SUPERFAMILY)</td>
<td align="left">lineage-id(SUPERFAMILY)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (FAMILY)</td>
<td align="left">lineage-id(FAMILY)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (SUBFAMILY)</td>
<td align="left">lineage-id(SUBFAMILY)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (TRIBE)</td>
<td align="left">lineage-id(TRIBE)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (SUBTRIBE)</td>
<td align="left">lineage-id(SUBTRIBE)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (GENUS)</td>
<td align="left">lineage-id(GENUS)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (SUBGENUS)</td>
<td align="left">lineage-id(SUBGENUS)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (SPECIES GROUP)</td>
<td align="left">lineage-id(SPECIES GROUP)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (SPECIES SUBGROUP)</td>
<td align="left">lineage-id(SPECIES SUBGROUP)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (SPECIES)</td>
<td align="left">lineage-id(SPECIES)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (SUBSPECIES)</td>
<td align="left">lineage-id(SUBSPECIES)</td>
</tr>
<tr class="odd">
<td align="left">Taxonomic identifier (VARIETAS)</td>
<td align="left">lineage-id(VARIETAS)</td>
</tr>
<tr class="even">
<td align="left">Taxonomic identifier (FORMA)</td>
<td align="left">lineage-id(FORMA)</td>
</tr>
<tr class="odd">
<td align="left">db_abbrev</td>
<td align="left">database(db_abbrev)</td>
</tr>
<tr class="even">
<td align="left">e.g. EMBL</td>
<td align="left">database(EMBL)</td>
</tr>
</tbody>
</table>
