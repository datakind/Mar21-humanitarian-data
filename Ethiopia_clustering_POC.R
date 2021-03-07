#The purpose of this script is to do a POC on how to answer these questions - only uses survey data not the merged data hence it is a POC
#Are there kebele/woreda that consistently answer positively? Negatively?
#Are there variables that cluster together?

#-------------------------------------------------------

setwd("C:\\Users\\Purvi\\Documents\\R\\Datadive March 2021\\socio-economic survey 2018-2019\\Useful files")
library(tidyverse)
library(plotly)
#install.packages("ggExtra")
library(ggExtra)
#install.packages("cowplot")
library(cowplot)

#note that data dictionary lives here: https://microdata.worldbank.org/index.php/catalog/3823/data-dictionary
#column names come from the data dictionary

sect8_hh_w4 <- as.data.frame(read.csv("sect8_hh_w4.csv"))

colnames(sect8_hh_w4) <- c("Unique Household Indentifier",
                           "Unique Enumeration Area Indentifier",
                           "Rural/Urban",
                           "Final adjusted wave 4 weight",
                           "Region code",
                           "Zone Code",
                           "Woreda Code",
                           "City Code",
                           "Sub city code",
                           "Kebele Code",
                           "EA code",
                           "Household ID",
                           "worry_HH_not_have_enough_food_last_7_days",
                           "2a. Number of days the household: Rely on less preferred foods",
                           "2b. Number of days the household: Limit the variety of foods eaten",
                           "2c. Number of days the household: Limit portion size at meal-times",
                           "2d. Number of days the household: Reduce number of meals eaten in a day",
                           "2e. Number of days the household: Restrict consumption by adults",
                           "2f. Number of days the household: Borrow food or rely on help",
                           "2g. Number of days the household: Have no food of any kind in your household",
                           "2h. Number of days the household: Go a whole day and night without eating",
                           "3a. Number of meals taken per day on average by 5 years and above",
                           "3a. Number of meals taken per day on average by children",
                           "4. Do all household members eat roughly the same diet?",
                           "5a. Do men usually eat a more diverse variety of foods?",
                           "5b. Do women usually eat a more diverse variety of foods?",
                           "5c. Do children usually eat a more diverse variety of foods?",
                           "6. Have you been faced with a situation when you didn't have enough food?",
                           "7. In which months did you experience this incident: 2011 May",
                           "7. In which months did you experience this incident: 2011 June",
                           "7. In which months did you experience this incident: 2011 July",
                           "7. In which months did you experience this incident: 2011 August",
                           "7. In which months did you experience this incident: 2011 September",
                           "7. In which months did you experience this incident: 2011 October",
                           "7. In which months did you experience this incident: 2011 November",
                           "7. In which months did you experience this incident: 2011 December",
                           "7. In which months did you experience this incident: 2012 January",
                           "7. In which months did you experience this incident: 2012 February",
                           "7. In which months did you experience this incident: 2012 March",
                           "7. In which months did you experience this incident: 2012 April",
                           "7. In which months did you experience this incident: 2012 May",
                           "7. In which months did you experience this incident: 2012 June",
                           "8. What was the cause of this situation? (CAUSE 1)",
                           "8. What was the cause of this situation? (CAUSE 2)",
                           "8. What was the cause of this situation? (CAUSE 3)",
                           "08_oth. Specify what was the cause of this situation.")

#create overall table
overall_table <- sect8_hh_w4 %>% group_by(
  `Region code`, 
  `Zone Code`,
  `Woreda Code`,
  `Kebele Code`,
) %>%   tally()

overall_table$region_zone_woreda_kebele <- paste(overall_table$`Region code`,
                                                 overall_table$`Zone Code`,
                                                 overall_table$`Woreda Code`,
                                                 overall_table$`Kebele Code`,sep = " - ")

#food insecurity------



sect8_hh_w4 <- sect8_hh_w4 %>% mutate_if(is.character,as.factor)

food_summary_1 <- sect8_hh_w4 %>% group_by(
                                         `Region code`, 
                                         `Zone Code`,
                                         `Woreda Code`,
                                         `Kebele Code`,
                                         worry_HH_not_have_enough_food_last_7_days
                                           
) %>%   tally()

food_summary_1$region_zone_woreda_kebele <- paste(food_summary_1$`Region code`,
                                                  food_summary_1$`Zone Code`,
                                                  food_summary_1$`Woreda Code`,
                                                  food_summary_1$`Kebele Code`,sep = " - ")

food_summary_2 <- spread(food_summary_1, worry_HH_not_have_enough_food_last_7_days, n, fill = 0)

