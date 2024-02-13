# gbif.R
# Last modified: 13 February 2024




# ----- ABOUT -----

# Code from Jeremy

# 1) Query species occurrence data from GBIF
# 2) Clean up the data
# 3) Save it to a csv file
# 4) Create a map to display the species occurrence points




# ----- LOAD LIBRARIES -----

# List packages needed
packages <- c("tidyverse",
              "rgbif",
              "usethis",
              "CoordinateCleaner")

# Install packages (if not already)
installed_packages <- packages %in% rownames(installed.packages())

if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Load packages
# invisible(lapply(packages, library, character.only = TRUE))
library(tidyverse)
library(rgbif)
library(usethis)
library(CoordinateCleaner)




# ----- QUERY FROM GBIF -----

# We need to edit some credentials to allow access in pulling GBIF data
usethis::edit_r_environ()

# --

# What is our species' taxon ID?
# We need this to pull our data in from GBIF

# Get information on species
spiderBackbone <- name_backbone(name = "Habronattus americanus")

# Pull out taxon ID
speciesKey <- spiderBackbone$speciesKey

# Request data
occ_download(pred("taxonKey", speciesKey), format = "SIMPLE_CSV")

# What prints in the console?

# <<gbif download>>
  # Your download is being processed by GBIF:
    # https://www.gbif.org/occurrence/download/0012117-240202131308920
    # Most downloads finish within 15 min.
  # Check status with: occ_download_wait('0012117-240202131308920')
  # After it finishes, use:
    # d <- occ_download_get('0012117-240202131308920') %>%
    # occ_download_import()
  # to retrieve your download.

# Download Info:
  # Username: tmcruz
  # E-mail: tmcruz@arizona.edu
  # Format: SIMPLE_CSV
  # Download key: 0012117-240202131308920
  # Created: 2024-02-13T18:28:53.151+00:00

# Citation Info:  
  # Please always cite the download DOI when using this data.
  # https://www.gbif.org/citation-guidelines
  # DOI: 10.15468/dl.t3c33t

# Citation:
  # GBIF Occurrence Download 
  # https://doi.org/10.15468/dl.t3c33t 
  # Accessed from R via rgbif (https://github.com/ropensci/rgbif) 
  # on 2024-02-13

# Get our data (stored somewhere in GBIF?) and store in data folder
d <- occ_download_get('0012117-240202131308920',
                      path = "data/") %>%
  occ_download_import()

# 639 observations

# Save data
write.csv(d, "data/rawData.csv")



# ----- CLEAN DATA (STEP-BY-STEP) -----

# Remove NA latitude and longitude
fData <- d %>%
  filter(!is.na(decimalLatitude), 
         !is.na(decimalLongitude))

# 594 observations

# Confine to data in US, Mexico, and Canada
fData <- fData %>%
  filter(countryCode %in% c("US", "MX", "CA"))

# 594 observations

# Remove organisms that are museum specimens and in zoos
fData <- fData %>%
  filter(!basisOfRecord %in% c("FOSSIL_SPECIMEN", "LIVING_SPECIMEN"))

# 594 observations

# Remove duplicates (reduces sampling bias)
fData <- fData %>%
  distinct(decimalLongitude,
           decimalLatitude,
           speciesKey,
           datasetKey,
           .keep_all = TRUE)

# 333 observations

# Rename our cleaned data
cleanData <- fData




# ----- CLEAN DATA (ALL IN ONE) -----

cleanData <- d %>%
  filter(!is.na(decimalLatitude), 
         !is.na(decimalLongitude)) %>%
  filter(countryCode %in% c("US", "MX", "CA")) %>%
  filter(!basisOfRecord %in% c("FOSSIL_SPECIMEN", "LIVING_SPECIMEN")) %>%
  distinct(decimalLongitude,
           decimalLatitude,
           speciesKey,
           datasetKey,
           .keep_all = TRUE)




# ----- SAVE CLEANED DATA -----
write.csv(cleanData, "data/cleanData.csv")





