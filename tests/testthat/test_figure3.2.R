context("figure3.2 works as expected")

test_that(
  "figure3.2 runs without errors",
  {

    gva <- year_sector_data(GVA_by_sector_2016)

    expect_silent(figure3.2(gva))

  }
)
