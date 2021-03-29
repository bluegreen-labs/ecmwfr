wf_batch_request <- function(request_list,
                             workers = 2,
                             user,
                             path = tempdir(),
                             time_out = 3600,
                             total_timeout = NULL
                             ) {
  list_in_list <- vapply(request_list, is.list, logical(1))

  if (any(!list_in_list)) {
    stop("request_list must be a list of requests")
  }

  N <- length(request_list)
  slots <- as.list(rep(FALSE, workers))
  queue <- request_list
  done  <- list()


  time_out <- repeat_if_one(time_out, N)
  if (missing(user)) user <- NULL

  user <- repeat_if_one(user, N)
  path <- repeat_if_one(path, N)

  if (is.null(total_timeout)) {
    total_timeout <- sum(time_out)/workers
  }

  timeout_time <- Sys.time() + total_timeout

  while (length(done) < length(request_list) & Sys.time() < timeout_time) {
    for (w in seq_along(slots)) {

      # If a slot is free and there's a queue,
      # asign to it the next pending request,
      # remove that request from the queue
      if (isFALSE(slots[[w]]) & length(queue) > 0) {
        slots[[w]] <- wf_request(queue[[1]], user = user[1],
                                 time_out = time_out[1],
                                 path = path[1], transfer = FALSE)
        queue <- queue[-1]
        user <- user[-1]
        time_out <- time_out[-1]
        path <- path[-1]
      }

      # Try to download
      if (!isFALSE(slots[[w]])) {
        slots[[w]]$download()
      }

      # If the slot is not still pending,
      # add the request to the "done" list
      # and free-up the slot
      if (!isFALSE(slots[[w]]) && !slots[[w]]$is_pending()) {
        done <- append(done, slots[[w]])
        slots[[w]] <- FALSE
      }

    }
  }

  unlist(lapply(done, function(x) x$get_file()))
}



repeat_if_one <- function(x, N) {
  if (is.null(x)) {
    return(x)
  }
  if (length(x) == 1) {
    x <- rep(x, N)
  }

  if (length(x) != N) {
    stop(deparse(substitute(x)), " must be a vector of length ", N, " or 1.")
  }
  x
}
