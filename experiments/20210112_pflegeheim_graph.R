library(tidyverse)
remotes::install_github("friep/vaccc19de")
library(vaccc19de)



cumulative_ts <- rki_download_cumulative_ts()
diffs_ts <- rki_download_diffs_ts()


#Exploring

summary(cumulative_ts$indikation_nach_alter)
table(cumulative_ts$indikation_nach_alter)
summary(cumulative_ts$pflegeheim_bewohner_in)
summary(cumulative_ts$ts_datenstand)

#loading the Pflegeheim-Data from Regionalstatistik (Table 22411-01-01-4-B)


availability<-read_delim("/Users/rzepka/Documents/Correlaid/contribution_for_vaccc19/22411-01-01-4-B.csv",
                       delim=";", skip = 4, locale = locale(encoding = "latin1"))


availability_clean<-availability %>%
  janitor::clean_names(dat = ., case = "snake")%>%
  # Select all but last 4 rows (which don't contain information)
  head(n = -4)%>% 
  select(x3,stationar_1)%>%
  rename("bundesland"="x3",
         "Stationäre Plätze"="stationar_1") # verfügbar in Pflegeheimen

availability_clean<-availability_clean[3:18,]        

  
  

cumulative_ts_aktuell<- cumulative_ts %>%
  # nur aktuellen Tag behalten
  filter(ts_datenstand==max(ts_datenstand)) %>%
  arrange(desc(pflegeheim_bewohner_in)) %>%
  #joining the 2017 Platzverfügbarkeit
  right_join(availability_clean) %>%
  mutate()

pflegeheim_share<-ggplot(cumulative_ts_aktuell, aes(x=reorder(bundesland_iso, pflegeheim_bewohner_in), y=pflegeheim_bewohner_in)) +
  geom_bar(stat="identity") +
  labs(y="Pflegeheimbewohner/in", x="Bundesland") +
  theme_bw()
pflegeheim_share