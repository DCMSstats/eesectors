#write.xlsx(year_sector_table(combined_GVA), file = "hellomax.xlsx")
#install.packages("openxlsx")
library(openxlsx)

wb <- loadWorkbook(file =
  "G:/Economic Estimates/Rmarkdown/DCMS_Sectors_Economic_Estimates_Template.xlsx")

ysd_headings <-
  c("sector",
    GVA_by_sector2$years,
    "% change 2015 - 2016",
    "% change 2010-2016",
    "% of UK GVA 2016") %>%
  matrix(nrow = 1)

# Contents
writeData(wb, 1, x = "November 2017", startCol = 2, startRow = 10)

# 3.1 - GVA (£m)
writeData(wb, 2, x = combined_GVA2, startCol = 1, startRow = 6)
writeData(wb, 2, x = ysd_headings, startCol = 1, startRow = 6, colNames = FALSE)
writeData(wb, 2, x = "Years: 2010 - 2016", startCol = 1, startRow = 3)

# 3.1a - GVA (2010=100)
writeData(wb, 3, x = indexed, startCol = 1, startRow = 6)
writeData(wb, 3, x = "Years: 2010 - 2016", startCol = 1, startRow = 3)

saveWorkbook(wb, "G:/Economic Estimates/Rmarkdown/excel_tables.xlsx", overwrite = TRUE)


wb <- loadWorkbook(file =
  "G:/Economic Estimates/Rmarkdown/DCMS_Sectors_Economic_Estimates_2016_GVA_Sub_sectors_Template.xlsx")

# Contents
#writeData(wb, 1, x = "November 2017", startCol = 2, startRow = 10)

# 1 - Creative Industries (£m)
writeData(wb, 2, x = creative_table, startCol = 1, startRow = 6)
#writeData(wb, 2, x = ysd_headings, startCol = 1, startRow = 6, colNames = FALSE)
#writeData(wb, 2, x = "Years: 2010 - 2016", startCol = 1, startRow = 3)

# 2 - Digital Sector (£m)
writeData(wb, 3, x = digital_table, startCol = 1, startRow = 6)

# 3 - Cultural Sector (£m)
writeData(wb, 4, x = culture_table, startCol = 1, startRow = 6)

saveWorkbook(wb, "G:/Economic Estimates/Rmarkdown/excel_tables_sub_sectors.xlsx", overwrite = TRUE)



## Add a worksheet
addWorksheet(wb, "A new worksheet")

wb ## view object

names(wb) #list worksheets
