package common

package object dataflow {
  implicit def enrichDataflow(dff: DataFlowFormat): RichDataFlowFormat = new RichDataFlowFormat(dff)
}