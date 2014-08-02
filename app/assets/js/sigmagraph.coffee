module("sigmagraph", dependsOn = ["DFF", "ui"]) () ->

  Colors =
    BRAIN: "#5bc0de"
    ROBOT: "#5cb85c"
    INPUT: "#f0ad4e"
    OUTPUT: "#f0ad4e"
    DEFAULT: "#d9534f"

  Node = (props, id, label, x, y, size = 2, color = undefined) ->
    c =
      if (not color?)
        if props["$label"]?
          Colors[props["$label"]] || Colors.DEFAULT
        else
          Colors.DEFAULT
      else
        color

    obj =
      id : id
      label: label
      x: x
      y: y
      size: size
      color: c

    for k, v of props
      obj[k] = v

    obj

  Edge = (props, id, from, portFrom, to, portTo) ->
    obj =
      id: "#{id}>#{from}:#{portFrom}->#{to}:#{portTo}"
      label: "#{from}:#{portFrom}->#{to}:#{portTo}"
      source: from
      target: to
      color: "#ec5148"

    for k, v of props
      obj[k] = v

    obj

  Graph = (dff, layout) ->
    coords = layout(dff)

    graph =
      nodes: []
      edges: []

    for nodeId, node of dff.nodes
      x = coords["#{nodeId}"].x
      y = coords["#{nodeId}"].y
      props = node.props
      props["inputs"] = node.inputs
      props["outputs"] = node.outputs

      label =  DFF.nodeLabel(node)

      n = Node(props, nodeId, label, x, y)
      graph.nodes.push(n)
      for fromPortId, edges of node.edges
        for edge in edges
          e = Edge({}, fromPortId, nodeId, fromPortId, "#{edge.nodeId}", edge.portN)
          graph.edges.push(e)

    graph

  SigmaView = (dff, layout, view) ->
    dffLabel = DFF.label(dff)

    panel = ui.panel(["panel-default"], dffLabel, "dff-panel")
    $("#" + view).append(panel)
    panel._body.css("min-height", "720px")

    s = new sigma("dff-panel");
    g = sigmagraph.Graph(dff, layout)

    for n in g.nodes
      s.graph.addNode(n)

    for e in g.edges
      s.graph.addEdge(e)

    s.refresh()

    propsPanel = ui.panel(['panel-default'], "", "node-props")
    propsTable = ui.table(["props"], ["property", "value"])

    propsPanel._body.append(propsTable)

    $("#" + view).append(propsPanel)

    nodeClick = (e) ->
      id = e.data.node.id
      label = if dff.nodes[id].props['$id']?
        ref_id = dff.nodes[id].props['$id']
        '<a href="/show?dff_id=' + ref_id + '">' + e.data.node.label + "</a>"
      else
        e.data.node.label + " properties"

      propsPanel._title(label)
      propsTable._props(DFF.prettyProps(dff.nodes[id].props))

    stageClick = () ->
      propsPanel._title(dffLabel + " properties")
      propsTable._props(DFF.prettyProps(dff.props))

    s.bind("clickNode", nodeClick)
    s.bind("clickStage", stageClick)

    stageClick()
    s


  def("Graph") Graph
  def("SigmaView") SigmaView
  def("Node") Node
  def("Edge") Edge