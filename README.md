# FAIR Retrospective
Repository for 10 year FAIR Retrospective Paper written by Marla I Hertz, Kelsey Badger, Lena Bohman, Matthew Harp, Mikala Narlock, Amy Nurnberger, and Jung Mee Park. 
Submit all questions about the data analysis and code to Jung Mee Park.

Original Raw data was from OpenAlex when we looked for citations that cited "The FAIR Guiding Principles for scientific data management and stewardship" (March 2016) by Wilkinson et al (DOI: 10.1038/sdata.2016.18). 

## Software requirements
R and RStudio, using libraries tidyverse, treemapify, openalexR, readr, httr2, dplyr, tidyr, countrycode, waldo, forcats, showtext. 

## Raw data
The raw data is stored on Zenodo. Dimensions data is available via subscription at https://app.dimensions.ai
## Scripts
Run the 01-Data_Cleaning_FAIR_Retrospective.R file first and save the data outputs to a drive called /output_data.

Then run 02-Data_Visualization_Table_FAIR_Retrospective.qmd

## Helpful tips
The file paths will differ based on where you store the data files.

