context('test the maha_check function')

test_that(
  'maha_check runs without errors',
  {

    a <- GVA_by_sector_2016 %>% dplyr::filter(sector == "all_dcms")
    b <- maha_check(a)
    a_split <- split(GVA_by_sector_2016,GVA_by_sector_2016$sector)

    expect_is(b,"data.frame")

    expect_equal(a,b)

    expect_is(lapply(a_split,maha_check),"list")

    }
  )
