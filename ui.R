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
                              selectize = TRUE, width = '50%', size = NULL),
                  
                  # markers for clustering
                  tags$div(align = 'left',
                           class = 'multicol',
                           checkboxGroupInput("markers", label = "Clustering markers",
                                              choices = NULL)),
                  
                  # analyisi settings
                  h4("Basic settings"),
                  fluidRow(
                    column(12, 
                           textInput("output_name", "Name of output folder", width = "50%")
                    ),
                    column(2,
                           checkboxInput("outlier_removal", "Outlier removal", TRUE),
                           checkboxInput("plot_pdfs", "Plot trees to PDF files", TRUE)
                    ),
                    column(2,
                           numericInput("clust_num", "Number of clusters", value = 500, min = 0, max = 1500, step = 100, width = 200)
                    ),
                    column(2,
                           numericInput("kmeans_iters", "Upsampling iterations", value = 1, min = 1, max = 5, step = 1, width = 200)
                    )
                    
                  ),
                  
                  h4("Additional settings"),
                  fluidRow(
                    column(3,
                           numericInput("subclust_lim", "Subcluster count limit (0 for auto)", value = 0, min = 0, max = 50000, step = 1000)  
                    ),
                    column(9,
                           radioButtons("normalization", "Normalization", inline = T, 
                                        choices = c("MinMax" = "minmax", "MeanSTD" = "meanstd", "None" = "none"))
                    )
                  ),
                  
                  useShinyjs(),
                  actionButton("run_analysis", "Run BirchSPADE"),
                  
                  # textOutput("status_info")
                  textInput("status_info", "BirchSPADE status:", width = "50%")
))