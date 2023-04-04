test_that("Query with the wrong format returns a message", {
  # Query should be a 'list' or a 'character' vector of size 1
  expect_equal(get_uniprot_data(NULL), NULL)
  expect_message(get_uniprot_data(NULL),
                 "Query not supported")
  expect_equal(get_uniprot_data(), NULL)
  expect_message(get_uniprot_data(),
                 "Query not supported")
  expect_equal(get_uniprot_data(1:10), NULL)
  expect_message(get_uniprot_data(1:10),
                 "Query not supported")
  expect_equal(get_uniprot_data(c("P22682", "P47941")), NULL)
  expect_message(get_uniprot_data(c("P22682", "P47941")),
                 "Query not supported")
})

test_that("Query with a single UniProt identifier works", {
  res <- get_uniprot_data("P22682")
  if(!is.null(res)){
    expect_true(res$status>0)
  }
})

test_that("Call with no 'columns' defined works", {
  ids <- c("P22682", "P47941")
  query <- list("accession_id" = ids)
  res <- get_uniprot_data(query)
  if(!is.null(res)){
    expect_true(res$status>0)
  }
})

test_that("Basic query works", {
  ids <- c("P22682", "P47941")
  query <- list("accession_id" = ids)

  res <- get_uniprot_data(query)

  if(!is.null(res)){
    expect_true(res$status>0)
  }
})

test_that("Query with incorrect base url produces with a message", {
  existing_ids <- c("P22682", "P47941")
  query <- list("accession_id" = existing_ids)
  expect_message(get_uniprot_data(query,
                                  base_url = "https://rest.uniprot.org/uni/"))
})


test_that("Query with unrecognized query fields fails with a message", {
  existing_ids <- c("P22682", "P47941")
  query <- list("acc_id" = existing_ids) # 'acc_id' is not a valid query field
  expect_message(get_uniprot_data(query))

})

test_that("Query with unrecognized field parameter fails with a message", {
  ids <- c("P22682", "P47941")
  query <- list("accession_id" = ids)
  columns <- c("acc_id") # 'acc_id' is not a valid field parameter
  expect_message(get_uniprot_data(query, columns = columns))

})

test_that("Query with only non valid entries works", {
  ids <- paste0("CON_", uniprot_entries$Entry[1:300])
  query <- list("accession_id" = ids)
  res <- get_uniprot_data(query)
  if(!is.null(res)){
    expect_true(res$status>0)
  }
})

test_that("Query with non valid entries for multiple query fields works", {
  ids <- paste0("CON_", uniprot_entries$Entry[1:300])
  query <- list("accession_id" = ids, "accession" = ids)

  res <- get_uniprot_data(query)
  if(!is.null(res)){
    expect_true(res$status>0)
  }
})

test_that("Query with valid and invalid values work", {
  invalid_ids <- c("P226", "CON_P22682", "REV_P47941")
  valid_ids <- c("A0A0U1ZFN5", "P22682")
  ids <- c(invalid_ids, valid_ids)
  query <- list("accession_id" = ids)

  res <- get_uniprot_data(query)
  if(!is.null(res)){
    expect_true(res$status>0)
  }
})

test_that("Long queries work", {
  ids <- uniprot_entries$Entry
  query <- list("accession_id" = ids)

  res <- get_uniprot_data(query)
  if(!is.null(res)){
    expect_true(res$status>0)
  }
})
