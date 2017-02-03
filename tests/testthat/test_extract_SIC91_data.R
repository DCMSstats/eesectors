context("extract_SIC91_data works as expected")

testxl <- file.path('testdata', 'SIC91_test.xlsm')
output <- file.path('testdata', 'test_output_SIC91.Rds')
reference <- file.path('testdata', 'test_reference_sic91.Rds')

test_that(
  "extract_SIC91_data can extract data from a dummy spreadsheet",
  {

    expect_message(extract_SIC91_data(testxl, sheet_name = 'SIC 91 Sales Data', output_path = 'testdata', test = TRUE))
    expect_true(file.exists(output))

    SIC91 <- readRDS(output)

    expect_is(SIC91, c('data.frame', 'tbl', 'tbl_df'))
    expect_equal_to_reference(SIC91, reference)

  }
)

file.remove(output)
