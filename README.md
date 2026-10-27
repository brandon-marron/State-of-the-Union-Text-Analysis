# State of the Union Text Analysis
Created an interactive R Shiny application that analyzes language trends across the United States' State of the Union from 1790 to 2021. 
The application uses text mining and language processing techniques to explore word frequency over time and which words commonly co-occur. 

# Project Overview
The goal of this project was to transform more than two centuries of speech text into an interactive application that lets users explore questions like:  

- How has the use of specific words changed over time?
- When were certain topics discussed most frequently?
- Does a word's apparent popularity change after accounting for speech length?
- What words most commonly follow a selected term?
- Do word associations differ across political parties? 

The application includes two text analyses: word-trend analysis and bigram analysis.

# Dataset
The dataset contains **233 presidential addresses ranging from 1790 to 2021** and representing 43 U.S. presidents. 
Each record contains:

- Year
- President
- Political party
- Full speech text

The dataset includes 231 unique years. The years **1953** and **1961** each contain two records, which the word-frequency analysis combines by year.

**Time period**: 1790 - 2021
**Records**: 233
**Presidents**: 43
**Dataset Source**: [Dataset](https://github.com/brandon-marron/State-of-the-Union-Text-Analysis/blob/main/sotu.csv)

# Tools Used

- **R**
- **Shiny**: interactive web application
- **tidyverse**: data manipulation and transformation
- **tidytext**: tokenization and text analysis
- **Plotly**: interactive visualizations
- **DT**: interactive data tables
- **ggplot2**: data visualization


# Data Preparation
Before conducting our analysis, we prepared and tokenized the text data in R.

This included:
- Importing speech year, political party, and full speech text
- Standardizing missing historical party labels
- Cleaning possessive endings from words
- Tokenizing speeches into individual words
- Calculating total word counts for each year
- Calculating the frequency of every word by year
- Removing common stop words and numeric tokens
- Identifying frequently occurring meaningful terms for interactive selection
- Tokenizing the corpus into two-word sequences, or **bigrams**
- Removing stop words and numeric terms from bigram analysis

This allows comparison of word usage both within individual years and across the full period.

# Application Features

## 1. Word Trend Analysis
![Word Trend](https://github.com/brandon-marron/State-of-the-Union-Text-Analysis/blob/main/images/word-trend-war.png)

The Word Trend Analysis allows users to select the following: 
- A range of years
- A word to analyze
- Raw word frequency or normalized frequency

The selected word is then plotted across the chosen time period. 

The following measures are available:

### **Raw Count** 

The total number of times the selected word appears during each year.

### **Occurrences per 1,000 Words**

The word frequency, normalized by the total number of words spoken in that year.

Normalization is useful because State of the Union addresses vary in length. A word may appear more frequently in a longer speech simply because it has more words. 

The application also provides an interactive table containing:

- Year
- Word frequency
- Occurrences per 1,000 words
- Total words for the year


## 2. Bigram Analysis
![Bigram](https://github.com/brandon-marron/State-of-the-Union-Text-Analysis/blob/main/images/bigram-american-party.png)

The Bigram Analysis examines which words most frequently appear immediately after a selected word.

Users are allowed to select and change the following:
- The time period
- Selected word
- Number of following words displayed
- Whether results should be separated by political party

An example would be, selecting the word "american", allows the application to identify phrases such as "American people", "American families", or "American workers" and compare their frequency.

Users can enable **Facet by Party** to compare word associations across political parties. 

# Key Findings
Exploration of the State of the Union corpus reveals several notable patterns: 

- The word "war" changes with major periods of U.S. military conflicts. When normalized by speech length, the usage rises especially sharply during World War II, with **1944 showing the highest relative frequency in the dataset**.
- Normalizing word frequency is important because State of the Union addresses vary in length. Raw counts can make terms in longer addresses more prominent than they are.
- **"American people"** is one of the most common pairings with "American". Later addresses show differences in the other words associated with "American" across Democratic and Republican speeches.
- The corpus shows substantial changes in presidential vocabulary across more than two centuries, allowing for historical events and changing policy priorities to be explored through language.

These findings are descriptive. Word frequency indicates how often a term appears but does not, by itself, establish its meaning, sentiment, or context. 

# Repository Structure

```text
state-of-the-union-text-analysis/
│
├── images/
|   ├── word-trend-war.png
|    └── bigram-american-party.png
├── README.md
├── app.R
│
└── sotu.csv
```

# Running the Application
The application requires **R** and the following **packages**:
```R
library(shiny)
library(tidyverse)
library(tidytext)
library(DT)
library(plotly)
```
Clone or download the repository and make sure **sotu.csv** is located in the same directory as **app.R**.

Run the application using:
```R
shiny::runApp()
```

### Alternatively 
The application is published on **Posit Connect**. Please see the **Links** section to access the application. 

[GitHub Links](https://github.com/brandon-marron/State-of-the-Union-Text-Analysis#links))

**OR** 

**Application Link**: [State of the Union Project)](https://brandonmarron-bigram-project.share.connect.posit.cloud/)

# Limitations
This project focuses mainly on word frequency and relationships between adjacent words. 

Several limitations include:
- Word frequency does not tell the user the context or sentiment of a term.
- Bigram analysis only considers directly adjacent words.
- Speeches vary considerably in length and format across different periods.
- Addresses from the same year are combined during yearly word-trend analysis.
- Political parties and political language have changed throughout U.S. history, so comparing words across long periods of time should be interpreted carefully.

# Links
**Application Link**: [State of the Union Project](https://brandonmarron-bigram-project.share.connect.posit.cloud/)

**Dataset Download Link**: [Dataset](https://github.com/brandon-marron/State-of-the-Union-Text-Analysis/blob/main/sotu.csv)

**GitHub Repository**: [Repository](https://github.com/brandon-marron/State-of-the-Union-Text-Analysis.git)

**LinkedIn**: [LinkedIn Profile](https://www.linkedin.com/in/brandonmarron)
