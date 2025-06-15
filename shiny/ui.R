# ui.R
library(shiny)
library(shinydashboard)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(treemapify)

# --- Data (pour UI dynamique) ------------------------------------------------
# On recharge ici steam et hltb pour que ui puisse connaître max(steam$price), etc.
steam <- read.csv(
  "C:/Users/virgi/Desktop/UTT/IF36/steam.csv/steam.csv",
  stringsAsFactors = FALSE
) %>%
  filter(owners != "") %>%
  separate(owners, into = c("min_o", "max_o"), sep = "-", convert = TRUE) %>%
  mutate(owners_mid = (min_o + max_o) / 2)

hltb <- read.csv(
  "C:/Users/virgi/Desktop/UTT/IF36/hltb_clean.csv",
  stringsAsFactors = FALSE
)

# fonction de conversion pour UI (même qu'en server)
convert_to_hours <- function(time_str) {
  time_str[time_str == "" | time_str == "N/A" | is.na(time_str)] <- NA
  h <- as.numeric(str_extract(time_str, "\\d+(?=h)"))
  m <- as.numeric(str_extract(time_str, "\\d+(?=m)"))
  ifelse(is.na(time_str),
         NA,
         (ifelse(is.na(h), 0, h) + ifelse(is.na(m), 0, m) / 60))
}
hltb <- hltb %>%
  mutate(
    main_story    = convert_to_hours(main_story),
    extras        = convert_to_hours(extras),
    completionist = convert_to_hours(completionist)
  )

# --- UI -----------------------------------------------------------------------
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(
    title = tags$div(
      "Dashboard Interactif - Temps de Jeu",
      style = "white-space: nowrap; font-size:14px;"
    ),
    titleWidth = "350px"
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Accueil",            tabName = "home",    icon = icon("home")),
      menuItem("Genre vs Durée",     tabName = "genre",   icon = icon("gamepad")),
      menuItem("Avis vs Temps",      tabName = "avis",    icon = icon("comments")),
      menuItem("Playtime vs Genre",  tabName = "play",    icon = icon("chart-bar")),
      menuItem("Prix & Possesseurs", tabName = "prix",    icon = icon("dollar-sign")),
      menuItem("Top Payants",        tabName = "treemap", icon = icon("table"))
    )
  ),
  dashboardBody(
    tabItems(
      # --- Accueil -------------------------------------------------------------
      tabItem(tabName = "home",
              fluidRow(
                valueBoxOutput("nbJeux"),
                infoBoxOutput("avgPlaytime")
              )
      ),
      # --- Genre vs Durée ------------------------------------------------------
      tabItem(tabName = "genre",
              fluidRow(
                box(width = 4, title = "Mode de jeu", status = "primary", solidHeader = TRUE,
                    selectInput("mode", "Mode :",
                                choices = c("main_story", "extras", "completionist"),
                                selected = "completionist")
                ),
                box(width = 8, title = "Temps moyen par genre", status = "primary", solidHeader = TRUE,
                    plotOutput("genrePlot", height = "400px")
                )
              )
      ),
      # --- Avis vs Temps -------------------------------------------------------
      tabItem(tabName = "avis",
              fluidRow(
                box(width = 4, title = "Buckets avis", status = "warning", solidHeader = TRUE,
                    sliderInput("buckets", "Nb tranches :", min = 2, max = 10, value = 4)
                ),
                box(width = 8, title = "Temps vs avis positifs", status = "warning", solidHeader = TRUE,
                    plotOutput("avisPlot", height = "400px")
                )
              )
      ),
      # --- Playtime vs Genre ---------------------------------------------------
      tabItem(tabName = "play",
              fluidRow(
                box(width = 4, title = "Top N jeux", status = "info", solidHeader = TRUE,
                    sliderInput("top_n", "Nombre de jeux :", min = 5, max = 30, value = 15)
                ),
                box(width = 8, title = "Top jeux par temps moyen", status = "info", solidHeader = TRUE,
                    plotOutput("topGamesPlot", height = "400px")
                )
              )
      ),
      # --- Prix & Possesseurs --------------------------------------------------
      tabItem(tabName = "prix",
              fluidRow(
                box(width = 4, title = "Filtrer prix", status = "warning", solidHeader = TRUE,
                    sliderInput("price_range", "Prix (USD) :",
                                min = 0,
                                max = max(steam$price, na.rm = TRUE),
                                value = c(0, 100),
                                step = 1)
                ),
                box(width = 8, title = "Scatter prix vs avis", status = "warning", solidHeader = TRUE,
                    plotOutput("prixPlot", height = "400px")
                )
              )
      ),
      # --- Treemap Top Payants -------------------------------------------------
      tabItem(tabName = "treemap",
              fluidRow(
                box(width = 12, title = "Treemap des 20 jeux payants", status = "success", solidHeader = TRUE,
                    plotOutput("treemapPlot", height = "400px")
                )
              )
      )
    )
  )
)
