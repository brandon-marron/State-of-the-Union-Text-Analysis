# ===============================================
# Title: State of The Union Analysis
# Description: Our goal is to conduct word analysis on the State of the Union
#              of the years. We decided on Word Trend and Bigram Analysis.
# Author: Brandon Marron
# ===============================================


# ===============================================
# Required packages
# ===============================================

library(shiny)
library(tidyverse)
library(tidytext)
library(DT)
library(plotly)

# ===============================================
# Import data
# ===============================================
sotu = read_csv(
  "sotu.csv",
  col_types = cols(
    year  = col_integer(),
    name  = col_character(),
    party = col_character(),
    text  = col_character()
  )
) %>%
  mutate(
    party = if_else(party == "none", "None", party),
    text  = str_replace_all(text, "(?<=\\p{L})[\u2019']s\\b", "")
  ) %>%
  select(year, party, text)

year_min = min(sotu$year)
year_max = max(sotu$year)


# ===============================================
# Pre-computation (done once at startup, not on every input change)
# ===============================================

# ---- Words ----
tokens_all = sotu %>% unnest_tokens(output = word, input = text)

# total words per year (two speeches in 1953 and 1961 are combined by year)
year_totals = tokens_all %>% count(year, name = "total_words")

# frequency of every word in every year
word_year = tokens_all %>% count(year, word, name = "n")

rm(tokens_all)

# Top 40 meaningful words for the dropdown (no stop words, no numbers like "000")
word_list = word_year %>%
  filter(!str_detect(word, "^[0-9]")) %>%
  anti_join(stop_words, by = "word") %>%
  group_by(word) %>%
  summarise(total = sum(n), .groups = "drop") %>%
  arrange(desc(total)) %>%
  slice_head(n = 40) %>%
  pull(word)

# ---- Bigrams (counted by year and party) ----
bigram_counts = sotu %>%
  unnest_tokens(output = bigram, input = text, token = "ngrams", n = 2) %>%
  filter(!is.na(bigram)) %>%
  separate(bigram, into = c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% stop_words$word,
         !word2 %in% stop_words$word,
         !str_detect(word1, "^[0-9]"),
         !str_detect(word2, "^[0-9]")) %>%
  count(year, party, word1, word2, name = "n")


# ===============================================
# Define UI
# ===============================================
ui <- fluidPage(
  
  titlePanel("The State of the Union Text Analysis"),
  
  fluidRow(
    # Shared by both analyses: always visible
    column(4,
           sliderInput(inputId = "year",
                       label = "Time Period:",
                       min = year_min,
                       max = year_max,
                       value = c(1991, year_max),
                       sep = "")
    ), # closes column 1
    
    column(4,
           selectInput(inputId = "selected_word",
                       label = "Select a word",
                       choices = sort(word_list),
                       selected = word_list[1])
    ), # closes column 2
    
    # Widgets
    column(4,
           # Analysis 1 only
           conditionalPanel(
             condition = "input.tabselected == 'analysis1'",
             radioButtons(inputId = "metric",
                          label = "Trend measure:",
                          choices = c("Raw count" = "count",
                                      "Per 1,000 words" = "rate"),
                          selected = "count")
           ),
           # Analysis 2 only
           conditionalPanel(
             condition = "input.tabselected == 'analysis2'",
             sliderInput(inputId = "number_words",
                         label = "Number of Words displayed: ",
                         min = 1,
                         max = 50,
                         value = 10),
             checkboxInput(inputId = "facet_party",
                           label = "Facet by Party?",
                           value = FALSE)
           )
    ) # closes column 3
    
  ), # closes fluidRow
  
  hr(),
  
  tabsetPanel(type = "tabs",
              id = "tabselected",
              tabPanel("Analysis 1",
                       value = "analysis1",
                       h3("Word Trend Analysis"),
                       plotlyOutput("plot1"),
                       hr(),
                       DT::DTOutput("table1")),
              tabPanel("Analysis 2",
                       value = "analysis2",
                       h3("Bigram Analysis"),
                       plotOutput("plot2"),
                       hr(),
                       DT::DTOutput("table2"))
  ) # closes tabsetPanel
  
) # closes ui



