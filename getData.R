library(xlsx)
library(rvest)
library(zoo)

# get table of prices
web <- read_html('http://www.ismeamercati.it/flex/cm/pages/ServeBLOB.php/L/IT/IDPagina/2977#MenuV')
prices <- html_table(web)[[1]]

# get excel file with prezzi medi per prodotto
download.file('http://www.ismeamercati.it/flex/tmp/xls/fdc9eed50d56cb7b924ed4f9d1162450.xlsx',
              'prezzi.xlsx',mode = 'wb')
pmedi <- read.xlsx('prezzi.xlsx',sheetIndex = 1,colIndex = c(1,3:16))
p <- sub('X','',names(pmedi[2:15]))
pp <- as.yearmon(p,"%Y.%m")
names(pmedi) <- c('Prodotto',as.character(pp))

# get p medi per vaietà
download.file('http://www.ismeamercati.it/flex/tmp/xls/54b39bb4fa3b1c547612f21b4b2f51b1.xlsx',
              'prezzivarieta.xlsx',mode='wb')
pmedivarieta <- read.xlsx('prezzivarieta.xlsx',sheetIndex = 1,colIndex = c(1,3:16))
pv <- sub('X','',names(pmedivarieta[2:15]))
ppv <- as.yearmon(pv,"%Y.%m")
names(pmedivarieta) <- c('Prodotto',as.character(ppv))