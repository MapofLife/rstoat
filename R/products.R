
#' @title Retrieve product metadata
#'
#' @description Get information on available products for annotation.
#' Get the spatial and temporal buffer limits for use in when creating a custom annotation.
#'
#' @return A data.frame of spatial and temporal buffer limits
#' @export
#'
#' @examples
#' \dontrun{
#' get_products()
#' }
get_products <- function () {
  prods <- get_json('list', 'products', authenticate=FALSE)
  data.frame(variable = prods$variable$code,
             product  = prods$product$code,
             min_spatial = prods$spatial$min,
             max_spatial = prods$spatial$max,
             min_temporal = prods$temporal$min,
             max_temporal = prods$temporal$max,
             spatial_resolution = prods$resolution$spatial,
             temporal_resolution = prods$resolution$temporal,
             start_date = prods$resolution$start,
             end_date = prods$resolution$end
             )
}