food_summary_3 <- food_summary_2 %>% 
  mutate(total = sum(c_across("V1":"2. NO"))) %>% 
  ungroup() %>% 
  mutate(across("V1":"2. NO", ~ . / total))


food_summary_4 <- food_summary_3 %>% 
  mutate(percentile_worry_HH_not_have_enough_food_last_7_days = ntile(`2. NO`, 100),
         pc_responses_worry_HH_not_have_enough_food_last_7_days = `1. YES`)


#join back onto overall table

overall_table <- left_join(overall_table, food_summary_4[,c(5,10,11)])

#---lack of assistance - remember low percentile is bad-----------

sect14_hh_w4 <- as.data.frame(read.csv("sect14_hh_w4.csv"))


colnames(sect14_hh_w4) <- c("Unique Household Indentifier",
                            "Unique Assistance Identifier",
                            "Unique Enumeration Area Indentifier",
                            "Rural/Urban",
                            "Final adjusted wave 4 weight",
                            "Region code",
                            "Zone Code",
                            "Woreda Code",
                            "City Code",
                            "Sub city code",
                            "Kebele Code",
                            "EA code",
                            "Household ID",
                            "1. Did HH receive any [ASSISTANCE] in the past 12 months?",
                            "1_other: specify other supports",
                            "2a. What is the name of the organization who provided [ASSISTANCE]",
                            "2b. What is the name of the organization who provided [ASSISTANCE]: #1",
                            "2b. What is the name of the organization who provided [ASSISTANCE]: #2",
                            "2b. What is the name of the organization who provided [ASSISTANCE]: #3",
                            "2_other: specify other type of organization",
                            "3. How much cash did HH receive from this organization?",
                            "4. How was the payment mainly made to you: Payment Method 1",
                            "4. How was the payment mainly made to you: Payment Method 2",
                            "other specify",
                            "5. What was the value of food HH received from this organization?",
                            "6. What was the value of in-kind assistance HH received from [ASSISTANCE]?",
                            "7. Was this aid given to entire HH or specific person?",
                            "8. Which members of the HH participated in this program? (HH Roster ID #1)",
                            "8. Which members of the HH participated in this program? (HH Roster ID #2)",
                            "8. Which members of the HH participated in this program? (HH Roster ID #3)")

food_summary_1 <- sect14_hh_w4[,c(1:14)] %>% pivot_wider(names_from = `Unique Assistance Identifier`, 
                                                         values_from = `1. Did HH receive any [ASSISTANCE] in the past 12 months?`)

food_summary_1$any_assistance <- "2. NO"
food_summary_1$any_assistance[food_summary_1$`1. Direct support through PSNP ` == "1. YES"] <- "1. YES"
food_summary_1$any_assistance[food_summary_1$`2. Free food ` == "1. YES"] <- "1. YES"
food_summary_1$any_assistance[food_summary_1$`3. Other non food assistance` == "1. YES"] <- "1. YES"

food_summary_1$any_assistance <- as.factor(food_summary_1$any_assistance)

food_summary_2 <- food_summary_1 %>% group_by(
  `Region code`, 
  `Zone Code`,
  `Woreda Code`,
  `Kebele Code`,
  any_assistance
  
) %>%   tally()

food_summary_2$region_zone_woreda_kebele <- paste(food_summary_2$`Region code`,
                                                  food_summary_2$`Zone Code`,
                                                  food_summary_2$`Woreda Code`,
                                                  food_summary_2$`Kebele Code`,sep = " - ")

food_summary_3 <- spread(food_summary_2, any_assistance, n, fill = 0)

food_summary_4 <- food_summary_3 %>% 
  mutate(total = sum(c_across("1. YES":"2. NO"))) %>% 
  ungroup() %>% 
  mutate(across("1. YES":"2. NO", ~ . / total))


food_summary_4 <- food_summary_4 %>% 
  mutate(percentile_any_assistance = ntile(`1. YES`, 100),
         pc_responses_no_assistance = `2. NO`)

#join back onto overall table

overall_table <- left_join(overall_table, food_summary_4[,c(5,9,10)])

#----
sect11_hh_w4 <- as.data.frame(read.csv("sect11_hh_w4.csv"))


