# 17.07.14

window.showDff = (dff, canvas) ->
  txt = JSON.stringify(dff, null, 4)
  code = $("<pre></pre>")
  code.append(txt)
  canvas.append(code)