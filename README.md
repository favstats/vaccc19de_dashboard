
<!-- README.md is generated from README.Rmd. Please edit that file -->

# COVID-19 Impfungsdaten des RKI

Ziel dieses Repository ist es den Fortschritt von COVID-19 Impfungen in
Deutschland zu
[dokumentieren](https://github.com/favstats/vaccc19de_dashboard/data/)
und [visualisieren](https://favstats.github.io/vaccc19de_dashboard/).

Die Impfungsdaten werden täglich vom Robert-Koch-Institut (RKI) [auf
dieser
Seite](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Impfquoten-Tab.html)
bereitgestellt. Die hier dargestellten Daten werden von diesem
öffentlichen
<a href="https://github.com/ard-data/2020-rki-impf-archive" target="_blank">ARD Data GitHub repository</a>
bezogen.

Bevölkerungsdaten für die Bundesländer stammen vom [Statistischen
Bundesamt](https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Bevoelkerungsstand/Tabellen/bevoelkerung-nichtdeutsch-laender.html).

📝 Hinweis: Das RKI hat am 18.01.2021 angefangen, in seinen Daten nach
erster und zweiter Impfung sowie nach Impfstoff (Moderna und Biontech)
zu unterscheiden. Dies resultierte in einigen Veränderungen in der
Struktur der Excel-Datei (z.B. mehr Spalten, mehrzeilige Spaltennamen),
die zwar für das menschliche Auge gut und schnell zu verarbeiten sind,
aber für den Code, den wir geschrieben haben, um das Excel einzulesen
und in ein einheitlicheres Format zu bringen, Probleme darstellen. Seit
dem 24.01.2021 beziehen wir nun die Impfdaten von diesem öffentlichen
[GitHub repository von ARD
Data](https://github.com/ard-data/2020-rki-impf-archive) 📝

![](img/infobox1_de.png) ![](img/infobox2_de.png)

<center>

*Letzter Datenstand: 05.02.2021 11:00:00*

<!-- **Aktuelle Anmerkungen:** -->
<!-- ```{r, results = "asis", echo = F} -->
<!-- notes_dat <- latest_dat %>%  -->
<!--   drop_na(notes) -->
<!-- if(nrow(notes_dat)!=0){ -->
<!--   notes_dat %>%  -->
<!--     mutate(notes = ifelse(stringi::stri_startswith_fixed(notes, "("), -->
<!--                           str_remove(notes, "\\("), -->
<!--                           notes), -->
<!--            notes = ifelse(stringi::stri_endswith_fixed(notes, ")") , -->
<!--                           str_sub(notes, 1, str_length(notes)-1), -->
<!--                           notes), -->
<!--            notes = ifelse(!stringi::stri_endswith_fixed(notes, "\\.") , -->
<!--                           paste0(notes, "."), -->
<!--                           notes)) %>%  -->
<!--     mutate(note_display = glue::glue("{bundesland}: *{notes}*")) %>%  -->
<!--     pull(note_display) %>%  -->
<!--     paste0(collapse = "\n\n")  %>%  -->
<!--     cat() -->
<!-- } else { -->
<!--   cat("*Keine Anmerkungen.*") -->
<!-- } -->
<!-- ``` -->

Twitter Bot für tägliche Updates:
<a href="https://twitter.com/vaccc19de" target="_blank">vaccc19de</a>

</center>

# Contribute

Contributions are very welcome. Depending on where you want to add
features, please open an issue here or on
<a href="https://github.com/friep/vaccc19de" target="_blank">{vaccc19de}</a>:

-   features relating to GitHub Action and daily updates of the data
    –&gt; this repository
-   features relating to the dashboard –&gt; this repository
-   features relating to data wrangling, data cleaning of the original
    excel file –&gt;
    <a href="https://github.com/friep/vaccc19de" target="_blank">{vaccc19de}</a>

Of course, features might require changes in both repositories. Please
still open issues in both repositories and then link them to each other.
