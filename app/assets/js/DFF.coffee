module("DFF", dependsOn = ["set"]) () ->

  bigraph = (dff) ->
    graph = {}
    for nId of dff.nodes
      graph[nId] = {}

    for nId, node of dff.nodes
      for port, es of node.edges
        for e in es
          graph[nId][e.nodeId] = true
          graph[e.nodeId][nId] = true

    graph

  graph = (dff) ->
    obj = {}
    for nId of dff.nodes
      obj[nId] = {}

    for nId, node of dff.nodes
      for port, es of node.edges
        for e in es
          obj[nId][e.nodeId] = true

    obj

  filter = (dff, g, predicate) ->
    toDelete = {}
    for n of g
      toDelete[n] = false

    for n of g
      toDelete[n] = not predicate(dff.nodes[n])

    obj = {}

    for n of g
      if not toDelete[n]
        obj[n] = {}
        for m of g[n]
          if not toDelete[m]
            obj[n][m] = true

    obj

  # Breadth First Search algorithm and layout
  bfs = (g, start) ->
    open = [start]
    allNodes = set.Set(id for id of g)
    delete allNodes[start]
    bfs_(g, set.Set(open), set.empty(), [open], allNodes)

  bfs_ = (g, open, closed, levels, allNodes) ->
    wave = []
    for n of open
      for neigh of g[n]
        if not closed[neigh]? and not open[neigh]?
          wave.push(neigh)

    if wave.length > 0
      waveSet = set.Set(wave)
      levels.push(set.pure(waveSet))
      set.without(allNodes, waveSet)
      bfs_(g, waveSet, set.union(open, closed), levels, allNodes)
    else
      closed = set.union(open, closed)
      rest = set.pure(allNodes)
      if rest.length == 0
        levels
      else
        open = [rest[0]]
        delete allNodes[rest[0]]
        levels.push([])
        levels.push(open)

        bfs_(g, set.Set(open), closed, levels, allNodes)

  levelLayout = (levels) ->
    nodes = {}
    dx = 1.0 / levels.length
    for lStr, ns of levels
      level = parseInt(lStr)
      x = level * dx
      dy = 1.0 / (ns.length + 1)
      for nnStr, n of ns
        nn = parseInt(nnStr)
        y = (nn + 1) * dy
        nodes[n] =
          x: x
          y: y

    nodes

  bfsLayout_ = (dff, transform) ->
    levels = bfs(transform(dff), "#{dff.inputNode}")
    levelLayout(levels)

  bfsLayout = (dff) ->
    bfsLayout_(dff, graph)

  bidirectionalBfsLayout = (dff) ->
    bfsLayout_(dff, bigraph)

  circleLayout = (dff) ->
    nodes = {}
    l = (id for id of dff.nodes).length
    for nId of dff.nodes
      n = parseInt(nId)
      nodes[n] =
        x: Math.cos(2 * Math.PI * n / l)
        y: Math.sin(2 * Math.PI * n / l)

    nodes

  label = (dff) ->
    if dff.props["$label"]?
      dff.props["$label"] + (if dff.props["$id"]? then " " + dff.props["$id"] else "")
    else
      "Data Flow Format"

  nodeLabel = (node) ->
    if node.props["$label"]?
      node.props["$label"] + " " + (if node.props["$id"]? then node.props["$id"] else "-1")
    else
      (node.props.name || "node") + ": " + (node.props["$type"] || "Node")

  cut = (s, limit) ->
    if s.length > limit
      s.slice(0, limit - 15) + " ... " + s.slice(-10)
    else
      s

  prettyProps = (props, lineLimit = 80) ->
    obj = {}
    for k, v of props
      if typeof(v) != "object"
        obj[k] = cut(v, lineLimit)
      else
        obj[k] = cut(v.toString(), lineLimit)
    obj

  viewer = (dffOrNode) ->
    props = dffOrNode.props
    if props["$viewer"]?
      props["$viewer"]
    else
      switch props["label"]
        when "ROBOT"
          if props["$type"] == "LABYRINTH" then "labyrinth-viewer" else "graph-viewer"
        when "BRAIN" then "graph-viewer"
        when "TRAVERSE" then "genealogy-view"
        else "graph-viewer"

  def("label") label
  def("nodeLabel") nodeLabel
  def("prettyProps") prettyProps

  def("bigraph") bigraph
  def("graph")
  def("filter") filter

  def("bfs") bfs
  def("levelLayout") levelLayout
  def("bfsLayout") bfsLayout
  def("bidirectionalBfsLayout") bidirectionalBfsLayout
  def("circleLayout") circleLayout

  def("viewer") viewer