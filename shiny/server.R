# server.R
library(shiny)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(treemapify)

# --- Data Loading -------------------------------------------------------------
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

# --- Helper Function ---------------------------------------------------------
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

# --- Server logic ------------------------------------------------------------
server <- function(input, output, session) {
  # Accueil dynamiques sur top 50 populaires
  output$nbJeux <- renderValueBox({
    valueBox(
      nrow(steam), "Jeux totaux", icon = icon("gamepad"), color = "green"
    )
  })
  output$avgPlaytime <- renderInfoBox({
    top50 <- steam %>% arrange(desc(owners_mid)) %>% slice_head(n = 50)
    infoBox(
      "Moyenne top 50 (h)",
      round(mean(top50$average_playtime / 60, na.rm = TRUE), 1),
      icon = icon("clock"), color = "blue"
    )
  })
  
  # 1. Genre vs Durée (top 20 genres)
  output$genrePlot <- renderPlot({
    df <- hltb %>%
      mutate(Primary_Genre = sapply(strsplit(Genres, ","), `[`, 1)) %>%
      pivot_longer(
        cols = c(main_story, extras, completionist),
        names_to = "Mode",
        values_to = "Temps"
      ) %>%
      filter(Mode == input$mode, !is.na(Temps)) %>%
      group_by(Primary_Genre) %>%
      summarise(Temps_moyen = mean(Temps), .groups = "drop") %>%
      arrange(desc(Temps_moyen)) %>%
      slice_head(n = 20)
    
    ggplot(df, aes(x = reorder(Primary_Genre, Temps_moyen), y = Temps_moyen)) +
      geom_col(fill = "#0074ff") +
      coord_flip() +
      labs(x = "Genre", y = "Temps moyen (h)") +
      theme_minimal()
  })
  
  # 2. Avis vs Temps
  output$avisPlot <- renderPlot({
    df <- steam %>%
      filter(average_playtime > 0) %>%
      mutate(
        avg_h = average_playtime / 60,
        pct   = 100 * positive_ratings / (positive_ratings + negative_ratings)
      ) %>%
      mutate(bucket = cut(pct, breaks = input$buckets, include.lowest = TRUE)) %>%
      group_by(bucket) %>%
      summarise(avg = mean(avg_h, na.rm = TRUE), .groups = "drop")
    
    ggplot(df, aes(x = bucket, y = avg)) +
      geom_col(fill = "steelblue") +
      labs(x = "% Avis positifs", y = "Temps moyen (h)") +
      theme_minimal()
  })
  
  # 3. Top N jeux
  output$topGamesPlot <- renderPlot({
    df_top <- steam %>%
      filter(!is.na(genres), average_playtime > 0) %>%
      mutate(
        avg_h      = average_playtime / 60,
        genre_main = sapply(strsplit(genres, ";"), `[`, 1)
      ) %>%
      arrange(desc(avg_h)) %>%
      slice_head(n = input$top_n)
    
    ggplot(df_top, aes(x = reorder(name, avg_h), y = avg_h, fill = genre_main)) +
      geom_col(show.legend = FALSE) +
      coord_flip() +
      labs(x = "Jeu", y = "Temps moyen (h)") +
      theme_minimal()
  })
  
  # 4. Prix vs Avis
  output$prixPlot <- renderPlot({
    df <- steam %>%
      filter(
        price >= input$price_range[1],
        price <= input$price_range[2],
        positive_ratings + negative_ratings > 5
      )
    
    ggplot(df, aes(
      x = price,
      y = 100 * positive_ratings / (positive_ratings + negative_ratings),
      color = owners_mid
    )) +
      geom_point(alpha = 0.7) +
      scale_colour_gradient(low = "#56B1F7", high = "#132B43") +
      labs(x = "Prix (USD)", y = "% Avis positifs", color = "Possesseurs") +
      theme_minimal()
  })
  
  # 5. Treemap Top 20 payants
  output$treemapPlot <- renderPlot({
    df <- steam %>%
      filter(price > 0) %>%
      arrange(desc(owners_mid)) %>%
      slice_head(n = 20) %>%
      mutate(avg_h = average_playtime / 60)
    
    ggplot(df, aes(area = owners_mid, fill = avg_h, label = name)) +
      geom_treemap() +
      geom_treemap_text(color = "white", reflow = TRUE) +
      scale_fill_gradient(low = "lightblue", high = "darkblue") +
      theme_minimal()
  })
}

