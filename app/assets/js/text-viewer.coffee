module("viewer", dependsOn = ["DFF", "ui"]) () ->
  def("show") (dff, canvas) ->
    panel = ui.panel(['panel-default'], DFF.label(dff))
    table = ui.table(['props'], ["property", "value"])
    panel._body.append(table)
    table._props(DFF.prettyProps(dff.props))
    $("#" + canvas).append(panel)

    for nodeId, n of dff.nodes
      name = if n.props["name"]? then n.props["name"] else "node #{nodeId}"
      type = if n.props["$type"]? then n.props["$type"] else "Node"
      nodeLabel =  name + ": " + type

      npanel = ui.panel(['panel-default'], nodeLabel)
      panel._body.append(npanel)
      ntable = ui.table(['props'], ["property", "value"])
      npanel._body.append(ntable)

      ntable._props(DFF.prettyProps(n.props))

