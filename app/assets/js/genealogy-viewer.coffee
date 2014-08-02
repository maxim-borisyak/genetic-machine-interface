module("viewer", dependsOn = ["DFF", "sigmagraph"]) () ->
  def("show") (dff, view) ->
    outputNode = dff.outputNode

    for k, v of dff.nodes[outputNode].props
      if k[0] != "$"
        dff.props[k] = v

    # No ones connected to outputNode
    delete dff.nodes[outputNode]

    bg = DFF.bigraph(dff)
    brainG = DFF.filter(dff, bg, (n) -> n.props["$label"] != "ROBOT")
    levels = DFF.bfs(brainG, dff.inputNode)
    newLevels = []
    for level in levels
      newLevel = []
      for n in level
        newLevel.push(n)
        for m of bg[n]
          if dff.nodes[m].props["$label"] == "ROBOT"
            newLevel.push(m)
      newLevels.push(newLevel)

    console.log(newLevels)
    console.log(bg)

    lo = () -> DFF.levelLayout(newLevels)
    s = sigmagraph.SigmaView(dff, lo, view)

    onDClick = (e) ->
      id = e.data.node.id
      dffId = dff.nodes[id].props["$id"]
      if dffId?
        location.href = "/show?dff_id="+dffId

    s.bind("doubleClickNode", onDClick)

