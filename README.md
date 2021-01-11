
<!-- README.md is generated from README.Rmd. Please edit that file -->

# COVID-19 Impfungsdaten des RKI

Ziel dieses Repository ist es den Fortschritt von COVID-19 Impfungen in
Deutschland zu
[dokumentieren](https://github.com/friep/vaccc19de_rki_data) und
[visualisieren](https://favstats.github.io/vaccc19de_dashboard/).

Die Impfungsdaten werden täglich vom Robert-Koch-Institut (RKI) [auf
dieser
Seite](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Impfquoten-Tab.html)
bereitgestellt. Die hier dargestellten Daten werden nach jedem Update
heruntergeladen und mit Hilfe des [{vaccc19de} R
:package:](https://github.com/friep/vaccc19de) aufbereitet.

Bevölkerungsdaten für die Bundesländer stammen vom [Statistischen
Bundesamt](https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Bevoelkerungsstand/Tabellen/bevoelkerung-nichtdeutsch-laender.html).

![](img/infobox1_de.png) ![](img/infobox2_de.png)

<center>

*Letzter Datenstand: 11.01.2021 11:00:00*

**Aktuelle Anmerkungen:**

Schleswig-Holstein: *Meldung steht noch aus.*

Thüringen: *Meldung aus KH steht noch aus.*

Twitter Bot für tägliche Updates:
<a href="https://twitter.com/vaccc19de" target="_blank">vaccc19de</a>

</center>

# Data

**Disclaimer**: The following is in English because it was migrated from
the
<a href="https://github.com/friep/vaccc19de_rki_data" target="_blank">old data repository</a>
and we could not be bothered to translate it so far.

Besides providing the dashboard, we collect and store the data behind
the dashboard in this repository. Data is published by the RKI on
<a href="https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Impfquotenmonitoring.html" target="_blank">this page</a>.

The data is collected via a GitHub Action which uses the accompanying
<a href="https://github.com/friep/vaccc19de" target="_blank">{vaccc19de} R :package:</a>.
You can find the raw data (xlsx files and sheets as csvs) in `data/raw`
and the time series at `data/cumulative_time_series.csv`.

## Data License

We are currently figuring out how to license the data / whether there
are any restrictions from RKI’s side - we don’t suspect that there are
any but we haven’t found any information on that yet.

:warning: We take no liability for the correctness of the data!
:warning:

## Datasets

### `data/cumulative_time_series.csv`

### Disclaimers :warning:

-   All counts are cumulative (except `differenz_zum_vortag`)
-   timestamps in the csv are in UTC, not in Berlin time.
-   as stated in the raw xlsx file, one vaccinated person can have
    multiple indications: “Anmerkung zu den Indikationen: Es können
    mehrere Indikationen je geimpfter Person vorliegen.”
-   always check the raw xlsx (see folder `data/raw`)

Read in directly from GitHub using R:

``` r
cumulative_ts <- readr::read_csv("https://raw.githubusercontent.com/favstats/vaccc19de_dashboard/main/data/cumulative_time_series.csv")
```

| col                               | type      | description                                                                                                                      |
|:----------------------------------|:----------|:---------------------------------------------------------------------------------------------------------------------------------|
| ts\_datenstand                    | datetime  | datetime until which data is included (‘Datenstand’) as specified in the Excel file. Given in UTC                                |
| ts\_download                      | datetime  | datetime when data was downloaded from RKI website. Given in UTC                                                                 |
| bundesland                        | character | full name of Bundesland                                                                                                          |
| bundesland\_iso                   | character | ISO 3166-2 of Bundesland                                                                                                         |
| impfungen\_kumulativ              | double    | Cumulative total number of vaccinations in the Bundesland                                                                        |
| differenz\_zum\_vortag            | double    | Difference to previous day (\~roughly corresponds to people vaccinated since then although delays in reporting could be the case |
| indikation\_nach\_alter           | double    | Total number of people vaccinated because of their age so far (cumulative)                                                       |
| berufliche\_indikation            | double    | Total number of people vaccinated because of their profession so far (cumulative)                                                |
| medizinische\_indikation          | double    | Total number of people vaccinated because of medical reasons so far (cumulative)                                                 |
| pflegeheim\_bewohner\_in          | double    | Total number of people in nursing homes so far (cumulative)                                                                      |
| notes                             | character | Notes as indicated by \* at the bottom of the Excel sheet and stored in unnamed columns.                                         |
| impfungen\_pro\_1\_000\_einwohner | character | vaccinations per 1000 inhabitants                                                                                                |

### `data/diffs_time_series.csv`

This dataset contains the “decumulated” time series which is derived
from the `cumulative_time_series.csv`. Each row represents the
*increase* since the last update of the data (usually the day before).

### Disclaimers :warning:

-   Note that a number for a day does not necessarily correspond to the
    number of vaccinations for that day. This is due to reporting delays
    and other irregularities in the process (see “notes” column).
-   Again, one person can have multiple indications which is why numbers
    of the indications might not add up to the overall increase in
    vaccinated people.
-   No liability is taken for the correctness of the calculations. If in
    doubt, check the raw excel files.

| col                           | type      | description                                                                                                                      |
|:------------------------------|:----------|:---------------------------------------------------------------------------------------------------------------------------------|
| ts\_datenstand                | datetime  | datetime until which data is included (‘Datenstand’) as specified in the Excel file. Given in UTC                                |
| ts\_download                  | datetime  | datetime when data was downloaded from RKI website. Given in UTC                                                                 |
| bundesland                    | character | full name of Bundesland                                                                                                          |
| bundesland\_iso               | character | ISO 3166-2 of Bundesland                                                                                                         |
| impfungen\_neu                | double    | Cumulative total number of vaccinations in the Bundesland                                                                        |
| indikation\_nach\_alter\_neu  | double    | Difference to previous day (\~roughly corresponds to people vaccinated since then although delays in reporting could be the case |
| medizinische\_indikation\_neu | double    | Number of people reported vaccinated because of their age since the last data update                                             |
| berufliche\_indikation\_neu   | double    | Number of people reported vaccinated because of their profession since the last data update                                      |
| pflegeheim\_bewohner\_in\_neu | double    | Number of people reported vaccinated because of medical reasons since the last data update                                       |
| notes                         | double    | Number of people reported vaccinated in nursing homes since the last data update                                                 |
| NA                            | character | Notes as indicated by \* at the bottom of the Excel sheet and stored in unnamed columns.                                         |

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
