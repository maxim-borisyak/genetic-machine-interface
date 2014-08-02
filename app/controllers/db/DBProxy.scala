package controllers.db

import common.dataflow.DataFlowFormat
import play.api.mvc._

trait DBProxy extends Controller {

  val maxTraverseNodes = 1024
  val maxTraverseDepth = 1024
  val traverseRelationShips = Seq(DataFlowFormat.parentRelation, DataFlowFormat.experimentRelation)

  def traverse(startId: Long): Action[AnyContent]

  def traverseNew(): Action[AnyContent]

  def dff(id: Long): Action[AnyContent]
}
