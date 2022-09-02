test_that("Query with the wrong format fail", {
  # Query should be a 'list' or a 'character' vector of size 1
  expect_equal(get_uniprot_data(NULL), NULL)
  expect_equal(get_uniprot_data(), NULL)
  expect_equal(get_uniprot_data(1:10), NULL)
  expect_equal(get_uniprot_data(c("P22682", "P47941")), NULL)
})

test_that("Query with a single UniProt identifier work", {
  expect_equal(is(get_uniprot_data("P22682")$content, "data.frame"), TRUE)
})

test_that("Call with no 'columns' defined works", {
  ids <- c("P22682", "P47941")
  query <- list("accession_id" = ids)
  res <- get_uniprot_data(query, columns = NULL)$content
  expect_equal(res[["Entry"]], ids)
  expect_equal(get_uniprot_data("P22682", columns = NULL)$content[["Entry"]],
               "P22682")
})

test_that("A message is returned if 'print_url = TRUE'", {
  expect_message(get_uniprot_data("P22682", print_url = TRUE))
})

test_that("Basic query works", {
  ids <- c("P22682", "P47941")
  query <- list("accession_id" = ids)
  res <- get_uniprot_data(query)$content

  expect_equal(is(res, "data.frame"), TRUE)
  expect_equal("Entry" %in% names(res), TRUE)
  expect_equal(dim(res)[1], length(ids))
  expect_equal(setequal(res[["Entry"]], ids), TRUE)
})

test_that("Query with unrecognized query fields fails with a warning", {
  existing_ids <- c("P22682", "P47941")
  query <- list("acc_id" = existing_ids) # 'acc_id' is not a valid query field
  expect_warning(get_uniprot_data(query))
})


test_that("Query with unrecognized field parameter fails with a warning", {
  ids <- c("P22682", "P47941")
  query <- list("accession_id" = ids)
  columns <- c("acc_id") # 'acc_id' is not a valid field parameter
  expect_warning(get_uniprot_data(query, columns = columns))
})

test_that("Query with a non valid accession ids fails with a warning", {
  ids <- c("P226", "A0A0U1ZFN5", "P22682", "CON_P22682", "REV_P47941")
  query <- list("accession_id" = ids)
  expect_warning(get_uniprot_data(query))
})

test_that("Long queries fail with a warning", {
  ids <- uniprot_entries$Entry
  query <- list("accession_id" = ids)
  expect_warning(get_uniprot_data(query))
})
