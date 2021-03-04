
#' @title View datasets
#'
#' @description List logged-in user's uploaded datasets (uploaded to https://mol.org through https://mol.org/upload).
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

#' @title List all jobs
#'
#' @description List logged-in user's past and current annotation jobs.
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

#' @title Retrieve annotation job details
#'
#' @description Get details of a batch annotation job. Requires login, please run mol_login(<email_address>).
#' Uses the output from my_jobs().
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

#' @title View annotation job species
#'
#' @description View the species in a completed annotation and other details. Only works for successfully completed jobs.
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
  do.call(rbind.data.frame, results)
  row.names(results) <- c()
  results
}

