context("extract_GVA_data works as expected")

testxl <- file.path('testdata', 'GVA_test.xlsm')
reference <- file.path('testdata', 'test_reference_GVA.Rds')

test_that(
  "extract_GVA_data can extract data from a dummy spreadsheet",
  {

    sheet_range <- paste(paste(2010:2015), 'Use')

    expect_message(GVA <- extract_GVA_data(testxl, sheet_range = sheet_range, header_rows = 8:9))

    # Check that GVA is the right kind of object, and identical to the reference
    # object.

    expect_is(GVA, c('data.frame', 'tbl', 'tbl_df'))
    #expect_equal_to_reference(GVA, reference)

    # Additionally check that all of the columns from the test spreadsheet have
    # been properly picked up and transposed

    expect_equal(unique(GVA$gva), paste0(1:120))

  }
)
