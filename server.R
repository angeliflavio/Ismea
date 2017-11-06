library(shiny)
library(rvest)
library(dplyr)
library(plotly)
library(tidyr)
library(googleVis)

# get data from Ismea
source('getData.R')

# FAO data form csv files
apple <- read.csv('apple.csv',sep = ',')
apple <- na.omit(apple)
wine <- read.csv('wine.csv',sep = ',')
wine <- na.omit(wine)

shinyServer(function(input,output){
    
 # ISMEA data
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
    
 # FAO data
    output$worldmap <- renderGvis({
        world <- filter(apple,Year==input$yearmap,Element==input$measuremap)
        gvisGeoChart(world,locationvar = 'Area',colorvar = 'Value',
                     options = list(width='automatic',colors="['blue']"))
    })
    
    output$table <- renderDataTable({
        apple[,c('Area','Element','Year','Unit','Value','Flag.Description')]
    })
    
    output$timeline <- renderGvis({
        subset <- filter(apple,Area %in% input$countrytimeline ,Element==input$measuretimeline)
        subset$Year <- as.Date(paste(subset$Year,'12-31',sep = '-'))
        gvisAnnotationChart(subset,datevar = 'Year',numvar = 'Value',idvar = 'Area',
                            options = list(width='90%',displayZoomButtons=F))
    })
    
    output$motionapple <- renderGvis({
        a <- apple[,c('Area','Element','Year','Value')]
        names(a) <- c('Paese','Misura','Anno','Valore')
        if (input$countryapplemotion!='Tutti'){
            a <- filter(a, Paese %in% input$countryapplemotion)
        }
        p <- spread(a,Misura,Valore)
        m <- gvisMotionChart(p, idvar = "Paese", timevar = "Anno",
                             options=list(width='800'))
        m
    })
    
    output$worldmapwine <- renderGvis({
        winemap <- filter(wine,Year==input$yearmapwine)
        gvisGeoChart(winemap,locationvar = 'Area',colorvar = 'Value',
                     options = list(width='automatic',colors="['blue']"))
    })
    
    output$timelinewine <- renderGvis({
        subsetwine <- filter(wine,Area %in% input$countrytimelinewine)
        subsetwine$Year <- as.Date(paste(subsetwine$Year,'12-31',sep = '-'))
        gvisAnnotationChart(subsetwine,datevar = 'Year',numvar = 'Value',idvar = 'Area',
                            options = list(width='90%',displayZoomButtons=F))
    })
    
    output$tablewine <- renderDataTable({
        wine[,c('Area','Element','Year','Unit','Value','Flag.Description')]
    })
    
    output$motionwine <- renderGvis({
        a <- wine[,c('Area','Element','Year','Value')]
        names(a) <- c('Paese','Misura','Anno','Produzione')
        if (input$countrywinemotion!='Tutti'){
            a <- filter(a, Paese %in% input$countrywinemotion)
        }
        w <- gvisMotionChart(a, idvar = "Paese", timevar = "Anno",sizevar = 'Produzione',
                             options=list(width='800'))
        w
    })
    
})
