test_that("Only objects of type 'list' or 'character' vectors of size 1 are accepted as inputs", {
  expect_equal(get_uniprot_data(NULL), NULL)
  expect_equal(get_uniprot_data(), NULL)
  expect_equal(get_uniprot_data(1:10), NULL)
  expect_equal(get_uniprot_data(c("P22682", "P47941"), print_full_query = TRUE), NULL)
})

test_that("Basic query works", {

  existing_ids <- c("P22682", "P47941")
  proper_query <- list("accession_id" = existing_ids)
  res <- get_uniprot_data(proper_query)

  expect_equal(is(res, "data.frame"), TRUE)
  expect_equal("Entry" %in% names(res), TRUE)
  expect_equal(dim(res)[1], length(existing_ids))
  expect_equal(setequal(res[["Entry"]], existing_ids), TRUE)
})

test_that("Query with unrecognized keys return an error", {

  existing_ids <- c("CON_P22682", "CON_P47941")
  query = list("acc_id" = existing_ids)
  expect_error(get_uniprot_data(query, ))

})
