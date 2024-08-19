ads_beta_service <- R6::R6Class("ecmwfr_ads_beta", inherit = cds_beta_service,
  public = list(
    submit = function() {
      if (private$status != "unsubmitted") {
        return(self)
      }

      # get key
      key <- wf_get_key(
        user = private$user,
        service = private$service
      )

      #  get the response for the query provided
      response <- httr::VERB(
        private$http_verb,
        private$request_url(),
        httr::add_headers(
          "PRIVATE-TOKEN" = key
        ),
        body = private$request,
        encode = "json"
      )

      # trap general http error
      if (httr::http_error(response)) {
        stop(httr::content(response),
             call. = FALSE
        )
      }

      # grab content, to look at the status
      # and code
      ct <- httr::content(response)
      ct$code <- httr::status_code(response)

      # some verbose feedback
      if (private$verbose) {
        message("- staging data transfer at url endpoint or request id:")
        message("  ", ct$jobID, "\n")
      }

      private$status <- ct$status
      private$code <- ct$code
      private$name <- ct$jobID
      private$next_retry <- Sys.time() + private$retry
      private$url <- wf_server(id = ct$jobID, service = "cds_beta")

      return(self)
    }
  ),
  private = list(
    service = "ads"
  )
)

