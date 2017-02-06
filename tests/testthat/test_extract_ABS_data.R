context("extract_ABS_data works as expected")

testxl <- file.path('testdata', 'ABS_test.xlsm')
output <- file.path('testdata', 'test_output_ABS.Rds')
reference <- file.path('testdata', 'test_reference_ABS.Rds')

test_that(
  "extract_ABS_data can extract data from a dummy spreadsheet",
  {

    expect_message(extract_ABS_data(testxl, sheet_name = 'New ABS Data', output_path = 'testdata', save = TRUE, test = TRUE))
    expect_true(file.exists(output))

    ABS <- readRDS(output)

    expect_is(ABS, c('data.frame', 'tbl', 'tbl_df'))
    expect_equal_to_reference(ABS, reference)

  }
)

file.remove(output)
