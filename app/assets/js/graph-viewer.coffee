module("showDff", dependsOn=[{ module: "sigma", file: "sigma.min.js" }]) () ->
  emptySet = {}

  arrayToSet = (xs) ->
    obj = {}
    for x in xs
      obj[x] = true
    obj

  union = (xs, ys) ->
    zs = {}
    for x of xs
      zs[x] = true
    for y of ys
      zs[y] = true
    zs

  pure = (xs) ->
    acc = []
    for x of xs
      acc.push(x)
    acc

  bfs = (dff, start) ->
    open = [start]
    bfs_(dff, arrayToSet(open), emptySet, [open])

  bfs_ = (dff, open, closed, levels) ->
    wave = []
    for n of open
      node = dff.nodes[n]
      for port, es of node.edges
        for e in es
          neigh = "#{e.nodeId}"
          if not closed[neigh]? and not open[neigh]?
            wave.push(neigh)

    if wave.length > 0
      waveSet = arrayToSet(wave)
      levels.push(pure(waveSet))
      bfs_(dff, waveSet, union(open, closed), levels)
    else
      levels

  bfsLayout = (dff) ->
    console.log(dff)
    levels = bfs(dff, "#{dff.inputNode}")
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

  dffToSigmaGraph = (dff, layout) ->
    Node = (props, id, label, x, y, size = 1, color = "#000") ->
      obj =
        id : id
        label: label
        x: x
        y: y
        size: size
        color: color

      for k, v of props
        obj[k] = v

      obj

    Edge = (props, id, from, portFrom, to, portTo) ->
      obj =
        id: "#{id}>#{from}:#{portFrom}->#{to}:#{portTo}"
        label: "#{from}:#{portFrom}->#{to}:#{portTo}"
        source: from
        target: to

      for k, v of props
        obj[k] = v

      obj

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
      label = "#{props["name"]}: #{props["$type"]}"
      n = Node(props, nodeId, label, x, y)
      graph.nodes.push(n)
      for fromPortId, edges of node.edges
        for edge in edges
          e = Edge({}, fromPortId, nodeId, fromPortId, "#{edge.nodeId}", edge.portN)
          graph.edges.push(e)

    graph

  showDff = (dff, view) ->
    $("#" + view)
      .css("border-style", "solid")
      .css("min-height", "720px")

    s = new sigma(view);
    g = dffToSigmaGraph(dff, bfsLayout)
    for n in g.nodes
      s.graph.addNode n

    for e in g.edges
      s.graph.addEdge e

    s.refresh()

  showDff
