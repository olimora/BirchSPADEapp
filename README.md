# BirchSPADEapp

# example to run

```R
library(devtools)

devtools::load_all("BirchSPADEapp/")
devtools::install("BirchSPADEapp/")

# or install from github
devtools::install_github("olimora/BirchSPADEapp")

library(BirchSPADEapp)
BirchSPADEapp::launch_BirchSPADEapp(fcs_data_home_folder = "~path to folder with fcs data~", 
                                    outputs_home_folder = "~path to ouput folder~")
```
