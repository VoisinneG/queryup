test_that("Long queries work", {
  # query with 1000 entries
  ids <- uniprot_entries$Entry
  query <- list("accession_id" = ids)
  res <- query_uniprot(query)
  expect_equal(setequal(res[["Entry"]], ids), TRUE)
})

test_that("Long queries with no columns defined work", {
  # query with 1000 entries
  ids <- uniprot_entries$Entry
  query <- list("accession_id" = ids)
  res <- query_uniprot(query, columns = NULL)
  expect_equal(setequal(res[["Entry"]], ids), TRUE)
})


test_that("Short queries work", {
  # query with 10 entries
  ids <- uniprot_entries$Entry[1:10]
  query <- list("accession_id" = ids)
  res <- query_uniprot(query)
  expect_equal(setequal(res[["Entry"]], ids), TRUE)
})

test_that("Setting 'max_keys' above 300 produces a warning", {
  expect_warning(query_uniprot("P22682", max_keys = 301), "300")
})

test_that("Query works when multiple fields have more than 'max_keys' items", {
  # query looking for interactions between 400 different entries
  ids <- sample(uniprot_entries$Entry, 400)
  query <- list("accession_id" = ids, "interactor" = ids)
  res <- query_uniprot(query, max_keys = 300,
                       columns = c("accession", "cc_interaction"))
  expect_equal(is(res, "data.frame"), TRUE)
})
