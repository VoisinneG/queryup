test_that("Long queries work", {

  ids <- uniprot_entries$Entry
  query <- list("accession_id" = ids)
  res <- query_uniprot(query)

  expect_equal(is(res, "data.frame"), TRUE)
  expect_equal("Entry" %in% names(res), TRUE)
  expect_equal(dim(res)[1], length(ids))
  expect_equal(setequal(res[["Entry"]], ids), TRUE)

})


test_that("Long query with a non valid accession ids fails with a warning", {
  ids <- c(uniprot_entries$Entry, "CON_P22682")
  query <- list("accession_id" = ids)
  expect_warning(query_uniprot(query))
})

test_that("Short query works", {
  ids <- uniprot_entries$Entry[1:10]
  query <- list("accession_id" = ids)
  res <- query_uniprot(query)

  expect_equal(is(res, "data.frame"), TRUE)
  expect_equal("Entry" %in% names(res), TRUE)
  expect_equal(dim(res)[1], length(ids))
  expect_equal(setequal(res[["Entry"]], ids), TRUE)
})


test_that("Query with unrecognized query fields fails with a warning", {
  existing_ids <- c("P22682", "P47941")
  query = list("acc_id" = existing_ids) # 'acc_id' is not a valid query field
  expect_warning(query_uniprot(query))
})

test_that("Query with unrecognized field parameter fails with a warning", {
  ids <- c("P22682", "P47941")
  query <- list("accession_id" = ids)
  columns <- c("acc_id") # 'acc_id' is not a valid field parameter
  expect_warning(query_uniprot(query, columns = columns))
})
