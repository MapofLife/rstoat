
extract_layer <- function(layers) {
  if (class(layers) != "list") {
    layers <- lapply(layers, function (slayer) {
      layer = strsplit(slayer, "-")[[1]]
      if (length(layer) != 4) {
        stop(paste("Layer", slayer, "must be in the format '<PRODUCT CODE>-<VARIABLE>-<SPATIAL BUFFER>-<TEMPORAL BUFFER>'"))
      }
      list(
        product = layer[1], variable = layer[2], spatial = as.numeric(layer[3]), temporal = as.numeric(layer[4])
      )
    })
  }
  layers
}


#' Submit a dataset previously uploaded on mol.org for annotation.
#'
#' To upload a dataset please visit https://mol.org/upload/
#' Requires login, please run mol_login(<email_address>)
#'
#' @param dataset_id The id of the dataset. List your datasets with the my_datasets() function.
#' @param title The title of the annotation job.
#' @param layers A list of parameters or vector of codes, of the layers, see the examples below.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' start_annotation_batch('<dataset_id>', 'My annotation task', layers = list(
#'    list(product = "chelsa", variable = "precip", spatial = 1000, temporal = 30)
#' ))
#' # alternatively supplying the code is fine.
#' start_annotation_batch('<datset_id>',
#'   'My 2nd annotation task', layers = c("modis-ndvi-1000-1", "modis-lst_day-1000-1"))
#' }
#'
start_annotation_batch <- function(dataset_id, title, layers) {
  body <- list(
    dataset_id = dataset_id,
    title = title,
    layers = extract_layer(layers)
  )
  resp <- post_json('user','annotate','dataset', body = body)
  message(paste(resp$status, resp$message))
}



#' Submit a dataframe for on the fly annotation
#'
#' Does not require login - for use for small numbers of records and pilot jobs
#'
#' @param events A data.frame with the following columns: event_id (character), lat (numeric), lng (numeric), date (string/date) in the format YYYY-MM-DD
#'
#' @param layers A list of parameters or vector of codes, of the layers, see the examples below.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' events <- data.frame(
#'    event_id = as.character(1:2),
#'    lng = c(-4, 24),
#'    lat = c(10, 10),
#'    date = '2015-01-01'
#' )
#' layers <- 'landsat8-evi-100-16'
#' start_annotation_simple(events, layers)
#' }
start_annotation_simple <- function(events, layers) {
  if(any(!(c("event_id", "lng", "lat", "date") %in% names(events)))) {
    stop("Dataframe must contain columns 'event_id', 'lng', 'lat', 'date'")
  }
  body <- list(
    events = events,
    params = extract_layer(layers)
  )
  resp <- post_json('annotate', body = body, otf=T, authenticate=FALSE)
  resp
}
