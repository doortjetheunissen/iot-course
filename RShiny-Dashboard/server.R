shinyServer(function(input,output,session){

  
  #############
  # FUNCTIONS #
  #############
  
  api.call <- function(){
    link <- 'https://industrial.api.ubidots.com/api/v1.6/'
    link_token <- 'auth/token/'
    
    r_token <- POST(paste0(link,link_token),
                    add_headers('x-ubidots-apikey' = ubidots_api_key))  # FILL IN YOUR API KEY IN api_key.R
    token <- content(r_token)$token
    
    # DO THIS API CALL FIRST AND THEN FILL IN THE RIGHT ID VALUE INSTEAD OF XXXXX IN link_values
    # link_variables <- 'variables/'
    # r_variables <- GET(paste0(link,link_variables),add_headers('X-Auth-Token' = token))
    # data_variables <- fromJSON(rawToChar(r_variables$content))
    # df_variables <- data.frame(data_variables$results)[1:2]
    # view(df_variables)
    
    link_values <- 'variables/XXXXX/values?page_size=200' 
    
    r_values <- GET(paste0(link,link_values),
                    add_headers('X-Auth-Token' = token))
    
    data_values <- fromJSON(rawToChar(r_values$content))
    df <- result_values <- data.frame(data_values$results)[1:2] #time in wrong format
    colnames(df) <- c('ts','temperature')
    df <- df %>% 
      mutate(timestamp = as_datetime(df$ts/1000, tz = 'Europe/Stockholm')) %>%
      select(timestamp, temperature)
    
    return(df)
  }
  
  filter.data <- reactive({
    df <- api.call()
    
    today <-floor_date(now(tzone = 'Europe/Stockholm'),'day')
    yesterday <- today - days(1)
    
    df <- df %>% filter(timestamp >= yesterday & timestamp < today)
    
  })
  
  calculate.minimum <- function(){
    df <- filter.data()
    
    minimum <- min(df$temperature)
    
    return(minimum)
  }
  
  calculate.maximum <- function(){
    df <- filter.data()
    
    maximum <- max(df$temperature)
    
    return(maximum)
  }
  
  calculate.average <- function(){
    df <- filter.data()
    
    average <- mean(df$temperature)
    
    return(average)
  }
    
  create.plot <- reactive({
    minimum <- calculate.minimum()
    maximum <- calculate.maximum()
    average <- calculate.average()
    
    minimum_adjusted <- minimum / 10
    maximum_adjusted <- maximum / 10
    average_adjusted <- (average - 25) / 10
    difference_adjusted <- (maximum_adjusted - minimum_adjusted - 0.5) * 2
    
    my_formula <- list(
      x = quote(average_adjusted * sign(x_i) * abs(x_i) ^ minimum_adjusted - sin(sign(y_i) * abs(y_i) ^ maximum_adjusted)),
      y = quote(difference_adjusted * sign(y_i) * abs(y_i) ^ minimum_adjusted + cos(sign(x_i) * abs(x_i) ^ maximum_adjusted)) 
    )
    
    df <- seq(from = -pi, to = pi, by = 0.01) %>%
      expand.grid(x_i = ., y_i = .) %>%
      mutate(!!!my_formula)
    
    if (maximum > 30){
      color = '#CC527A'
    } else if (maximum > 25){
      color = '#E39829'
    } else if (maximum > 20){
      color = '#7FBAA5'
    } else {
      color = '#077B88'
    }
    
    background_color = '#FFF8EB'
    
    plot <- ggplot(df, aes(x, y)) +
      geom_point(alpha = 0.1, size = 0, shape = 20, color = color) +
      theme_void() + 
      coord_polar() +
      theme(
        panel.background = element_rect(fill = background_color),
        plot.background = element_rect(fill = background_color)
      )
    
    
    return(plot)
  })
  
  
  ###########
  # OUTPUTS #
  ###########
  
  output$minimum.temperature <- renderText({
    minimum <- calculate.minimum()
    return(paste0(minimum, ' °C'))
  })
  
  output$maximum.temperature <- renderText({
    maximum <- calculate.maximum()
    return(paste0(maximum, ' °C'))
  })
  
  output$average.temperature <- renderText({
    average <- round(calculate.average(),1)
    return(paste0(average, ' °C'))
  })
  
  output$temperature.art <- renderPlot({
    plot <- create.plot()
    
    plot
  })
    
})
