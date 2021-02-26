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
read_output <- function(directory, drop_event_id = TRUE) {
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
