context("GVA_by_sector works as expected")

input <- example_working_file("example_working_file.xlsx")
ABS = suppressMessages(extract_ABS_data(input))
GVA = suppressMessages(extract_GVA_data(input))
SIC91 = suppressMessages(extract_SIC91_data(input))
tourism = suppressMessages(extract_tourism_data(input))
# make charities dummy data
load(file.path("testdata", "charities_dummy.rda"))
charities <- charities[-nrow(charities),]


combine_GVA_long <- combine_GVA_long(
  ABS = ABS,
  GVA = GVA,
  SIC91 = SIC91,
  DCMS_sectors = eesectors::DCMS_sectors)

GVA_by_sector <- GVA_by_sector(
  combine_GVA_long = combine_GVA_long,
  GVA = GVA,
  tourism = tourism,
  charities = charities)

# test_that(
#   "GVA_by_sector returns object with right class", {
#     expect_identical(
#       class(GVA_by_sector),
#       #c("GVA_by_sector", "tbl_df", "tbl", "data.frame"))
#       c("year_sector_data"))
#   }
# )

test_that(
  "GVA_by_sector throws error if given wrong dataframe", {
    class(GVA) <- class(GVA)[-1]
    expect_error(GVA_by_sector(
      combine_GVA_long = combine_GVA_long,
      GVA = GVA,
      tourism = tourism,
      charities = charities))
  }
)
