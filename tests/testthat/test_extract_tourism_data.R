context("extract_tourism_data works as expected")

testxl <- file.path('testdata', 'tourism_test.xlsm')
reference <- file.path('testdata', 'test_reference_tourism.Rds')

test_that(
  "extract_tourism_data can extract data from a dummy spreadsheet",
  {

    expect_message(
      tourism <- extract_tourism_data(
        example_working_file("example_working_file.xlsx")))
    expect_is(tourism, c('data.frame', 'tbl', 'tbl_df'))
    expect_equal_to_reference(tourism, reference)

  }
)