# ===============================================
# Server logic
# ===============================================
server <- function(input, output) {
  
  # ---- Analysis 1: one row per year in the range, zeros included ----
  word_trend = reactive({
    yrs = year_totals %>%
      filter(year >= input$year[1], year <= input$year[2])
    
    hits = word_year %>%
      filter(word == input$selected_word) %>%
      select(year, n)
    
    yrs %>%
      left_join(hits, by = "year") %>%
      mutate(Frequency = replace_na(n, 0L),
             Per_1000  = Frequency / total_words * 1000) %>%
      transmute(Year = year, Frequency, Per_1000, total_words) %>%
      arrange(Year)
  })
  
  # ---- Analysis 2: words that follow the selected word ----
  next_words = reactive({
    d = bigram_counts %>%
      filter(year >= input$year[1],
             year <= input$year[2],
             word1 == input$selected_word)
    
    validate(need(nrow(d) > 0,
                  paste0("No bigrams starting with \"", input$selected_word,
                         "\" in this time period.")))
    
    if (input$facet_party) {
      d %>%
        group_by(party, word2) %>%
        summarise(n = sum(n), .groups = "drop") %>%
        group_by(party) %>%
        slice_max(order_by = n, n = input$number_words, with_ties = FALSE) %>%
        ungroup()
    } else {
      d %>%
        group_by(word2) %>%
        summarise(n = sum(n), .groups = "drop") %>%
        slice_max(order_by = n, n = input$number_words, with_ties = FALSE)
    }
  })
  
  
  # ===============================================
  # Outputs for the first TAB
  # ===============================================
  output$plot1 = renderPlotly({
    d = word_trend()
    validate(need(nrow(d) > 0, "No speeches in this time period."))
    
    use_rate = input$metric == "rate"
    d = d %>% mutate(Value = if (use_rate) Per_1000 else Frequency)
    
    chart = ggplot(d, aes(x = Year, y = Value)) +
      geom_col(fill = "skyblue") +
      labs(
        title = paste0("Trend of the word: ", input$selected_word),
        x = "Year",
        y = if (use_rate) "Occurrences per 1,000 words" else "Frequency"
      ) +
      theme_minimal()
    
    ggplotly(chart)
  })
  
  output$table1 <- DT::renderDT({
    word_trend() %>%
      transmute(Year,
                Frequency,
                `Per 1,000 Words` = round(Per_1000, 2),
                `Total Words` = total_words) %>%
      DT::datatable(rownames = FALSE)
  })
  
  
  # ===============================================
  # Outputs for the second TAB
  # ===============================================
  output$plot2 <- renderPlot({
    d = next_words()
    
    if (input$facet_party) {
      ggplot(d, aes(x = reorder_within(word2, n, party), y = n)) +
        geom_col(fill = "darkblue") +
        scale_x_reordered() +
        facet_wrap(~ party, scales = "free_y") +
        coord_flip() +
        labs(title = paste0("Top words following \"", input$selected_word, "\""),
             x = "Next Word", y = "Frequency") +
        theme_minimal()
    } else {
      ggplot(d, aes(x = reorder(word2, n), y = n)) +
        geom_col(fill = "darkblue") +
        coord_flip() +
        labs(title = paste0("Top words following \"", input$selected_word, "\""),
             x = "Next Word", y = "Frequency") +
        theme_minimal()
    }
  })
  
  output$table2 <- DT::renderDT({
    d = next_words()
    
    if (input$facet_party) {
      d = d %>%
        arrange(party, desc(n)) %>%
        rename(Party = party, `Next Word` = word2, Frequency = n)
    } else {
      d = d %>%
        arrange(desc(n)) %>%
        rename(`Next Word` = word2, Frequency = n)
    }
    
    DT::datatable(d, rownames = FALSE)
  })
  
}

# ===============================================
# Run the application
# ===============================================
shinyApp(ui = ui, server = server)