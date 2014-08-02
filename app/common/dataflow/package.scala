package common

package object dataflow {
  def randomDataflow(nodeNumber: Int = 100, connections: Int = 10): DataFlowFormat = {
    import scala.util.Random

    val builder = new DataFlowFormatBuilder("Brain")("nodeNumber" -> nodeNumber)("connections" -> connections)
    val input = builder.node("rInput").asInput()
    val output = builder.node("rOutput").asOutput()

    for {
      nodes <- 0 until (nodeNumber - 2)
    } {
      val newNode = builder.node("rnode")
      for {
        _ <- 0 until connections
      } {
        val id = Random.nextInt(nodes + 2)
        val node = builder.node(id)
        if (Random.nextInt(2) == 0) {
          newNode --> node
        } else {
          node --> newNode
        }
      }
    }

    builder.toDataFlowFormat
  }
}