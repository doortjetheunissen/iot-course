source('libraries.R')
source('api_key.R')

shinyUI(
  fluidPage(
    includeCSS('art.css'),
    fluidRow( # title
      id = 'art-header',
      column(div(class = 'header-title', 'ART OF THINGS'), width = 12, align = 'center')
    ),
    fluidRow( # temperature title
      id = 'sensor-header',
      column(div(class = 'header-title', 'TEMPERATURE'), width = 12, align = 'center')
    ),
    fluidRow( # temperature statistics title
      column(div(class = 'statistics-title', 'minimum'), width = 4, align = 'center'),
      column(div(class = 'statistics-title', 'maximum'), width = 4, align = 'center'),
      column(div(class = 'statistics-title', 'average'), width = 4, align = 'center')
    ),
    fluidRow( # temperature statistics
      column(div(class = 'statistics-title', textOutput('minimum.temperature')), width = 4, align = 'center'),
      column(div(class = 'statistics-title', textOutput('maximum.temperature')), width = 4, align = 'center'),
      column(div(class = 'statistics-title', textOutput('average.temperature')), width = 4, align = 'center')
    ), # fluidRow statistics
    fluidRow(
      id = 'spacer'
    ),
    fluidRow( # temperature art
      column(plotOutput('temperature.art'), width = 12, align = 'center')
    )
  ) # fluidPage
) # shinyUI
