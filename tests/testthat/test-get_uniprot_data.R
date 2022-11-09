test_that("Query with the wrong format returns NULL", {
  # Query should be a 'list' or a 'character' vector of size 1
  expect_equal(get_uniprot_data(NULL), NULL)
  expect_equal(get_uniprot_data(), NULL)
  expect_equal(get_uniprot_data(1:10), NULL)
  expect_equal(get_uniprot_data(c("P22682", "P47941")), NULL)
})

test_that("Query with a single UniProt identifier works", {
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

test_that("A message is returned if 'print_url' is TRUE", {
  expect_message(get_uniprot_data("P22682", print_url = TRUE), "http")
})

test_that("A message is returned if 'print_uniprot_messages' is TRUE", {
  expect_message(get_uniprot_data(
    list("accession_id" = "CON_P22682"),
    print_uniprot_messages = TRUE),
    "UniProtKB")
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
  expect_warning(get_uniprot_data(query), "request failed")
})


test_that("Query with unrecognized field parameter fails with a warning", {
  ids <- c("P22682", "P47941")
  query <- list("accession_id" = ids)
  columns <- c("acc_id") # 'acc_id' is not a valid field parameter
  expect_warning(get_uniprot_data(query, columns = columns), "request failed")
})

test_that("Query with only non valid entries works", {
  ids <- paste0("CON_", uniprot_entries$Entry[1:300])
  query <- list("accession_id" = ids)
  # first message for the presence of invalid values
  # second message for the absence of valid values
  expect_message(
    expect_message(get_uniprot_data(query), "invalid values were found"),
    "no valid entries")
  expect_equal(length(get_uniprot_data(query)$content$Entry), 0)
})

test_that("Query with non valid entries for multiple query fields works", {
  ids <- paste0("CON_", uniprot_entries$Entry[1:300])
  query <- list("accession_id" = ids, "accession" = ids)
  # first message for the presence of invalid values
  # second message for the absence of valid values
  expect_message(
    expect_message(get_uniprot_data(query), "invalid values were found"),
    "no valid entries")
  expect_equal(length(get_uniprot_data(query)$content$Entry), 0)
})

test_that("Query with valid and invalid values work", {
  invalid_ids <- c("P226", "CON_P22682", "REV_P47941")
  valid_ids <- c("A0A0U1ZFN5", "P22682")
  ids <- c(invalid_ids, valid_ids)
  query <- list("accession_id" = ids)
  expect_message(get_uniprot_data(query), "invalid values were found")
  expect_equal(
    setequal(get_uniprot_data(query)$content$Entry, valid_ids),
    TRUE)
})

test_that("Long queries work", {
  ids <- uniprot_entries$Entry
  query <- list("accession_id" = ids)
  expect_equal(
    setequal(get_uniprot_data(query)$content$Entry, ids),
    TRUE)
})
