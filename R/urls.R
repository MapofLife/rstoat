base <- function (otf=FALSE) {
  otf_url <- Sys.getenv('MOL_OTF_URL')
  otf_url <- ifelse(otf_url == '', 'https://stoat-otf.azurewebsites.net', otf_url)
  ifelse(
    otf,
    otf_url,
    'https://api-dot-annotations-dot-map-of-life.appspot.com'
    )
}

build_url <- function (..., otf = FALSE) {
  paste(base(otf), ..., sep = '/', collapse = '/')
}

ua <- function () httr::user_agent(paste("rstoat", utils::packageVersion("rstoat")))

http_error_handle_parse <- function (resp, enc = "UTF-8", simplifyVector = TRUE) {
  # see: https://community.rstudio.com/t/internet-resources-should-fail-gracefully/49199/7
  if (httr::http_error(resp)) {
    e_message <- tryCatch(
    {
      jsonlite::fromJSON(httr::content(resp, "text", encoding = enc), simplifyVector = T)$message
    }, error = function(e) {paste(
        'Unable to parse error message: ', httr::text_content(resp)
      )
    })
    error_message <- paste0(
      "STOAT API request failed [", httr::status_code(resp),"]\n",
      e_message
    )
    message(error_message, call. = F)
    return(NULL)
  }
  if (httr::http_type(resp) != "application/json") {
    message(httr::content(resp))
    message("API did not return json.", call. = FALSE)
    return (NULL)
  }
  jsonlite::fromJSON(httr::content(resp, "text", encoding = enc), simplifyVector = simplifyVector)
}

err_func <- function (e) {
  if(!curl::has_internet()) {
    message('The rstoat package requires an internet connection, please connect to the internet.')
    return(NULL)
  } else {
    message(paste('Could not connect to: ', base(), ', please raise an issue on github: https://github.com/MapofLife/rstoat/issues '))
    return(NULL)
  }
}

get_resp <- function (block) {
  tryCatch(
    block,
    error = err_func
  )
}

get_json <- function (..., enc = "UTF-8", simplifyVector = TRUE, query = NULL, authenticate=TRUE) {
  resp <- get_resp(
    {
      if (authenticate) {
        resp <- httr::GET(build_url(...), ua(), get_auth_header(), query = query)
      } else {
        resp <- httr::GET(build_url(...), ua(), query = query)
      }
      resp
    })
  if (is.null(resp)) return(resp)
  http_error_handle_parse(resp, enc, simplifyVector = simplifyVector)
}

post_json <- function (..., body = list(), enc = "UTF-8", simplifyVector = TRUE, authenticate=TRUE) {
  resp <- get_resp({
    if (authenticate) {
      resp <- httr::POST(build_url(...), body = body, encode = "json", ua(), get_auth_header())
    } else {
      resp <- httr::POST(build_url(...), body = body, encode = "json", ua())
    }
    resp
  })
  if (is.null(resp)) return(resp)
  http_error_handle_parse(resp, enc, simplifyVector = simplifyVector)
}


#' @title Download sample annotation data
#'
#' @description Download the powerful owl and budgerigar sample datasets (both raw occurrence data and annotated data),
#' used in the Introduction vignette, from Map of Life's datastore.
#'
#' @param dir The directory where to store the data.
#'
#' @return The path of the downloaded sample data.
#' @export
#'
#' @examples
#' \dontrun{
#' download_sample_data()
#' }
download_sample_data <- function (dir = 'sample_data') {
  if (!dir.exists(dir)) {
    dir.create(dir)
    message(paste0('Created directory: ', dir))
  }
  res <- tryCatch({
      message('Downloading powerful owl occurrence data.')
      utils::download.file(build_url('samples/powerful_owl/vignette', otf=T), file.path(dir, 'powerful_owl_vignette.csv'), mode='wb')

      message('Downloading budgerigar occurrence data.')
      utils::download.file(build_url('samples/budgerigar/vignette', otf=T), file.path(dir, 'budgerigar_vignette.csv'), mode='wb')

      tmp_path <- tempfile()
      message('Downloading powerful owl annotated results data.')
      utils::download.file(build_url('samples/powerful_owl/results', otf=T), file.path(tmp_path), mode='wb')
      message('Unzipping powerful owl\n')
      utils::unzip(tmp_path, exdir=paste0(dir, '/powerful_owl_results'))

      message('Downloading budgerigar annotated results data.')
      utils::download.file(build_url('samples/budgerigar/results', otf=T), file.path(tmp_path), mode='wb')
      message('Unzipping budgerigar\n')
      utils::unzip(tmp_path, exdir=paste0(dir, '/budgerigar_results'))

      message(paste0('Annotation available in directory: ', dir))
      dir
  }, error = err_func, warning = err_func
  )
  return(res)
}

