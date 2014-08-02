package controllers

import play.api.mvc._

import geneticmachine.machine._
import common.dataflow.DataFlowFormat

import play.api.libs.json._
import common.dataflow.json._

import scala.concurrent.Future

object GeneticMachine extends Controller {

  val geneticMachineUrl = "GeneticMachine@127.0.0.1:7778"
  new GeneticMachine(dbPath = "../genetic-machine/genetic-machine-db") with Neo4jDB with RemoteView

  // Yes, another akka system...
  val viewMachine = new MirrorMachine(geneticMachineUrl, "mirror.conf") with ViewMachine

  import play.api.libs.concurrent.Execution.Implicits._

  private def dffAction(dffFuture: Future[DataFlowFormat]): Action[AnyContent] = Action.async {
    for {
      dff <- dffFuture
      json = Json.toJson(dff)
    } yield Ok { json }
  }

  def traverse(id: Option[Long]): Action[AnyContent] = dffAction {
    viewMachine.traverse(id)
  }

  def dff(id: Long): Action[AnyContent] = dffAction {
    viewMachine.dff(id)
  }

  def traverse(id: Long): Action[AnyContent] = traverse(Some(id))

  def traverseNew(): Action[AnyContent] = traverse(None)

  def about = TODO
}
