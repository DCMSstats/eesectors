context('Test that imported data are in the correct format')

test_that(
  'GVA_by_sector_2016 contains the expected columns',
  {
    expect_equal(
      colnames(GVA_by_sector_2016),
      c('sector', 'year', 'GVA')
    )
  }
)

test_that(
  'GVA_by_sector_2016 is the right shape',
  {
    expect_equal(
      dim(GVA_by_sector_2016),
      c(54, 3)
    )
  }
)

test_that(
  'GVA_by_sector_2016 contain sthe right number of years',
  {
    expect_equal(
      unique(GVA_by_sector_2016$year),
      2010:2015
    )
  }
)

test_that(
  'GVA_by_sector_2016 contains the right sectors',
  {
    expect_equal(
      sort(as.character(unique(GVA_by_sector_2016$sector))),
      sort(c(
        'Creative Industries',
        'Cultural Sector',
        'Digital Sector',
        'Gambling',
        'Sport',
        'Telecoms',
        'Tourism',
        'UK',
        'all_sectors'))
    )
  }
)

