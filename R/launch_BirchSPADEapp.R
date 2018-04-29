launch_BirchSPADEapp = function() {
  appDir <- system.file("app_dir", package = "BirchSPADEapp")
  if (appDir == "") {
    stop("Could not find the app. Try re-installing `BirchSPADEapp`.", call. = FALSE)
  }
  
  shiny::runApp(appDir, display.mode = "normal", launch.browser = T)
}