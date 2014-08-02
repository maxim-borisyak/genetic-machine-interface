module("showDff", dependsOn = ["utils", "externalview"]) () ->

  defaultViewer = "graph-viewer"

  loadDff = (id) ->
    $.ajax
      url: "/dff/" + id
      dataType: "json"

  $ () ->
    params = utils.getQueryParams()
    id = if params['dff_id']?
      parseInt(params['dff_id'])
    else
      NaN

    if (not id?) or isNaN(id)
      utils.showError("Wrong 'id' url parameter",
                      "Please make sure you enter right url. Current 'id' was recognized as " + params['dff_id'] + ".")
      throw id

    dffF = loadDff(id)
    dffF.fail (jqXHR, textStatus, e) ->
      utils.showError("Data load failure", "Data Flow format <samp>id = #{id}</samp> load failed: #{textStatus}; #{jqXHR.status}: #{e};")
      console.log(e)
      throw e

    dffF.done (dff) ->
      externalview(dff, "dff-view", defaultViewer)
