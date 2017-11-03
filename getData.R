library(xlsx)
library(rvest)
library(zoo)
library(plotly)
library(dplyr)
library(data.table)

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

# function to get data from xlsx to data frame, for production section
maketable <- function(area,url){
    temp <- tempfile()
    download.file(url,temp,mode = 'wb')
    table <- read.xlsx(temp,sheetIndex = 1,rowIndex = c(1,2,5,8),colIndex = c(1,3:7))
    tablet <- transpose(table[-1])
    colnames(tablet) <- table[,1]
    tablet$Anni <- gsub('X','',colnames(table[-1]))
    tablet$Area <- area
    return(tablet)
}

# urls for apple production
area <- c('Italia','Trentino AA','Veneto','Bolzano','Trento','Verona')
urls <- c('http://www.ismeamercati.it/flex/tmp/xls/45364f1aca810931b9bf81f1bbfca4dd.xlsx',
          'http://www.ismeamercati.it/flex/tmp/xls/b664bb4132ec6d9c0d500e1da65cf89b.xlsx',
          'http://www.ismeamercati.it/flex/tmp/xls/5fc642064bcbf12e925d64ae00381896.xlsx',
          'http://www.ismeamercati.it/flex/tmp/xls/6c933fd4f6b96d94e8ec13aa24bf735e.xlsx',
          'http://www.ismeamercati.it/flex/tmp/xls/e599f4ab187f6a0678c618a15c97f7d2.xlsx',
          'http://www.ismeamercati.it/flex/tmp/xls/bf877f49f999b2c5eb12f2afb591b94a.xlsx')
areas <- data.frame(Area=area,URL=urls)
areas$URL <- as.character(areas$URL)

# loop through urls to get data
tables <- list()
for (i in 1:nrow(areas)){
    tables[[i]] <- maketable(areas$Area[i],areas$URL[i])
}

# merge production tables
produzione <- bind_rows(tables[[1]],tables[[2]],tables[[3]],tables[[4]],tables[[5]],tables[[6]])
colnames(produzione) <- c('Produzione','Superficie','Resa','Anni','Area')


