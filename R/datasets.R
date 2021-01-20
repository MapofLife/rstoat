#' List logged in users uploaded datasets (uploaded to https://mol.org through https://mol.org/upload).
#'
#' Requires login, please run mol_login(<email_address>)
#'
#' @return A data frame of a users datasets and their associated ids.
#' @export
#'
#' @examples
#' \dontrun{
#' my_datasets()
#' }
my_datasets <- function () {
  get_json('user','datasets')
}

#' List logged in users current annotation jobs.
#'
#' Requires login, please run mol_login(<email_address>)
#'
#' @return A data.frame containing jobs metadata.
#' @export
#' @examples
#' \dontrun{
#' my_jobs()
#' }
my_jobs <- function () {
  get_json('user','annotations')
}

#' Get details of a custom annotation job.
#'
#' Requires login, please run mol_login(<email_address>)
#' Uses the output from my_jobs()
#'
#' @param annotation_id The annotation id from from my_jobs().
#'
#' @return A data.frame of layers and their statuses, along with the annotation_id, and the dataset_id for the custom annotation.
#' @export
#'
#' @examples
#' \dontrun{
#' job_details(<annotation_id>)
#' }
job_details <- function (annotation_id) {
  res <- get_json('user', 'annotations', annotation_id, simplifyVector = TRUE)
  res$params$title <-  res$name
  res$params$updated <- NULL
  res$params$created <- NULL
  res$params$annotation_id <- res$task_id
  res$params$dataset_id <- res$dataset_id
  res$params
}

#' Download results of a successfully completed custom annotation.
#'
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
  annotation_url <- httr::GET(url, get_auth_header())$url
  tmp_path <- tempfile()
  download_path <- paste0(dir, '/', annotation_id)
  if (!dir.exists(dir)) {
    dir.create(dir)
    message(paste0('Created directory: ', dir))
  }
  if (dir.exists(download_path)) stop('Annotation already downloaded.')
  status <- utils::download.file(annotation_url, tmp_path, mode='wb')
  if (status == 0){
    message('Unzipping')
    utils::unzip(tmp_path, exdir=download_path)
    message(paste0('Annotation available at: ', download_path))
    return(download_path)
  } else {
    stop('There was an error downloading your annotation')
  }
}

#' View species in an annotation
#'
#' Requires login, please run mol_login(<email_address>)
#' Uses the output from my_jobs().
#'
#' @param annotation_id The annotation id from from my_jobs().
#'
#' @return A data.frame, with species and counts in this annotation.
#' @export
#'
#' @examples
#' \dontrun{
#' job_species(<annotation_id>)
#' }
job_species <- function (annotation_id) {
  results <- get_json('user', 'annotations', annotation_id, 'species', simplifyVector = FALSE)
  results <- lapply(results, function(x) {
    count_per_product <- unlist(x$variables)
    counts <- data.frame(
      scientificname = x$scientificname,
      total_occurence_data = x$counts,
      code = internal_to_code(names(count_per_product)),
      annotated = count_per_product
    )
  })
  results <- jsonlite::rbind_pages(results)
  row.names(results) <- c()
  results
}

