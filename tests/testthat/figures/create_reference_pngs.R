library(eesectors)

gva <- long_data(GVA_by_sector_2016)

figure3.1(gva)

ggplot2::ggsave(
  width = 5,
  height = 5,
  filename = "tests/testthat/figures/test_figure3.1_reference.png"
)

figure3.2(gva)

ggplot2::ggsave(
  width = 5,
  height = 5,
  filename = "tests/testthat/figures/test_figure3.2_reference.png"
)

figure3.3(gva)

ggplot2::ggsave(
  width = 5,
  height = 5,
  filename = "tests/testthat/figures/test_figure3.3_reference.png"
)


