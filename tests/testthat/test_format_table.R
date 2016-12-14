context('Test the format_table method')

test_that(
  'format_table runs without errors',
  {

    a <- long_data(GVA_by_sector_2016)

    expect_output(b <- format_table(a, html = FALSE))

    expect_is(b, c("tbl_df", "tbl", "data.frame"))

    expect_equal(ncol(b), 10)

  }
)

test_that(
  'End to end test of format_table for gva',
  {

    a <- long_data(GVA_by_sector_2016)
    b <- format_table(a, html = FALSE)

    expect_equivalent(b, GVA_table)

    }
  )
