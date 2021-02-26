
# modis_lst_day_1000_1 -> modis-lst_day-1000-1
# landsat8_evi_30_16   -> landsat8-evi-30-16
internal_to_code <- function(code){
  b = strsplit(code, '_')
  sapply(b, function(a){
    n <- length(a)
    if(n == 4){
      return(paste0(a, collapse = '-'))
    } else {
      return(paste0(c(a[1], # product
                      paste(a[2:3], collapse = '_'), # variable
                      a[4], a[5]), collapse = '-'))
    }
  })
}
