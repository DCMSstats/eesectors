context("extract_tourism_data works as expected")

testxl <- file.path('testdata', 'tourism_test.xlsm')
output <- file.path('testdata', 'test_output_tourism.Rds')
reference <- file.path('testdata', 'test_reference_tourism.Rds')

test_that(
  "extract_ABS_data can extract data from a dummy spreadsheet",
  {

    expect_message(extract_tourism_data(testxl, sheet_name = 'Tourism', output_path = 'testdata', test = TRUE))
    expect_true(file.exists(output))

    tourism <- readRDS(output)

    expect_is(tourism, c('data.frame', 'tbl', 'tbl_df'))
    expect_equal_to_reference(tourism, reference)

  }
)

file.remove(output)
