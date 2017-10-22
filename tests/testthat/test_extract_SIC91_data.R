context("extract_SIC91_data works as expected")

testxl <- file.path('testdata', 'SIC91_test.xlsm')
reference <- file.path('testdata', 'test_reference_sic91.Rds')

test_that(
  "extract_SIC91_data can extract data from a dummy spreadsheet",
  {

    expect_message(
      SIC91 <- extract_SIC91_data(
        example_working_file("example_working_file.xlsx")))

    expect_is(SIC91, c('data.frame', 'tbl', 'tbl_df'))
    expect_equal_to_reference(SIC91, reference)

  }
)
