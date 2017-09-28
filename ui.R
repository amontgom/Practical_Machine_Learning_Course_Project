library(shiny)
library(ggplot2)

dataset <- airquality

shinyUI(pageWithSidebar(
    
    headerPanel('Air Quality Plotter'),
    
    sidebarPanel(
        
        sliderInput('sampleSize', 'Sample Size (Non-Random)', min=1, max=nrow(dataset),
                    value=min(1, nrow(dataset)), step=1, round=0),
        
        selectInput('x', 'X Axis', names(dataset)),
        selectInput('y', 'Y Axis', names(dataset), names(dataset)[[2]]),
        selectInput('color', 'Color by:', c('None', names(dataset))),
        selectInput('size', 'Size By:', c('None', names(airquality))),
        
        checkboxInput('linReg', 'Linear Regression Line'),
        checkboxInput('smooth', 'Smooth Line'),
        
        selectInput('facet_row', 'Split By Rows:', c(None='.', names(dataset))),
        selectInput('facet_col', 'Split By Columns:', c(None='.', names(dataset))),
        
        helpText("New York Air Quality Measurements"),
        helpText("Use the sliders, dropdowns, and checkboxes to explore the airquality dataset"),
        helpText("Ozone: Mean ozone in parts per billion from 1300 to 1500 hours at Roosevelt Island"),
        helpText("Solar.R: Solar radiation in Langleys in the frequency band 4000-7700 Angstroms from 0800 to 1200 hours at Central Park"),
        helpText("Wind: Average wind speed in miles per hour at 0700 and 1000 hours at LaGuardia Airport"),
        helpText("Temp: Maximum daily temperature in degrees Fahrenheit at La Guardia Airport."),
        helpText("Chambers, J. M., Cleveland, W. S., Kleiner, B. and Tukey, P. A. (1983) Graphical Methods for Data Analysis. Belmont, CA: Wadsworth.") 
    ),
    
    mainPanel(
        plotOutput('plot')
    )
))