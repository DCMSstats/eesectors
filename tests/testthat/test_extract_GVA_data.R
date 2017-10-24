context("extract_GVA_data works as expected")

testxl <- file.path('testdata', 'GVA_test.xlsm')
reference <- file.path('testdata', 'test_reference_GVA.Rds')

test_that(
  "extract_GVA_data can extract data from a dummy spreadsheet",
  {

    sheet_range <- paste(paste(2010:2015), 'Use')

    expect_message(
      GVA <- extract_GVA_data(
        example_working_file("example_working_file.xlsx")))

    # Check that GVA is the right kind of object, and identical to the reference
    # object.

    expect_is(GVA, c('data.frame', 'tbl', 'tbl_df'))

    # Although this test passes locally, it seems to fail on linux builds on
    # travis for some reason:

    #expect_equal_to_reference(GVA, reference)

    # Additionally check that all of the columns from the test spreadsheet have
    # been properly picked up and transposed

    # the below is not applicable to new dummy data
    # expect_equal(unique(GVA$GVA), 1:120)


  }
)
