module("showGenealogy", dependsOn = ["utils", "externalview"]) () ->
  defaultViewer = "genealogy-viewer"

  traverse = (id) ->
    $.ajax
      url: "/traverse/" + id
      dataType: "json"

  traverseNew = () ->
    $.ajax
      url: "/traverse_new"
      dataType: "json"

  $ () ->
    params = utils.getQueryParams()
    id = if params['dff_id']?
      parseInt(params['dff_id'])
    else
      NaN

    dffF = if (not id?) or isNaN(id) then traverseNew() else traverse(id)

    dffF.fail (jqXHR, textStatus, e) ->
      utils.showError("Genealogy load failure", "Genealogy load failed: #{textStatus}; #{jqXHR.status}: #{e};")
      console.log(e)
      throw e

    dffF.done (dff) ->
      externalview(dff, "dff-view", defaultViewer)