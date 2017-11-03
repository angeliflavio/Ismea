library(shiny)
library(rvest)
library(dplyr)
library(plotly)
library(tidyr)

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
    
    output$production <- renderPlotly({
        if (input$areaproduzione=='Nazionale'){
            d <- filter(produzione,Area=='Italia')
            plot_ly(x=d$Anni,y=d[,input$misura]) %>% 
                layout(title='Italia',
                       yaxis=list(title=input$misura),xaxis=list(title='Anni'))
        }
        else if (input$areaproduzione=='Regioni principali'){
            d <- filter(produzione,Area %in% c('Trentino AA','Veneto'))
            dd <- select(d,input$misura,Anni,Area)
            dd <- spread(dd,Area,input$misura)
            plot_ly(x=dd$Anni,y=dd$`Trentino AA`,name='Trentino AA',type = 'bar') %>% 
                add_trace(y=dd$Veneto,name='Veneto') %>% 
                layout(title='Regioni principali',
                       yaxis=list(title=input$misura),xaxis=list(title='Anni'),barmode='group')
        }
        else if (input$areaproduzione=='Province principali'){
            p <- filter(produzione, Area %in% c('Bolzano','Trento','Verona'))
            pp <- select(p,input$misura,Anni,Area)
            pp <- spread(pp,Area,input$misura)
            plot_ly(x=pp$Anni,y=pp$Bolzano,name='Bolzano',type = 'bar') %>% 
                add_trace(y=pp$Trento,name='Trento') %>% 
                add_trace(y=pp$Verona,name='Verona') %>% 
                layout(title='Province principali',
                       yaxis=list(title=input$misura),xaxis=list(title='Anni'),barmode='group')
        }
    })
    
})