colnames(sect11_hh_w4) <- c("Unique Household Indentifier",
                            "Asset Item Code",
                            "Unique Enumeration Area Indentifier",
                            "Rural/Urban",
                            "Final adjusted wave 4 weight",
                            "Region code",
                            "Zone Code",
                            "Woreda Code",
                            "City Code",
                            "Sub city code",
                            "Kebele Code",
                            "EA code",
                            "Household ID",
                            "0. Does your household own any [ITEM]?",
                            "1. How many [ITEM] does your household own?",
                            "2. Among the household members who owns [ITEM]? HH Member 1",
                            "2. Among the household members who owns [ITEM]? HH Member 2",
                            "2. Among the household members who owns [ITEM]? HH Member 3",
                            "2. Among the household members who owns [ITEM]? HH Member 4",
                            "2. Among the household members who owns [ITEM]? HH Member 5",
                            "2. Among the household members who owns [ITEM]? HH Member 6",
                            "2. Among the household members who owns [ITEM]? HH Member 7",
                            "2. Among the household members who owns [ITEM]? HH Member 8",
                            "2. Among the household members who owns [ITEM]? HH Member 9",
                            "2. Among the household members who owns [ITEM]? HH Member 10",
                            "2. Among the household members who owns [ITEM]? HH Member 11",
                            "2. Among the household members who owns [ITEM]? HH Member 12")

food_summary_1 <- sect11_hh_w4[,c(1:14)] %>% pivot_wider(names_from = `Asset Item Code`, 
                                                         values_from = `0. Does your household own any [ITEM]?`)

food_summary_1$any_stove <- "2. NO"
food_summary_1$any_stove[food_summary_1$`1. Kerosene stove` == "1. YES"] <- "1. YES"
food_summary_1$any_stove[food_summary_1$`2. Cylinder gasstove` == "1. YES"] <- "1. YES"
food_summary_1$any_stove[food_summary_1$`3. Electric stove` == "1. YES"] <- "1. YES"
food_summary_1$any_stove[food_summary_1$`20. Energy saving stove (lakech, mirt etc)` == "1. YES"] <- "1. YES"
food_summary_1$any_stove[food_summary_1$`27. Biogas stove (pit)` == "1. YES"] <- "1. YES"


food_summary_1$any_stove <- as.factor(food_summary_1$any_stove)

food_summary_2 <- food_summary_1 %>% group_by(
  `Region code`, 
  `Zone Code`,
  `Woreda Code`,
  `Kebele Code`,
  any_stove
  
) %>%   tally()

food_summary_2$region_zone_woreda_kebele <- paste(food_summary_2$`Region code`,
                                                  food_summary_2$`Zone Code`,
                                                  food_summary_2$`Woreda Code`,
                                                  food_summary_2$`Kebele Code`,sep = " - ")

food_summary_3 <- spread(food_summary_2, any_stove, n, fill = 0)

food_summary_4 <- food_summary_3 %>% 
  mutate(total = sum(c_across("1. YES":"2. NO"))) %>% 
  ungroup() %>% 
  mutate(across("1. YES":"2. NO", ~ . / total))


food_summary_4 <- food_summary_4 %>% 
  mutate(percentile_any_stove = ntile(`1. YES`, 100),
         pc_responses_no_stove = `2. NO`)

#join back onto overall table

overall_table <- left_join(overall_table, food_summary_4[,c(5,9,10)])

#---------------------------------------------------

# K-Means Cluster Analysis-------------------------

#--------------------------------------------------
fit <- kmeans(overall_table[,c(8,10,12)], 7)


# get cluster means
aggregate(overall_table[,c(8,10,12)],by=list(fit$cluster),FUN=mean)
# append cluster assignment
overall_table$fit.cluster <- fit$cluster


summary_table <- overall_table %>% 
  group_by(`Region code`, fit.cluster) %>% 
  summarise('n' = n(),
            'mean_worry_food' = mean(pc_responses_worry_HH_not_have_enough_food_last_7_days),
            'mean_no_assistance' = mean(pc_responses_no_assistance),
            'mean_no_stove' = mean(pc_responses_no_stove))


p1 <- ggplot(overall_table, aes(x = fit.cluster, y = pc_responses_worry_HH_not_have_enough_food_last_7_days)) +
  geom_boxplot(aes(group = fit.cluster))+
  ggtitle("pc_responses_worry_HH_not_have_enough_food_last_7_days")

p2 <- ggplot(overall_table, aes(x = fit.cluster, y = pc_responses_no_assistance)) +
  geom_boxplot(aes(group = fit.cluster))+
  ggtitle("pc_responses_no_assistance")

p3 <- ggplot(overall_table, aes(x = fit.cluster, y = pc_responses_no_stove)) +
  geom_boxplot(aes(group = fit.cluster))+
  ggtitle("pc_responses_no_stove")

p4 <- ggplot(summary_table, aes(x = fit.cluster , y = n, fill = `Region code`))+
  geom_bar(stat = "identity", colour = "black") +
  #facet_wrap(~fit.cluster)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  ggtitle("Region by cluster")+
  theme(legend.position = "top")

plot_grid(p1, p2, p3, p4)

#---------------------------------------------------------------------

