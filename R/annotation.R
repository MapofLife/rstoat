
extract_layer <- function(layers) {
  if (list %in% is(layers)) {
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

# modis_lst_day_1000_1 -> modis-lst_day-1000-1
# landsat8_evi_30_16   -> landsat8-evi-30-16
internal_to_code <- function (code) {
  b = strsplit(code, '_')
  sapply(b, function(a){
    n <- length(a)
    if (n == 4) {
      return(paste0(a, collapse = '-'))
    } else {
      return(paste0(c(a[1], # product
                      paste(a[2:3], collapse = '_'), # variable
                      a[4], a[5]), collapse = '-'))
    }
  })
}

download_annotation_err <- function (e) {
  if(!curl::has_internet()) {
    message('The rstoat package requires an internet connection, please connect to the internet.')
    return(NULL)
  } else {
    message('File not found. Please check that your annotation has completed.')
    return(NULL)
  }
}

#' @title Start batch annotation
#'
#' @description Submit a dataset previously uploaded on mol.org for annotation.
#' To upload a dataset please visit https://mol.org/upload/
#' Requires login, please run mol_login(<email_address>)
#'
#' @param dataset_id The id of the dataset. List your datasets with the my_datasets() function.
#' @param title The title of the annotation job.
#' @param layers A list of parameters or vector of codes, of the layers, see the examples below.
#'
#' @return No return value, check my_jobs() to confirm successful job submission.
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
start_annotation_batch <- function (dataset_id, title, layers) {
  body <- list(
    dataset_id = dataset_id,
    title = title,
    layers = extract_layer(layers)
  )
  resp <- post_json('user','annotate','dataset', body = body)
  message(paste(resp$status, resp$message))
}

#' @title Start simple annotation
#'
#' @description Submit a dataframe for on-the-fly annotation.
#' Does not require login - for use for small numbers of records and pilot jobs.
#'
#' You can annotate using layers that are on earthengine!

#' Layer parameters:
#' Used by all:
#' \itemize{
#' \item spatial: The spatial buffer in meters.
#' \item temporal: The temporal buffer in days.
#' }
#'
#' For STOAT layers:
#' \itemize{
#'   \item product: The product e.g "srtm", or "landsat8".
#'   \item variable; The vairable, e.g "elevation", or "evi".
#' }
#'
#' For non STOAT layers, ie those in Google Earth Engine:
#' \itemize{
#' \item id: The id of the image in Google Earth Engine, mapped to "product" in the output.
#' \item static: Whether to load the imagery as an ImageCollection or as an Image.
#' \item bands: A list, wiht one element, which is used to specify which band of the imagery to use for the annotation, mapped to "variable" in the output.
#' \item reducers: A list containing one or more of the following: \itemize{
#'    \item mean
#'    \item lcv_count
#'    \item mode
#'    \item median
#'    \item stdev
#'    \item min
#'    \item max
#'    \item stdev
#'  } If only one is provided the output will be assigned to "value", else the output will be named the same as the reducer.
#'
#' }
#'
#'
#' @param events A data.frame for on the fly annotation
#' @param layers A list of parameters or vector of codes, of the layers, see the examples below.
#' @param coords A vector of length 2 containing column names for record longitudes, and latitudes.
#' @param date Column name for record dates, dates must take the format YYYY-MM-DD
#'
#'
#' @return Input data.frame with values from the annotation appended, in addition to unique identifier field event_id.
#' \itemize{
#'  \item event_id: A unique identifier for each occurrence
#'  \item product: Product used for annotation
#'  \item variable: Variable used for annotation
#'  \item s_buff: Spatial buffer in meters applied to occurrence
#'  \item t_buff: Temporal buffer in days applied to occurrence
#'  \item value: Annotated value of occurrence from requested layer (mean within buffer),
#'               if there is only one reducer (default), then this value will be here.
#'  \item stdev: Standard deviation of values within buffer
#'  \item valid_pixel_count: Number of pixels within buffered area'
#' }
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
#'
#' # simple layer string format: PRODUCT-VARIABLE-S_BUFF-T_BUFF
#' layers <- 'landsat8-evi-100-16'
#' start_annotation_simple(events, layers)
#'
#' start_annotation_simple(events, layers)
#'
#' # For lcv_count (Count of landcover value), 'value' returned is a string of
#' # landcover counts within the AOI.
#' # The output format is:
#' #  <LANDCOVER_CLASS>:<COUNT_OF_PIXELS_WITH_THAT_CLASS>
#' #  classes are seperated by commas.
#'
#' start_annotation_simple(events, list(
#'   list(
#'     id="COPERNICUS/Landcover/100m/Proba-V-C3/Global",
#'     s_buff=1000,
#'     reducers=list("lcv_count", "mode"),
#'     static=FALSE,
#'     t_buff=365,
#'     bands=list("discrete_classification")
#'   )
#' ))
#'
#' # Annotating with two worldclim layers:
#' #   bio01 is annual mean temperature
#' #   bio12 is annual precipitation
#'
#' start_annotation_simple(events, list(
#'  list(
#'    "id"= "WORLDCLIM/V1/BIO",
#'    "s_buff"=1000,
#'    "reducers"=list("mean"),
#'    "static"= TRUE,
#'    "t_buff"= 1,
#'    "bands"=list("bio01")
#'  ),
#'  list(
#'    "id"= "WORLDCLIM/V1/BIO",
#'    "s_buff"=1000,
#'    "reducers"=list("mean"),
#'    "static"= TRUE,
#'    "t_buff"= 1,
#'    "bands"=list("bio12")
#'  )
#' ))

#' }
start_annotation_simple <- function (events, layers, coords=c('lng','lat'), date='date') {
  if (any(!(c(coords[1], coords[2], date) %in% names(events)))) {
    stop("Dataframe must contain either columns 'lng', 'lat', 'date', or user must provide arguments for alternate column names")}
  events_subset <- data.frame(event_id = events$event_id,
                              lng = events[[coords[1]]],
                              lat = events[[coords[2]]],
                              date = events[[date]],
                              stringsAsFactors = F)
  body <- list(
    events = events_subset,
    params = extract_layer(layers)
  )
  resp <- post_json('annotate/ondemand', body = body, otf=T, authenticate=FALSE)

  resp <- merge(events, resp, by = 'event_id')
  resp
}

#' @title Download annotation results
#'
#' @description Download results of a successfully completed batch annotation.
#' Requires login, please run mol_login(<email_address>)
#' Uses the output from my_jobs() for the annotation id.
#'
#' @param annotation_id The id of the annotation
#' @param dir The directory where to write the annotation.
#' @return The path of the downloaded annotation.
#' @export
#'
#' @examples
#' \dontrun{
#' download_annotation(<annotation_id>, <dir>)
#' }
download_annotation <- function (annotation_id, dir = 'annotation_results') {
  url <- build_url('user/annotations', annotation_id, 'download')
  annotation_url <- get_resp({
    httr::GET(url, get_auth_header(), ua())
  })
  if (is.null(annotation_url)) return(NULL)
  annotation_url <- annotation_url$url
  tmp_path <- tempfile()
  download_path <- paste0(dir, '/', annotation_id)
  if (!dir.exists(dir)) {
    dir.create(dir)
    message(paste0('Created directory: ', dir))
  }
  if (dir.exists(download_path)) {
    message('Annotation already downloaded.')
    return(NULL)
  }

  status <- NULL
  # catch file not found error
  tryCatch ({
    status <- utils::download.file(annotation_url, tmp_path, mode='wb')
  }, error = download_annotation_err, warning = download_annotation_err
  )
  if (!is.null(status)) {
    if (status == 0){
      message('Unzipping')
      utils::unzip(tmp_path, exdir=download_path)
      message(paste0('Annotation available at: ', download_path))
      return(download_path)
    } else {
      message('There was an error downloading your annotation')
      return(NULL)
    }
  }
  else {
    message('There was an error downloading your annotation')
  }
}

#' @title Read annotation output into R
#' @description Convenience function which reads and joins annotation results spread across multiple files for space efficiency.
#' To run this function, please first download annotated data first using download_annotation()
#'
#' @param directory The path of the data.
#' @param drop_event_id Whether to drop the event_id column or not.
#'
#' @return A data.frame of annotated data, one row per variable per event
#' @export
#'
#' @examples
#' \dontrun{
#' read_output("path/to/your/downloaded/data/directory")
#' }
read_output <- function (directory, drop_event_id = TRUE) {
  files <- list.files(directory, full.names = T)
  species_file <- files[grepl('species.csv$', files)]
  event_file <- files[grepl('events.csv$', files)]
  events <- utils::read.csv(event_file)
  events$event_id <- as.character(events$event_id)
  species <- utils::read.csv(species_file)
  species$event_id <- as.character(species$event_id)

  if (!requireNamespace("dplyr", quietly = TRUE)) {
    print("Merging using base R. Install package \"dplyr\" for faster merges")
    out <- merge(species, events, by="event_id")
  }
  else {
    out <- dplyr::left_join(species, events, by="event_id")
  }

  output_files <- files[grepl('results.csv$', files)]

  for (output_file in output_files) {
    current_file <- utils::read.csv(output_file)
    current_file$event_id <- as.character(current_file$event_id)
    current_name <- basename(output_file)
    current_name <- sub("_results.csv", "", current_name)
    # create a new column in 'out' named after each output file
    current_file[current_name] <- current_file$value
    current_file <- current_file[, c("event_id", current_name)]

    if (!requireNamespace("dplyr", quietly = TRUE)) {
      out <- merge(out, current_file, by="event_id")
    }
    else {
      out <- dplyr::left_join(out, current_file, by="event_id")
    }
  }

  if (drop_event_id) out$event_id <- NULL
  out
}
