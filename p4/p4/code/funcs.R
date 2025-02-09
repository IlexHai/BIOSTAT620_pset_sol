library(httr2)
get_cdc_data <- function(endpoint){
  response <- request(endpoint) |> req_url_query("$limit" = 10000000) |>
    req_perform() |> 
    resp_body_json(simplifyVector = TRUE) |>
    as_tibble()
  
  return(response)
}