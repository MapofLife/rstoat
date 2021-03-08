
get_auth_header <- function () {
  token <-  Sys.getenv('MOL_USER_TOKEN')
  if (token == ""){
    if (keyring::has_keyring_support()) {
      tryCatch(
        {
          token <- keyring::key_get("MOL_USER_TOKEN")
        },
        error = function (e) {
          message(e)
          stop("Could not access the stored Map of Life credentials, please login by running mol_login().")
        }
      )
    } else {
      stop("Please login using mol_login(), and set the MOL_USER_TOKEN environment variable.")
    }
  }
  httr::add_headers(`Authentication-Token` = token)
}

#' @title Map of Life Login
#'
#' @description Login to your Map of Life account.
#'
#' @param email The email address associated with your Map of Life Account.
#' @param password Your map of life password. If left blank, and you are in RStudio you can enter it via a secure popup.
#'
#' @return No return value
#' @export
#'
#' @examples
#' \dontrun{
#' mol_login("your.email@company.com")
#' }
mol_login <- function (email, password = NULL) {
  if (class(email) != "character") stop("Please provide an email.")
  if (is.null(password) & Sys.getenv("RSTUDIO") == "1") {
    password <- rstudioapi::askForPassword("Please enter your password for https://mol.org")
  }
  auth_login_url = build_url('auth/login')
  message("Attempting to log in.")
  # check for env vars

  resp <- get_resp(
    {
      httr::POST(auth_login_url, body = list(
        email = email,
        password = password
      ),  encode = "json", ua())
    })
  # if (is.null(resp)) return(resp)
  parsed <- NULL
  if (!is.null(resp)) {
    parsed <- http_error_handle_parse(resp)
  }

  if (!is.null(parsed)){
    message(parsed$message)
    if (parsed$success) {
      if (keyring::has_keyring_support()) {
        keyring::key_set_with_value("MOL_USER_TOKEN", password = parsed$authtoken)
      } else {
        message('Your system does not support keyring access.\nPlease manually set the environment variable MOL_USER_TOKEN to the following:')
        message(parsed$authtoken)
        message('Setting this environment variable will log you in.')
      }
    } else {
      message("You can sign up for a Map of Life account: https://auth.mol.org/register or reset your password: https://auth.mol.org/reset")
    }
  } else {
    message("You can sign up for a Map of Life account: https://auth.mol.org/register or reset your password: https://auth.mol.org/reset")
  }
}
