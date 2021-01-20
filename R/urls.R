base <- function(otf=FALSE) {
  otf_url <- Sys.getenv('MOL_OTF_URL')
  otf_url <- ifelse(otf_url == '', 'https://stoat-otf.azurewebsites.net', otf_url)
  ifelse(
    otf,
    otf_url,
    'https://api-dot-annotations-dot-map-of-life.appspot.com'
    )
}

build_url <- function(..., otf = FALSE) {
  paste(base(otf), ..., sep = '/', collapse = '/')
}

ua <- function () httr::user_agent(paste("rstoat", utils::packageVersion("rstoat")))

http_error_handle_parse <- function(resp, enc = "UTF-8", simplifyVector = TRUE) {
  if (httr::http_error(resp)) {
    e_message <- tryCatch(
    {
      jsonlite::fromJSON(httr::content(resp, "text", encoding = enc), simplifyVector = T)$message
    }, error = function(e) {'Unable to parse error message'})

    error_message <- paste0(
      "STOAT API request failed [", httr::status_code(resp),"]\n",
      e_message
    )
    stop(error_message, call. = F)
  }
  if (httr::http_type(resp) != "application/json") {
    message(httr::content(resp))
    stop("API did not return json.", call. = FALSE)
  }
  jsonlite::fromJSON(httr::content(resp, "text", encoding = enc), simplifyVector = simplifyVector)
}

get_json <- function (..., enc = "UTF-8", simplifyVector = TRUE, query = NULL, authenticate=TRUE) {
  if (authenticate) {
    resp <- httr::GET(build_url(...), ua(), get_auth_header(), query = query)
  } else {
    resp <- httr::GET(build_url(...), ua(), query = query)
  }
  http_error_handle_parse(resp, enc, simplifyVector = simplifyVector)
}

post_json <- function (..., body = list(), enc = "UTF-8", simplifyVector = TRUE, authenticate=TRUE) {
  if (authenticate) {
    resp <- httr::POST(build_url(...), body = body, encode = "json", ua(), get_auth_header())
  } else {
    resp <- httr::POST(build_url(...), body = body, encode = "json", ua())
  }
  http_error_handle_parse(resp, enc, simplifyVector = simplifyVector)
}
