library(shiny)
library(shinyjs)

tweaks <-
  list(tags$head(tags$style(HTML("
                                 .multicol {
                                 -webkit-column-count: 5; /* Chrome, Safari, Opera */
                                 -moz-column-count: 5;    /* Firefox */
                                 column-count: 5;
                                 -moz-column-fill: auto;
                                 -column-fill: auto;
                                 padding-bottom: 20px
                                 }
                                 "))),
       tags$head(
         tags$style(HTML('#run_analysis{background-color:#66ccff}'))
       )
  )

# Define UI for application that draws a histogram
shinyUI(fluidPage(tweaks,
                  
                  # Application title
                  titlePanel("BirchSPADE"),
                  
                  # input file
                  selectInput("file", "File", choices = NULL, selected = NULL, multiple = FALSE,
                              selectize = TRUE, size = NULL, width = "90%"),
                  
                  # markers for clustering
                  tags$div(align = 'left',
                           class = 'multicol',
                           checkboxGroupInput("markers", label = "Clustering markers",
                                              choices = NULL)),
                  
                  # analyisi settings
                  h4("Settings"),
                  fluidRow( # row with output folder
                    column(12, 
                           textInput("output_name", "Name of output folder", width = "90%")
                    )
                  ),
                  fluidRow(
                    column(5,
                           radioButtons("normalization", "Normalization", inline = T, 
                                        choices = c("MinMax" = "minmax", "MeanSTD" = "meanstd", "None" = "none")),
                           checkboxInput("outlier_removal", "Remove outliers", TRUE),
                           checkboxInput("use_density", "Use density in clustering", TRUE),
                           checkboxInput("plot_pdfs", "Plot trees to PDF files", FALSE)
                    ),
                    column(5,
                           numericInput("subclust_lim", "Subcluster count limit (0 for auto)", value = 0, min = 0, max = 50000, step = 1000),
                           numericInput("clust_num", "Number of clusters", value = 500, min = 0, max = 1500, step = 100),
                           numericInput("kmeans_iters", "Upsampling iterations", value = 1, min = 1, max = 5, step = 1)
                    )
                  ),
                  
                  useShinyjs(),
                  actionButton("run_analysis", "Run BirchSPADE"),
                  
                  # textOutput("status_info")
                  textInput("status_info", "BirchSPADE status:", width = "50%")
))