library(shiny)
library(shinydashboard)
library(shinyBS)
library(rvest)

# get table of prices
web <- read_html('http://www.ismeamercati.it/flex/cm/pages/ServeBLOB.php/L/IT/IDPagina/2977#MenuV')
prices <- html_table(web)[[1]]

dashboardPage(
    dashboardHeader(title = 'ISMEA Mercati'),
    dashboardSidebar(
        sidebarMenu(
            menuItem('Prezzi per piazza',tabName = 'prezzipiazza'),
            menuItem('Prezzi medi',tabName = 'prezzimedi'),
            menuItem('Produzione',tabName = 'produzione')
        )
    ),
    dashboardBody(
        tabItems(
            tabItem('prezzipiazza',
                    verticalLayout(
                        box(width = 12,background = 'light-blue',
                            flowLayout(
                                selectInput('prodotto','Prodotto',
                                            choices = c('Tutti','Mele','Pere','Uva','Kiwi','Pesche','Nettarine')),
                                selectInput('piazza','Piazza',
                                            choices = c('Tutte',unique(prices$Piazza)))
                            )
                        ),
                        box(width = 12,
                            dataTableOutput('prices')
                        )
                    )),
            tabItem('prezzimedi',
                    verticalLayout(
                        box(width = 4,background = 'light-blue',
                            selectInput('prodottopmedi','Prodotto',
                                        choices = c('Tutti','Mele','Pere','Uva','Susine','Albicocche','Ciliegie','Kiwi','Fragole'))),
                        tabBox(width = 12,
                               tabPanel('Per Prodotto',dataTableOutput('pmedi')),
                               tabPanel('Per Varieta',dataTableOutput('pmedivarieta'))
                        )
                    )
                    ),
            tabItem('produzione',
                    verticalLayout(
                        box(width = 4,background = 'light-blue',
                            selectInput('prodottoproduzione','Prodotto',
                                        choices = c('Mele','Pere','Uve da tavola','Ciliegie ')))
                    ))
        )
    )
)