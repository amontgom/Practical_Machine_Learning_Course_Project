library(shiny)
library(ggplot2)

shinyServer(function(input, output) {
    
    dataset <- reactive( {
        airquality[sample(nrow(airquality), input$sampleSize),]
    })
    
    output$plot <- reactivePlot(function() {
        
        p <- ggplot(dataset(), aes_string(x=input$x, y=input$y)) + geom_point()
        
        if (input$color != 'None')
            p <- p + aes_string(color=input$color)
        
        if (input$size != "None")
            p <- p + aes_string(size = input$size)
        
        facets <- paste(input$facet_row, '~', input$facet_col)
        if (facets != '. ~ .')
            p <- p + facet_grid(facets)
        
        if (input$linReg)
            p <- p + geom_smooth(method = lm, se=FALSE)
        
        if (input$smooth)
            p <- p + geom_smooth()
        
        print(p)
        
    }, height=600
    )
    
})