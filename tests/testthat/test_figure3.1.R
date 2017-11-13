context("figure3.1 works as expected")

test_that(
  "figure3.1 runs without errors",
  {

    gva <- year_sector_data(GVA_by_sector_2016)

    expect_silent(figure3.1(gva))

  }
)
