context('Test that exports_by_sector_2016 data are in the correct format')

test_that(
  'exports_by_sector_2016 contains the expected columns',
  {
    expect_equal(
      colnames(exports_by_sector_2016),
      c('sector', 'year', 'exports')
    )
  }
)

test_that(
  'exports_by_sector_2016 is the right shape',
  {
    expect_equal(
      dim(exports_by_sector_2016),
      c(40, 3)
    )
  }
)

test_that(
  'exports_by_sector_2016 contain sthe right number of years',
  {
    expect_equal(
      unique(exports_by_sector_2016$year),
      2010:2014
    )
  }
)

test_that(
  'exports_by_sector_2016 contains the right sectors',
  {
    expect_equal(
      sort(as.character(unique(exports_by_sector_2016$sector))),
      sort(
        c('creative',
        'cultural',
        'digital',
        'gambling',
        'sport',
        'telecoms',
        'UK',
        'all_sectors')
        )
    )
  }
)

