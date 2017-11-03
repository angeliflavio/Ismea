library(shiny)
library(shinydashboard)
library(shinyBS)
library(rvest)
library(plotly)

# get table of prices
web <- read_html('http://www.ismeamercati.it/flex/cm/pages/ServeBLOB.php/L/IT/IDPagina/2977#MenuV')
prices <- html_table(web)[[1]]

dashboardPage(
    dashboardHeader(title = 'ISMEA Mercati',
                    dropdownMenu(type = 'notification',headerText = ' ',
                                 icon = img(src='github.png',width='17px'),badgeStatus = NULL,
                                 notificationItem('GitHub Source Code',
                                                  href = 'https://github.com/angeliflavio/Ismea',
                                                  icon = icon('github')))),
    dashboardSidebar(
        sidebarMenu(
            menuItem('Prezzi per piazza',tabName = 'prezzipiazza'),
            menuItem('Prezzi medi',tabName = 'prezzimedi'),
            menuItem('Dati mercato',tabName = 'produzione')
        )
    ),
    dashboardBody(
        tabItems(
            tabItem('prezzipiazza',
                    verticalLayout(
                        box(width = 12,background = 'navy',
                            flowLayout(
                                selectInput('prodotto','Prodotto',
                                            choices = c('Tutti','Mele','Pere','Uva','Kiwi','Pesche','Nettarine')),
                                selectInput('piazza','Piazza',
                                            choices = c('Tutte',unique(prices$Piazza)))
                            ),
                            tags$a(href='http://www.ismeamercati.it','Fonte ISMEA')
                        ),
                        box(width = 12,
                            dataTableOutput('prices')
                        )
                    )),
            tabItem('prezzimedi',
                    verticalLayout(
                        box(width = 4,background = 'navy',
                            selectInput('prodottopmedi','Prodotto',
                                        choices = c('Tutti','Mele','Pere','Uva','Susine','Albicocche',
                                                    'Ciliegie','Kiwi','Fragole')),
                            tags$a(href='http://www.ismeamercati.it','Fonte ISMEA')
                            ),
                        tabBox(width = 12,
                               tabPanel('Per Prodotto',dataTableOutput('pmedi')),
                               tabPanel('Per Varieta',dataTableOutput('pmedivarieta'))
                        )
                    )
                    ),
            tabItem('produzione',
                    verticalLayout(
                        box(width = 8,background = 'navy',
                            flowLayout(
                                selectInput('prodottoproduzione','Prodotto',
                                            choices = c('Mele')),
                                selectInput('areaproduzione','Area',
                                            choices = c('Nazionale','Regioni principali','Province principali')),
                                selectInput('misura','Misura',
                                            choices = c('Produzione (t)'='Produzione',
                                                        'Superficie (ha)'='Superficie',
                                                        'Resa (t/ha)'='Resa'))
                            ),
                            tags$a(href='http://www.ismeamercati.it','Fonte ISMEA')
                        ),
                        box(width = 12,
                            plotlyOutput('production'))
                    )
            ))
    )
)