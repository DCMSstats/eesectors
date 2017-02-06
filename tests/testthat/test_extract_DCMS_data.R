context("extract_DCMS_sectors works as expected")

testxl <- file.path('testdata', 'DCMS_sectors_test.xlsm')
output <- file.path('testdata', 'DCMS_sectors.Rds')

test_that(
  "extract_DCMS_data can extract data from a dummy spreadsheet",
  {

    expect_message(extract_DCMS_sectors(testxl, sheet_name = 'DCMS_sectors_test', skip = 7, output_path = 'testdata'))
    expect_true(file.exists(output))

    DCMS_sectors_output <- readRDS(output)
    DCMS_sectors_output$SIC <- as.character(DCMS_sectors_output$SIC)

    expect_is(DCMS_sectors_output, c('data.frame', 'tbl', 'tbl_df'))

    # Use the built in DCMS_sectors dataset

    expect_identical(DCMS_sectors_output, DCMS_sectors)

  }
)

file.remove(output)
