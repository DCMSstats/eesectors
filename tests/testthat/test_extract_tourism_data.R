context("extract_tourism_data works as expected")

testxl <- file.path('testdata', 'tourism_test.xlsm')
reference <- file.path('testdata', 'test_reference_tourism.Rds')

test_that(
  "extract_tourism_data can extract data from a dummy spreadsheet",
  {

    expect_message(tourism <- extract_tourism_data(testxl, sheet_name = 'Tourism'))
    expect_is(tourism, c('data.frame', 'tbl', 'tbl_df'))
    expect_equal_to_reference(tourism, reference)

  }
)

