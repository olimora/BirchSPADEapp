library(shiny)
library(shinyjs)
library(flowCore)
library(BirchSPADE)

# BirchSPADEapp_fcs_data_home_folder_global = "/home/DATA/BIOINF-DATA/"
files = list.files(BirchSPADEapp_fcs_data_home_folder_global, pattern = "\\.fcs$", recursive = T)

getSubclustLimit = function(cell_count) {
  ret = round(cell_count/10)
  if (ret > 50000) {
    rer = 50000
  }
  return(ret)
}


shinyServer(function(input, output, session) {
  shinyjs::hide("status_info")
  shinyjs::disable("status_info")
  
  filter <- reactive({
    if (!exists("BirchSPADEapp_fcs_data_home_folder_global") || !exists("BirchSPADEapp_outputs_home_folder_global"))
      stop("Global variable does not exist in global environment.")
  })
  
  # observe to fill files select input
  observe({
    updateSelectInput(session, "file",
                      choices = files)
  })
  
  # observe to fill markers checkboxes
  observe({
    if (input$file != "") {
      input_file_full = paste0(BirchSPADEapp_fcs_data_home_folder_global, "/", input$file)
      if (isFCSfile(input_file_full)) {
        tryCatch({
          in_fcs = read.FCS(input_file_full)
          chcs = as.vector(parameters(in_fcs)@data$desc)
          updateCheckboxGroupInput(session, "markers",
                                   choices = chcs[1:length(chcs)])
          updateNumericInput(session, "subclust_lim", value = getSubclustLimit(nrow(exprs(in_fcs))))
          rm(in_fcs)
        }, warning  = function(e) {
          showModal(modalDialog(
            title = "Invalid FCS file",
            HTML(paste("The file you chosen is invalid.<br>Message:<br>", e)),
            easyClose = TRUE
          ))
        })
      }
    }
  })
  
  # to count selected
  observe({
    if (is.null(input$markers)) {
      num = 0
    } else {
      num = length(input$markers)
    }
    selected_markers = input$markers
    updateCheckboxGroupInput(session, "markers", label = paste0("Clustering markers", " (", num, ")"))
  })
  
  # to keep selected when changing the file
  observe({
    input$file
    updateCheckboxGroupInput(session, "markers",
                             selected = input$markers)
  })
  
  # change output folder name with file change
  observe({
    folder = BirchSPADEapp_outputs_home_folder_global
    folder_outputs = paste0(folder,"/","BirchSPADE_outputs/")
    dir.create(folder_outputs, showWarnings = FALSE)
    val = paste0(folder_outputs, basename(input$file))
    updateTextInput(session, "output_name", value = val)
  })
  
  # validate limit of subclusters
  observe({
    is_numeric = is.numeric(input$subclust_lim)
    is_integer = is.integer(input$subclust_lim)
    if (!is_numeric || !is_integer || input$subclust_lim < 0) {
      showModal(modalDialog(
        title = "Invalid limit of subclusters",
        "Number of subclusters can be only integer",
        easyClose = TRUE
      ))
      updateNumericInput(session, "subclust_lim", value = 10000)
    }
  })
  
  # validate number of clusters
  observe({
    is_numeric = is.numeric(input$clust_num)
    is_integer = is.integer(input$clust_num)
    if (!is_numeric || !is_integer || input$clust_num < 0) {
      showModal(modalDialog(
        title = "Invalid number of clusters",
        "Number of clusters can be only integer",
        easyClose = TRUE
      ))
      updateNumericInput(session, "clust_num", value = 500)
    }
  })
  
  # validate number of kmens iterations
  observe({
    is_numeric = is.numeric(input$kmeans_iters)
    is_integer = is.integer(input$kmeans_iters)
    if (!is_numeric || !is_integer || input$kmeans_iters < 0 || input$kmeans_iters > 5) {
      showModal(modalDialog(
        title = "Invalid number of upsampling iterations",
        "Number of iterations can be only integer. From 1 to 5",
        easyClose = TRUE
      ))
      updateNumericInput(session, "kmeans_iters", value = 1)
    }
  })
  
  #button to run spade
  observeEvent(input$run_analysis, {
    verified = TRUE
    
    ## verify that chosen markers length > 0
    if (length(input$markers) < 2) {
      showModal(modalDialog(
        title = "No markers chosen or too few markers choosen",
        "You have to choose markers to use in clustering",
        easyClose = TRUE
      ))
      verified = FALSE
    }
    
    if (verified) {
      # running analysis
      shinyjs::disable("file")
      shinyjs::disable("markers")
      shinyjs::disable("output_name")
      shinyjs::disable("outlier_removal")
      shinyjs::disable("use_density")
      shinyjs::disable("plot_pdfs")
      shinyjs::disable("clust_num")   
      shinyjs::disable("kmeans_iters")
      shinyjs::disable("subclust_lim")
      shinyjs::disable("normalization")
      shinyjs::disable("run_analysis")
      
      shinyjs::show("status_info")
      shinyjs::enable("status_info")
      updateTextInput(session, "status_info", value = "BirchSPADE is running.")
      
      withProgress(message = 'Running analysis', value = 0, {
        incProgress(0.5, detail = "Just running")
        
        BirchSPADE.run.analysis(input_file_full = paste0(BirchSPADEapp_fcs_data_home_folder_global,input$file),
                                outputs_dir = gsub(x = input$output_name, pattern = basename(input$file), replacement = ""),
                                markers = input$markers,
                                normalization = input$normalization,
                                remove_outliers = input$outlier_removal,
                                final_cluster_count = input$clust_num,
                                kmeans_upsampling_iterations = input$kmeans_iters,
                                plot_trees = input$plot_pdfs,
                                subcluster_limit = input$subclust_lim,
                                use_density = input$use_density,
                                hclust_method = "ward")
      })
      
      shinyjs::enable("file")
      shinyjs::enable("markers")
      shinyjs::enable("output_name")
      shinyjs::enable("outlier_removal")
      shinyjs::enable("use_density")
      shinyjs::enable("plot_pdfs")
      shinyjs::enable("clust_num")   
      shinyjs::enable("kmeans_iters")
      shinyjs::enable("subclust_lim")
      shinyjs::enable("normalization")
      shinyjs::enable("run_analysis")
      
      updateTextInput(session, "status_info", value = "SPADE has succesfully ended.")
      showModal(modalDialog(
        title = "",
        "BirchSPADE analysis has succesfully ended.",
        easyClose = F
      ))
    }
    
  })
})

# BirchSPADE.save_original_data_with_clusters()