module("viewer", dependsOn = [{ module : "d3", file : "d3.min.js" }, "ui", "DFF"]) () ->
  Status =
    Occupied: 1
    Free: -1
    Unknown: 0
    Start: 200
    End: 300
    Path: 2

  Colors =
    Occupied: d3.rgb("black")
    Free: d3.rgb("white")
    Unknown: d3.rgb("lightgrey")
    Path: d3.rgb("green")
    Border: d3.rgb(42, 42, 42)
    Start: d3.rgb("red")
    End: d3.rgb("yellow")

  for k of Colors
    Colors[Status[k]] = Colors[k]

  unmerge = (arr, cols) ->
    d3.range(arr.length / cols).map (row) ->
      arr.slice(row * cols, (row + 1) * cols)

  def("show") (dff, container) ->
    obtainData = () ->
      dff.nodes[dff.nodes["#{dff.inputNode}"].edges["0"]["0"].nodeId].props

    data = obtainData()

    matrix = unmerge(data.Labyrinth, data.Cols)

    sX = data.TrajectoryX[0]
    sY = data.TrajectoryY[0]
    matrix["#{sX}"]["#{sY}"] = Status.Start
    eX = data.TrajectoryX[data.TrajectoryX.length - 1]
    eY = data.TrajectoryY[data.TrajectoryX.length - 1]
    matrix["#{eX}"]["#{eY}"] = Status.End

    labPanel = ui.panel(["panel-default"], "Labyrinth", "lab-panel")
    $("#" + container).append(labPanel)

    svg = d3.select("#lab-panel").append("svg")
      .style("min-height", "920px")
      .style("width", "100%")
      .style("margin", "auto")

    info = null

    h = parseInt(svg.style("height"))
    w = parseInt(svg.style("width"))

    cellSize = Math.floor(Math.min(h / (data.Rows + 2), w / (data.Cols + 2)))

    translate = (x, y) ->
      "translate(" + (data.Rows + 2 - x) * cellSize + "," + (y + 1) * cellSize + ")";

    onMouseOver = () ->
      t = d3.select(this)
      x = parseInt(t.attr("row"))
      y = parseInt(t.attr("col"))

      info.transition()
        .duration(100)
        .attr("x", (data.Rows + 2 -x - 1) * cellSize)
        .attr("y", (if y > 2 then y else y + 4) * cellSize)
      #info.attr("transform", translate(x + 0.5, y - 0.5))
      info.text("X: #{t.attr('row')}; Y: #{t.attr('col')}")

    onMouseOut = () ->
      info.text("")

    for row of matrix
      r = parseInt(row)
      for col of matrix[row]
        c = parseInt(col)
        svg.append("rect")
          .attr("transform", translate(r, c))
          .attr("width", cellSize)
          .attr("height", cellSize)
          .attr("row", r)
          .attr("col", c)
          .style("fill", Colors[matrix[row][col]])
          .on("mouseover", onMouseOver)
          .on("mouseout",onMouseOut)

    # borders
    for row of d3.range(0, data.Rows + 2)
      r = parseInt(row)
      svg.append("rect")
        .attr("transform", translate(r - 1, -1))
        .attr("width", cellSize)
        .attr("height", cellSize)
        .style("fill", Colors.Border)

      svg.append("rect")
        .attr("transform", translate(r - 1, data.Cols))
        .attr("width", cellSize)
        .attr("height", cellSize)
        .style("fill", Colors.Border)

    for col of matrix[0]
      c = parseInt(col)
      svg.append("rect")
        .attr("transform", translate(-1, c))
        .attr("width", cellSize)
        .attr("height", cellSize)
        .style("fill", Colors.Border)

      svg.append("rect")
        .attr("transform", translate(data.Rows, c))
        .attr("width", cellSize)
        .attr("height", cellSize)
        .style("fill", Colors.Border)

    Directions =
      North: 0
      West: 1
      South: 2
      East: 3

    Command =
      TurnLeft: 1
      TurnRight: -1
      Forward: 0

    LabyrinthCommand =
      "0": Command.TurnLeft
      "1": Command.TurnRight
      "2": Command.Forward

    turn = (d, c) ->
      t = (d + c) % 4
      if t < 0 then t + 4 else t

    command = (c) -> LabyrinthCommand["#{c}"]

    dir = Directions.North

    s = 0.15 # scale
    o = s * cellSize # zero
    m = 0.5 * cellSize # middle
    e = (1.0 - s) * cellSize # end

    fig =
      "1": "#{o},#{o} #{m},#{e} #{e},#{o}"
      "0": "#{o},#{o} #{o},#{e} #{e},#{m}"
      "3": "#{o},#{e} #{e},#{e} #{m},#{o}"
      "2": "#{o},#{m} #{e},#{o} #{e},#{e}"

    onMouseOverPath = () ->
      t = d3.select(this)
      i = parseInt(t.attr("i"))
      x = parseInt(t.attr("row"))
      y = parseInt(t.attr("col"))
      info.transition()
        .duration(150)
        .attr("x", (data.Rows + 2 -x - 1) * cellSize)
        .attr("y", (y) * cellSize)
      #info.attr("transform", translate(x + 0.5, y - 0.5))
      info.text("X: #{t.attr('row')}; Y: #{t.attr('col')}, #: #{i}")

    for i of data.Commands
      x = data.TrajectoryX[i]
      y = data.TrajectoryY[i]
      c = command(data.Commands[i])
      dir = turn(dir, c)

      svg.append("polygon")
        .attr("i", i)
        .attr("col", y)
        .attr("row", x)
        .attr("points", fig["#{dir}"])
        .attr("transform", translate(x, y))
        .style("fill", Colors.Path)
        .on("mouseover", onMouseOverPath)
        .on("mouseout", onMouseOut)

    info = svg.append("text")
      .style("fill", d3.rgb("red"))
      .style("font-family", 'Ubuntu Mono')
      .style("font-size", '20px')

    # Properties
    propPanel = ui.panel(["panel-default"], "Properties")
    table = ui.table(["props"], ["property", "value"])
    propPanel._body.append(table)

    for k, v of DFF.prettyProps(dff.props)
      table._add([k, v])

    for k, v of DFF.prettyProps(data)
      table._add([k, v])

    $("#" + container).append(propPanel)