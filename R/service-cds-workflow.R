cds_workflow <- R6::R6Class("ecmwfr_cds_workflow", inherit = cds_service,
  private = list(
    http_verb = "PUT",
    request_url = function() {
      sprintf(
        "%s/tasks/services/%s/clientid-%s",
        wf_server(service = "cds"),
        # NOTE THE DIFFERENENT ENDPOINT FOR TOOLBOX EDITOR APPS
        gsub("\\.", "/","tool.toolbox.orchestrator.run_workflow"),
        ecmwfr:::wf_unique_id()
      )
    },
    get_location = function(content) {
      content$result[[1]]$location
    }
  )
)
