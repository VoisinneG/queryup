test_that("Query with incorrect base url returns a message", {
  existing_ids <- c("P22682", "P47941")
  query <- list("accession_id" = existing_ids)
  expect_message(query_uniprot(query,
                               base_url = "https://rest.uniprot.org/uni/"))
})

test_that("Long queries work", {
  # query with 500 entries
  ids <- uniprot_entries$Entry[1:500]
  query <- list("accession_id" = ids)
  res <- query_uniprot(query)
  if(!is.null(res)){
    expect_true(inherits(res, "data.frame"))
  }
})

test_that("Long queries with no columns defined work", {
  # query with 500 entries
  ids <- uniprot_entries$Entry[1:500]
  query <- list("accession_id" = ids)
  res <- query_uniprot(query, columns = NULL)

  if(!is.null(res)){
    expect_true(inherits(res, "data.frame"))
  }
})


test_that("Short queries work", {
  # query with 10 entries
  ids <- uniprot_entries$Entry[1:10]
  query <- list("accession_id" = ids)
  res <- query_uniprot(query)

  if(!is.null(res)){
    expect_true(inherits(res, "data.frame"))
  }
})

test_that("Setting 'max_keys' above 200 produces a message", {
  expect_message(query_uniprot("P22682", max_keys = 301), "200")
})

test_that("Query works when multiple fields have more than 'max_keys=200' items", {
  # query looking for interactions between 400 different entries
  ids <- sample(uniprot_entries$Entry, 400)
  query <- list("accession_id" = ids, "interactor" = ids)
  res <- query_uniprot(query, max_keys = 200,
                       columns = c("accession", "cc_interaction"))

  if(!is.null(res)){
    expect_true(inherits(res, "data.frame"))
  }
})
