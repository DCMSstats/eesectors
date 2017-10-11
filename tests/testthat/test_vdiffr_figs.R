context("vdiffr check of GVA figures")
# https://github.com/lionel-/vdiffr

gva <- suppressMessages(
  eesectors::year_sector_data(eesectors::GVA_by_sector_2016)
  )

disp_fig_3_1 <- eesectors::figure3.1(gva)
disp_fig_3_2 <- eesectors::figure3.2(gva)
disp_fig_3_3 <- eesectors::figure3.3(gva)

# Supply an empty string to path for the root folder storage.
vdiffr::expect_doppelganger(title = "Figure 3.1",
                            fig = disp_fig_3_1,
                            path = "")
vdiffr::expect_doppelganger("Figure 3.2",
                            disp_fig_3_2,
                            path = "")
vdiffr::expect_doppelganger("Figure 3.3",
                            disp_fig_3_3,
                            path = "")
