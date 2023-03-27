# queryup 1.0.3

* Better handling of possible errors when using `httr::GET()`

# queryup 1.0.2

* Package dependencies on `RCurl` and `jsonlite` packages have been replaced 
by a single dependency on the `httr` package.
* When a request fails, a message with the http status code is returned.
* Parameters `print_url` and `print_uniprot_messages` have been deprecated.

# queryup 1.0.1

* The function `get_uniprot_data` now works also for long queries (with more 
than 300 items) 

# queryup 1.0.0

* `queryup` is now compatible with the latest UniProt REST API (rest.uniprot.org)
* messages are more informative and will let you know invalid query fields,
invalid return fields and invalid entries
* `queryup` filters out invalid UniProt entries from queries
* `queryup` can manage long queries (with hundreds of entries)
