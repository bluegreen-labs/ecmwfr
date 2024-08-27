service <- R6::R6Class(
  "ecmwfr_service",
  cloneable = FALSE,
  public = list(
    initialize = function(request,
                          user,
                          service,
                          url,
                          retry,
                          path = tempdir(),
                          verbose = TRUE) {
      private$user <- user
      private$request <- request
      private$service <- service
      private$path <- path
      private$retry <- retry
      private$file <- file.path(path, request$target)
      private$verbose <- verbose
      private$url <- url
      private$status <- "unsubmitted"
      private$next_retry <- Sys.time()

      return(self)
    },

    print = function(...) {
      request <- capture.output(str(private$request, 1))
      cat("Download request \n")
      cat("  Service: ", private$service, "\n")
      cat("  Status:  ", private$status, "\n")
      cat("  Location:", if (private$downloaded) private$file else "NA", "\n")
      cat("  Request:", request, sep = "\n     ")

      invisible(self)
    },

    exit_message = function(...) {

    intro <- paste(
      "Even after exiting your request is still beeing processed!\n\n"
    )

    options <- paste(
      "- Retry downloading as soon as as completed! \n\n",
      "  If you close your session use the following code: \n\n",
      "  wf_transfer(url = '",
      private$url,
      "',\n   path = '",
      private$path,
      "',\n   filename = '",
      private$file,
      "'\n  )\n\n",
      "- Delete the job upon completion using:\n",
      "  wf_delete(\n   url ='", private$url,"'\n  )\n\n",
      "  If your session stays open you donwload or delete requests using: \n\n",
      "  file$download() and file$delete() *\n\n",
      " [* with file from: file <- wf_request(request)] \n\n",
      sep = ""
    )

    # combine all messages
    exit_msg <- paste(intro, options, sep = "")
    message(sprintf(
      "- Your request has been submitted as a %s request.\n\n  %s",
      toupper(private$service),
      exit_msg
    ))

    },

    submit = function() {
     stop("not implemented")
    },

    update_status = function(fail_is_error = TRUE,
                             verbose = NULL) {
      stop("not implemented")
      },

    download = function(force_redownload = FALSE,
                        fail_is_error = TRUE,
                        verbose = NULL) {
     stop("not implemented")
    },

    transfer = function(time_out = 3600, verbose = NULL) {
      if (private$verbose) {
        message(sprintf("- timeout set to %.1f hours", time_out/3600))
      }

      # set time-out
      time_out <- Sys.time() + time_out

      # Try to download while pending.
      # Quit if timed out
      while (Sys.time() < time_out) {
        self$download()

        if (private$downloaded) {
          break
        }
      }

      if (self$is_pending()) {
        if (private$verbose) {
          # needs to change!
          message("  Your download timed out, however ...\n")
          #self$exit_message()  # TODO
        }
      }
      return(self)

    },

    delete = function() {
      stop("not implemented")
    },

    browse_request = function() {
      stop("not implemented")
    },

    get_file = function() {
      if (private$downloaded) {
        return(private$file)
      } else {
        return(NA)
      }
    },

    get_status = function() {
      private$status
    },

    get_request = function() {
      private$request
    },

    get_url = function() {
      private$url
    },

    is_failed = function() {
      private$failed
    },

    is_success = function() {
      private$downloaded
    },

    is_running = function() {
      private$status == "running"
      # !(self$code == 302)
    },

    is_pending = function() {
      # Always pending, unless it has failed or successfully downloaded.
      !(self$is_failed() | private$downloaded)
    },

    request_id = NA  # For compatibility with old code

  ),
  private = list(
    service = NA,
    request = NA,

    user = NA,

    path = NA,
    file = NA,
    time_out = NA,

    status = NA,
    failed = FALSE,
    code = NA,
    name = NA,
    retry = NA,
    next_retry = NA,
    url = NA,
    file_url = NA,

    verbose = TRUE,
    downloaded = FALSE

  )
)

