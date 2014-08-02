module("view", dependsOn = ["ui", "DFF"]) () ->
  setTimeout () ->
    request = (url) ->
      req = $.ajax
        url: url
        dataType: "json"

      req.fail (jqXHR, textStatus, e) ->
        showError(textStatus + ": " + e.stack)

      req

    traverse = (id) -> request("/traverse/" + id)

    traverseNew = () -> request("/traverse_new")

    traverseShort = (id) -> request("/traverse_short/" + id)

    GOTO = (e) ->
      dffId = $(e.currentTarget).attr("dffId")
      location.href = "/show?dff_id=" + dffId

    showError = (e) ->
      al = $('<div class="alert alert-dismissable alert-danger"> </div>')
      al.append($('<button type="button" class="close" data-dismiss="alert">×</button>'))
      al.append($('<h4>Error!</h4>'))
      p = $('<p></p>')
      p.append("<strong>Error: </strong>" + e)
      al.append(p)
      $('#main-panel').prepend(al)

    Status =
      INHERITS: "info"
      EXAMINES: "success"
      INHERITED: "warning"
      SELF: "active"
      NONE: ""

    refresh = (e) ->
      dffId = $(e.currentTarget).attr("dffId")
      traverse(dffId).done(fill)

    connections = (dff, node) ->
      cs = []
      for port, es of node.edges
        for e in es
          cs.push(dff.nodes[e.nodeId])
      cs

    brains = {}
    robots = {}
    metrics = {}

    metricUpdate = () ->
      metric = $('#metric').val()

      for bId of brains
        m = metrics[bId]
        m.removeClass()
        m.empty()
        r = robots[bId]
        if r?
          if r.props[metric]?
            m.append(r.props[metric])
          else
            m.addClass("error")
        else
          m.addClass("warning")


    fill = (dff) ->
      table = $("#main-table")
      table.empty()

      bs = (b for bId, b of dff.nodes when b.props["$label"] == "BRAIN")

      for b in bs
        brains[b.props["$id"]] = b

      rs = (b for bId, b of dff.nodes when b.props["$label"] == "ROBOT")

      for r in rs
        brain = connections(dff, r)[0].props["$id"]
        robots[brain] = r

      for bId, brain of brains
        row = $("<tr></tr>")

        bName = (brain.props["$type"] || "Brain") + " " + bId
        bTd = $("<td><a href='show?dff_id=#{bId}'>#{bName}<a></td>")
        bTd.attr("dffId", bId)
        bTd.on("dblclick", GOTO)
        row.append(bTd)

        if robots[bId]?
          rId = robots[bId].props["$id"]
          rName = (robots[bId].props["$type"] || "Robot") + " " + rId
          rTd = $("<td><a href='show?dff_id=#{rId}'>#{rName}</a></td>")
          rTd.attr("dffId", rId)
          rTd.on("dblclick", GOTO)
          row.append(rTd)
        else
          row.append('<td>None</td>')

        metricTd = $('<td></td>')
        metrics[bId] = metricTd
        row.append(metricTd)

        refreshBtn = $('<button type="button" class="btn btn-default"><span class="glyphicon glyphicon-refresh"></span></button>')
        refreshBtn.click(refresh)
        refreshBtn.attr("dffId", bId)
        el = $('<td></td>')
        el.append(refreshBtn)
        row.append(el)
        table.append(row)

    show = () ->
      traverseNew().done(fill)
      $("#metric").keyup(metricUpdate)

    show()


