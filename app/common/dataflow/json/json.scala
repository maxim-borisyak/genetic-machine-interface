package common.dataflow

import common.dataflow.DataFlowFormat.{Node, Port}
import play.api.libs.json._

package object json {
  private def anyToJson(value: Any): JsValue = value match {
    case s: String => JsString(s)
    case n: Int => JsNumber(n)
    case l: Long => JsNumber(l)
    case d: Double => JsNumber(d)

    case cs: Array[Char] => JsString(new String(cs))

    case xs: Array[_] => JsArray {
      xs.map(anyToJson)
    }

    case xs: TraversableOnce[_] => JsArray {
      xs.map(anyToJson).toSeq
    }

    case b: Boolean => JsBoolean(b)
    case b: Byte => JsNumber(b)
    case f: Float => JsNumber(f)
    case c: Char => JsString(c.toString)
    case v => Json.parse(v.toString)
  }

  private def withIndex[T](xs: Seq[T]): Seq[(Int, T)] = {
    xs.zipWithIndex.map { vi => vi.swap }
  }

  private def indexedJsObj[T : Writes](xs: Seq[T]) = JsObject {
    withIndex(xs).map { iv =>
      iv._1.toString -> Json.toJson[T](iv._2)
    }
  }

  implicit val propsWrite = new Writes[Map[String, Any]] {
    def writes(props: Map[String, Any]) = JsObject {
      val jsProps = for {
        (k, v) <- props
      } yield (k, anyToJson(v))

      jsProps.toSeq
    }
  }

  implicit val portWrites = new Writes[Port] {
    def writes(port: Port) = Json.obj(
      "nodeId" -> port.nodeId,
      "portN" -> port.portN
    )
  }

  implicit val nodeWrites = new Writes[Node] {
    def writes(node: Node) = Json.obj(
      "inputs" -> node.inputs,
      "outputs" -> node.outputs,
      "props" -> Json.toJson(node.props),
      "edges" -> Json.toJson(indexedJsObj(node.edges))
    )
  }

  implicit val dffWrites = new Writes[DataFlowFormat] {
    def writes(dff: DataFlowFormat) = Json.obj(
      "props" -> Json.toJson(dff.props),
      "relations" -> Json.toJson(dff.relations),
      "inputNode" -> dff.inputNodeId,
      "outputNode" -> dff.outputNodeId,
      "nodes" -> Json.toJson(indexedJsObj(dff.nodes))
    )
  }

  def toJson(dff: DataFlowFormat): JsValue = Json.toJson(dff)
}
