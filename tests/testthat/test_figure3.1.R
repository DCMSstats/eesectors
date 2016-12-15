context("figure3.1 works as expected")

test_that(
  "figure3.1 runs without errors",
  {

    gva <- long_data(GVA_by_sector_2016)

    expect_silent(figure3.1(gva))

  }
)


test_that(
  "figure3.1 produces expected plot",
  {

    # Check whether comparison file exists, and delete if so

    test_png <- file.path("figures", "test_figure3.1_test.png")
    ref_png <- file.path("figures", "test_figure3.1_reference.png")

    if (file.exists(test_png)) file.remove(test_png)

    test_that(
      "test_png does not already exist",
      {
        expect_false(file.exists(test_png))
        }
      )

    # Create a new figure as png

    a <- long_data(GVA_by_sector_2016)
    b <- figure3.1(a)

    ggplot2::ggsave(
      width = 5,
      height = 5,
      filename = "figures/test_figure3.1_test.png"
    )

    # Check that the new file was created

    test_that(
      "test_png was created",
      {
        expect_true(file.exists(test_png))
      }
    )

    # Compare new figure with reference

    visualTest::isSimilar(
      file = "figures/test_figure3.1_reference.png",
      fingerprint = visualTest::getFingerprint(
        file = "figures/test_figure3.1_test.png"
      ),
      threshold = 1e-3
    )

  }
)
