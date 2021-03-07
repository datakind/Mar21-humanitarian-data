library(pdftools)
library(tidyverse)
library(tabulizer)
library(haven)
library(geojsonio)
library(sf)

# Proof of concept pdf scraping
# extract table sections chosen for extract_areas only include data within "Governorates" section excluding the line with "Governorates"


# File is available in google docs https://drive.google.com/file/d/1jJwf9u04yqiG6GYfIVaBJJqLPXGyobtu/view?usp=sharing
pdf_file <- "Iraq/Iraq 2018 MICS SFR English Volume I - 22 Sep 20.pdf" 

wealth_index_quantiles <- extract_areas(pdf_file, pages = 51)

# wealth_index_quantiles <- extract_tables(pdf_file, pages = 51)
wealth_index_quantiles <- wealth_index_quantiles[[1]]
wealth_index_quantiles <- as.data.frame(wealth_index_quantiles)

wealth_index_quantiles <- wealth_index_quantiles %>%
  rename(poorest = V2,
         second = V3,
         middle = V4,
         fourth = V5,
         richest = V6,
         total_wealth = V7,
         number_of_household_members = V8,
         governorates = V1) %>%
  filter_all(all_vars(!is.na(.)))

woman_literacy <- as.data.frame(extract_areas(pdf_file, pages = 60)[[1]])
woman_literacy <- woman_literacy %>%
  rename(governorates = V1,
         pre_primary_literate = V2,
         pre_primary_illiterate = V3,
         primary_literate = V4,
         primary_illiterate = V5,
         lower_secondary_literate = V6,
         secondary_or_higher_literate = V7,
         total_woman_literacy = V8,
         total_percentage_woman_literate = V9,
         number_of_women_15_to_49_years = V10
         )

childhood_mortality <- as.data.frame(extract_areas(pdf_file, pages = 86)[[1]])
childhood_mortality <- childhood_mortality %>%
  rename(
    governorates = V1,
    neonatal_mortality_rate = V2,
    post_natal_mortality_rate = V3,
    infant_mortality_rate = V4,
    child_mortality_rate = V5,
    under_5_mortality_rate = V6
  )

df <- wealth_index_quantiles %>%
  full_join(woman_literacy, by = "governorates") %>%
  full_join(childhood_mortality, by = "governorates") %>%
  filter(governorates != "Kerbala") %>%
  mutate(
    governorates = case_when(
      governorates == "Duhok" ~ "Dohuk",
      governorates == "Nainawa" ~ "Nineveh",
      governorates == "Sulaimaniya" ~ "Sulaymaniyah",
      governorates == "Diala" ~ "Diyala",
      governorates == "Anbar" ~ "Al Anbar",
      governorates == "Karbalah" ~ "Karbala",
      governorates == "Salahaddin" ~ "Saladin",
      governorates == "Qadissiyah" ~ "Al-Qadisiyah",
      governorates == "Muthana" ~ "Muthanna",
      governorates == "Thiqar" ~ "Dhi Qar",
      governorates == "Missan" ~ "Maysan",
      TRUE ~ governorates
    )
  )

write.csv(df, "Iraq/subset_mics.csv")



# From MakeCountryBoundaries.R --------------------------------------------

worldadm1<-topojson_read("https://www.geoboundaries.org/data/geoBoundariesCGAZ-3_0_0/ADM1/simplifyRatio_25/geoBoundariesCGAZ_ADM1.topojson")
IRQ1<-worldadm1%>%
  filter(shapeGroup=="IRQ")

IRQ1 <- IRQ1 %>%
  left_join(df, by = c("shapeName" = "governorates")) # %>%
  # pivot_longer(
  #   cols = !!(names(df)[2:length(names(df))]),
  #   names_to = "variable",
  #   values_to = "measure"
  # ) %>%
  # mutate(
  #   var_type = case_when(
  #     variable %in% names(woman_literacy) ~ "woman_literacy",
  #     variable %in% names(wealth_index_quantiles) ~ "wealth_index_quantiles",
  #     variable %in% names(childhood_mortality) ~ "childhood_mortality"
  #   )
  # )

ggplot(IRQ1) +
  geom_sf(aes(fill = as.numeric(total_percentage_woman_literate))) +
  ggtitle("Total Percentage of Literate Woman") +
  labs(fill = "% Womany Literate")

ggplot(IRQ1) +
  geom_sf(aes(fill = as.numeric(poorest))) +
  ggtitle("% of Goverorate in Poorest Wealth Quinitile") +
  labs(fill = "% in Poorest Quintile")

ggplot(IRQ1) +
  geom_sf(aes(fill = as.numeric(neonatal_mortality_rate))) +
  ggtitle("Neonatal mortality") +
  labs(fill = "Neonatal mortality rate")



# woman <- read_sav("Iraq/wm.sav")
# child <- read_sav("Iraq/ch.sav")
# births <- read_sav("Iraq/bh.sav")
# womanchild <- read_sav("Iraq/fs.sav")
# female_mut <- read_sav("Iraq/fg.sav")
# household <- read_sav("Iraq/hh.sav")
# members <- read_sav("Iraq/hl.sav")
# mort <- read_sav("Iraq/mm.sav")

