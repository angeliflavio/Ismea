library(shiny)
library(rvest)
library(dplyr)

# get data from Ismea
source('getData.R')


shinyServer(function(input,output){
    
    output$prices <- renderDataTable({
        t <- prices
        if (input$piazza!='Tutte'){t <- filter(t,Piazza==input$piazza)}
        if (input$prodotto!='Tutti'){t <- filter(t,grepl(input$prodotto,Prodotto))}
        t
    })
    
    output$pmedi <- renderDataTable({
        d <- pmedi
        if (input$prodottopmedi!='Tutti'){d <- filter(d,grepl(input$prodottopmedi,Prodotto))}
        d
    })
    
    output$pmedivarieta <- renderDataTable({
        dd <- pmedivarieta
        if (input$prodottopmedi!='Tutti'){dd <- filter(dd,grepl(input$prodottopmedi,Prodotto))}
        dd
    })
    
})
