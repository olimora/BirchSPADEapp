launch_BirchSPADEapp = function(fcs_data_home_folder,
                                outputs_home_folder) {
  appDir <- system.file("app_dir", package = "BirchSPADEapp")
  print(appDir)
  if (appDir == "") {
    stop("Could not find the app. Try re-installing `BirchSPADEapp`.", call. = FALSE)
  }
  
  # does fcs_data_home_folder exist?
  if (!file.exists(fcs_data_home_folder)) {
    stop("Provided path to FSC files does not exist.", call. = FALSE)
  }
  if (!file.exists(outputs_home_folder)) {
    dir.create(outputs_home_folder, showWarnings = FALSE)
  }
  
  assign("BirchSPADEapp_fcs_data_home_folder_global", fcs_data_home_folder, envir = .GlobalEnv)
  assign("BirchSPADEapp_outputs_home_folder_global", outputs_home_folder, envir = .GlobalEnv)
  
  shiny::runApp(appDir, display.mode = "normal", launch.browser = T)
}
