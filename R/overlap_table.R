
overlap_table <- function(df) {

# function find GVA for a specific sector, for sic codes only used by that
# sector and then sic codes it shares with other sectors
mysum <- function(sector_para) {

  # extract the sic codes used by sector
  temp <-
    df %>%
    filter(sector == sector_para) %>%
    .$SIC %>%
    unique()

  # for the above sic codes sum gva by sector
  df %>%
    filter(year == 2016) %>%
    filter(SIC %in% temp) %>%
    group_by(sector) %>%
    filter(sector != "all_dcms") %>%
    summarise(sum(BB16_GVA))
}

sec_column <- df %>%
  select(sector) %>%
  filter(sector != "all_dcms") %>%
  distinct() %>%
  arrange(sector)

final <- sec_column

for (x in sec_column$sector) {
  #val_quo = enquo(x)
  #print(val_quo)
  final <- full_join(
    final, rename(mysum(x), x = `sum(BB16_GVA)`), by = c("sector"))
}

names(final) <- c("sector", sec_column$sector)
mutate_all(final, function(x) ifelse(is.na(x),0,x))

}

# to interpret output - for each row, the diagonal is the total GVA and each
# other columns are a subset set of this and give the amount the total needs
# to overlap lap with that sector







