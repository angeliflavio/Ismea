library(shiny)
library(shinydashboard)
library(shinyBS)
library(rvest)
library(plotly)

# get table of prices
web <- read_html('http://www.ismeamercati.it/flex/cm/pages/ServeBLOB.php/L/IT/IDPagina/2977#MenuV')
prices <- html_table(web)[[1]]

# get FAO data from csv files
apple <- read.csv('apple.csv',sep = ',')
wine <- read.csv('wine.csv',sep = ',')

dashboardPage(
    dashboardHeader(title = 'ISMEA Mercati',
                    dropdownMenu(type = 'notification',headerText = ' ',
                                 icon = img(src='github.png',width='17px'),badgeStatus = NULL,
                                 notificationItem('GitHub Source Code',
                                                  href = 'https://github.com/angeliflavio/Ismea',
                                                  icon = icon('github')))),
    dashboardSidebar(
        sidebarMenu(
            menuItem('FAO Dati Globali Mele',tabName = 'faomele'),
            menuItem('FAO Dati Globali Vino',tabName = 'faovino'),
            menuItem('ISMEA Prezzi per piazza Italia',tabName = 'prezzipiazza'),
            menuItem('ISMEA Prezzi medi Italia',tabName = 'prezzimedi'),
            menuItem('ISMEA Dati mercato Italia',tabName = 'produzione')
        )
    ),
    dashboardBody(
        tabItems(
            tabItem('faomele',
                    tabsetPanel(
                        tabPanel('Mappa',
                                 br(),
                                 verticalLayout(
                                     box(background = 'navy',width = 12,
                                         flowLayout(
                                             selectInput('measuremap','Misura',
                                                         choices = c('Produzione (ton)'= 'Production',
                                                                     'Superficie (ettari)'='Area harvested',
                                                                     'Resa (hg/ettaro)'='Yield'),
                                                         selected = 'Produzione'),
                                             selectInput('yearmap','Anno',
                                                         choices = seq(1961,2014),selected = 2014)
                                         ),
                                         tags$a(href='http://www.fao.org','Fonte FAO') 
                                     ),
                                     box(width = 12,
                                         br(),
                                         htmlOutput('worldmap'))
                                 )
                        ),
                        tabPanel('Grafico',
                                 br(),
                                 verticalLayout(
                                     box(width = 4,background = 'navy',
                                         selectInput('countryapplemotion','Paesi',
                                                     choices = c('Tutti',as.vector(unique(apple$Area))),
                                                     selected = 'Tutti',
                                                     multiple = T),
                                         bsTooltip('countryapplemotion','Selezione singola o multipla',
                                                   options = list(container = "body")),
                                         br(),
                                         tags$a(href='http://www.fao.org','Fonte FAO')
                                     ),
                                     box(width = 12,
                                         htmlOutput('motionapple')
                                     )
                                 )
                        ),
                        tabPanel('Grafico storico',
                                 br(),
                                 verticalLayout(
                                     box(width = 12,background = 'navy',
                                         flowLayout(
                                             selectInput('measuretimeline','Misura',
                                                         choices = c('Produzione (ton)'= 'Production',
                                                                     'Superficie (ettari)'='Area harvested',
                                                                     'Resa (hg/ettaro)'='Yield'),
                                                         selected = 'Produzione (ton)'),
                                             selectInput('countrytimeline','Paesi',
                                                         choices = as.vector(unique(apple$Area)),
                                                         selected = 'Italy',
                                                         multiple = T),
                                             bsTooltip('countrytimeline','Selezione singola o multipla',
                                                       options = list(container = "body"))
                                         ),
                                         tags$a(href='http://www.fao.org','Fonte FAO')
                                     ),
                                     box(width = 12,
                                         htmlOutput('timeline'))
                                 )
                        ),
                        tabPanel('Tabella',
                                 br(),
                                 dataTableOutput('table'))
                    )
                    ),
            tabItem('faovino',
                    tabsetPanel(
                        tabPanel('Mappa',
                                 br(),
                                 verticalLayout(
                                     box(width = 4,background = 'navy',
                                         selectInput('yearmapwine','Anno',
                                                     choices = seq(1961,2014),selected = 2014),
                                         br(),
                                         tags$a(href='http://www.fao.org','Fonte FAO')
                                     ),
                                     box(width = 12,
                                         br(),
                                         htmlOutput('worldmapwine'))
                                 )),
                        tabPanel('Grafico',
                                 br(),
                                 verticalLayout(
                                     box(width = 4,background = 'navy',
                                         selectInput('countrywinemotion','Paesi',
                                                     choices = c('Tutti',as.vector(unique(wine$Area))),
                                                     selected = 'Tutti',
                                                     multiple = T),
                                         bsTooltip('countrywinemotion','Selezione singola o multipla',
                                                   options = list(container = "body")),
                                         br(),
                                         tags$a(href='http://www.fao.org','Fonte FAO')
                                     ),
                                     box(width = 12,
                                         br(),
                                         htmlOutput('motionwine')
                                     )
                                 )),
                        tabPanel('Grafico storico',
                                 br(),
                                 verticalLayout(
                                     box(width = 4,background = 'navy',
                                         selectInput('countrytimelinewine','Paesi',
                                                     choices = as.vector(unique(wine$Area)),
                                                     selected = 'Italy',
                                                     multiple = T),
                                         bsTooltip('countrytimelinewine','Selezione singola o multipla',
                                                   options = list(container = "body")),
                                         br(),
                                         tags$a(href='http://www.fao.org','Fonte FAO')
                                     ),
                                     box(width = 12,
                                         br(),
                                         htmlOutput('timelinewine'))
                                 )),
                        tabPanel('Tabella',
                                 br(),
                                 dataTableOutput('tablewine'))
                    )
                    ),
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