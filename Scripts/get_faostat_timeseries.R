library(tidyverse)
library(FAOSTAT)
## Package under active development: https://gitlab.com/paulrougieux/faostatpackage


# countries <- FAOcountryProfile$FAO_TABLE_NAME


data_folder <- "data_raw_faostat"
dir.create(data_folder)

datasets <- FAOsearch(dataset="", full = TRUE) %>%
  filter(!datasetcode %in% c("BC", "BL", "ET"))

# Get all FAO data sets
fao_list <- list()
for (i in 1:length(datasets$datasetcode)) {
  print(datasets$datasetcode[i])
  cur_data <- get_faostat_bulk(code = datasets$datasetcode[i], data_folder = data_folder)
  fao_list[[i]] <- cur_data
}


# Not all data sets are compatible for merging. Select data sets with similar format
sub_list <- list()
for (i in 1:length(fao_list)) {
  print(i)
  cur_index <- length(sub_list) + 1
  std_cols <- c("area_code","area","item_code","item","element_code","element","year_code","year","unit","value","flag")
  cols_with_note <- c("area_code","area","item_code","item","element_code","element","year_code","year","unit","value","flag","note")
  cur_names <- names(fao_list[[i]])
  if (all(cur_names %in% std_cols) & all(std_cols %in% cur_names)) {
    cur_df <- fao_list[[i]] %>%
      mutate(note = NA) %>%
      mutate_all(as.character)
    sub_list[[cur_index]] <- cur_df
  } else if (all(cur_names %in% cols_with_note) & all(cols_with_note %in% cur_names)) {
    sub_list[[cur_index]] <- fao_list[[i]] %>%
      mutate_all(as.character) # To avoid issues when merging
  }
}

countries <- c("Ethiopia", "Mali", "Iraq", "Bangladesh")

fao_data <- do.call(bind_rows, sub_list) %>%
  filter(area %in% countries)

write.csv(fao_data, "fao_data.csv")