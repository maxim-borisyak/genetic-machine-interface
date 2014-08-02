root = this

viewerProp = "$viewer"
getViewerType = (dff) ->
  if root.DFF?
    DFF.viewer(dff)
  else
    dff.props[viewerProp]

getViewerScript = (viewerType) ->
  $.getScript("assets/js/" + viewerType + ".js")

root.externalview = (dff, container, viewerType) ->
  try
    params = utils.getQueryParams()
    viewerType = params['viewer'] || viewerType || getViewerType(dff)

    viewerF = getViewerScript(viewerType)
    viewerF.fail (jqXHR, textStatus, e) ->
      showError("Script load failure", "script <samp>#{viewerType}</samp> load failed: #{textStatus}; #{jqXHR.status}: #{e};")
      console.log(e)
      throw e

    viewerF.done () ->
      if root.viewer?
        try
          root.viewer.show(dff, container)
        catch e
          utils.showError("Error during script execution", e.stack)
          throw e
      else
        utils.showError("Bad viewer script",
            "Make sure your DataFlowFormat contains valid '$viewer' property and the script (" + viewerType + ".js) " +
            "provides method showDff(dff, container).")
  catch e
    utils.showError("Error during script execution", e.stack)
    throw e