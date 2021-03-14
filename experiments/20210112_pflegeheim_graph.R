library(tidyverse)
library(vaccc19de)



cumulative_ts <- rki_download_cumulative_ts()
diffs_ts <- rki_download_diffs_ts()


#Exploring

summary(cumulative_ts$indikation_nach_alter)
table(cumulative_ts$indikation_nach_alter)
summary(cumulative_ts$pflegeheim_bewohner_in)
summary(cumulative_ts$ts_datenstand)

#loading the Pflegeheim-Data from Regionalstatistik (Table 22411-01-01-4-B)


availability<-read_delim("/Users/rzepka/Documents/Correlaid/vaccc19de_dashboard/experiments/22411-01-01-4-B.csv",
                       delim=";", skip = 4, locale = locale(encoding = "latin1"))


availability_clean<-availability %>%
  janitor::clean_names(dat = ., case = "snake")%>%
  # Select all but last 4 rows (which don't contain information)
  head(n = -4)%>%
  select(x3,stationar_1)%>%
  rename("bundesland"="x3",
         "platz"="stationar_1") # Stationäre_Plätze verfügbar in Pflegeheimen

# Drop rows without info
availability_clean<-availability_clean[3:18,]

# Rename Baden-Württemberg
availability_clean[8,1]<-"Baden-Württemberg"

# Nur aktuellsten Datenstand behalten
cumulative_ts_aktuell<- cumulative_ts %>%
  # nur aktuellen Tag behalten
  filter(ts_datenstand==max(ts_datenstand))%>%
  #joining the 2017 Platzverfügbarkeit
  right_join(availability_clean) %>%
  dplyr::mutate(share_pflegeheim=pflegeheim_bewohner_in/as.numeric(platz)*100)

pflegeheim_share<-ggplot(cumulative_ts_aktuell, aes(x=reorder(bundesland_iso, share_pflegeheim), y=share_pflegeheim)) +
  geom_bar(stat="identity") +
  labs(y="Anteil geimpfter, stationärer \nPflegeheimbewohner/innen (%)", x="Bundesland",
       caption="Daten zu den Pflegeheimen sind der Tabelle 22411-01-01-4-B der Regionalstatistik \nentnommen. Sie geben die Zahl der verfügbaren stationären Plätze in Pflegeheimen wieder.") +
  theme_bw()
pflegeheim_share

ggsave("/Users/rzepka/Documents/Correlaid/vaccc19de_dashboard/experiments/pflegeheim_share.pdf")
