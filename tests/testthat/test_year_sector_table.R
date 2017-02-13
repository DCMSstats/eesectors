context('Test the year_sector_table method')

test_that(
  'year_sector_table runs without errors',
  {

    a <- year_sector_data(GVA_by_sector_2016)

    expect_output(b <- year_sector_table(a, html = FALSE))

    expect_is(b, c("tbl_df", "tbl", "data.frame"))

    expect_equal(ncol(b), 10)

  }
)

test_that(
  'End to end test of year_sector_table for gva',
  {

    a <- year_sector_data(GVA_by_sector_2016)
    b <- year_sector_table(a, html = FALSE)

    expect_equivalent(b, GVA_table)

    }
  )
