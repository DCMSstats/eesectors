context("extract_DCMS_sectors works as expected")

testxl <- file.path('testdata', 'DCMS_sectors_test.xlsm')

test_that(
  "extract_DCMS_data can extract data from a dummy spreadsheet",
  {

    expect_message(DCMS_sectors_output <- extract_DCMS_sectors(testxl, sheet_name = 'DCMS_sectors_test', skip = 7))

    expect_is(DCMS_sectors_output, c('data.frame', 'tbl', 'tbl_df'))

    # Use the built in DCMS_sectors dataset

    expect_identical(DCMS_sectors_output, DCMS_sectors)

  }
)
