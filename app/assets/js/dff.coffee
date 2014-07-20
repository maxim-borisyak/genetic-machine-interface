#
# Utility library for DataFlowFormat
#

root = this

defaultViewer = "labyrinth-viewer"
viewerProp = "$viewer"

loadDff = (id) ->
  $.ajax
    url: "/dff/" + id
    dataType: "json"

getViewerType = (dff) ->
  if dff.props[viewerProp]? then dff.props[viewerProp] else defaultViewer

getViewerScript = (viewerType) ->
  $.getScript("assets/js/" + viewerType + ".js")

showError = (reason, e) ->
  error = $('<pre class="alert alert-danger" role="alert"></pre>')
  $("#dff-view").append error
  error.append '<strong>' + reason + '</strong>: ' + e.stack

root.showError = showError

$ () ->
  console.log(utils)
  params = utils.getQueryParams()
  id = if params['dff_id']?
    parseInt(params['dff_id'])
  else
    NaN

  console.log("With id", id)

  if (not id?) or isNaN(id)
    showError("Wrong 'id' url parameter",
              "Please make sure you enter right url. Current 'id' was recognized as " + params['dff_id'] + ".")

  dffF = loadDff(id)
  dffF.done (dff) ->
    console.log(dff)
    try
      viewerType = getViewerType(dff)
      viewerF = getViewerScript(viewerType)
      viewerF.fail (jqXHR, textStatus, errorThrown) ->
        showError("Script load failure", textStatus + "; " + errorThrown)
        throw errorThrown

      viewerF.done () ->
        if root.showDff?
          try
            root.showDff(dff, "dff-view")
          catch e
            showError("Error during script execution", e)
            throw e
        else
          showError("Bad viewer script",
                    "Make sure your DataFlowFormat contains valid '$viewer' property and the script (" + viewerType + ".js) " +
                    "provides method showDff(dff, container).")
    catch showError
      showError("Error during script execution", showError)