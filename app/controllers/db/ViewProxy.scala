package controllers.db

import common.MessageProtocol
import common.ViewProtocol
import common.dataflow.DataFlowFormat
import common.dataflow.RichDataFlowFormat._
import play.api.mvc._
import scala.concurrent.Future
import scala.concurrent.duration._
import play.libs.Akka.system

import akka.pattern.ask

import scala.pickling._
import binary._

trait ViewProxy extends DBProxy {
  val askTimeout = 6.second
  val masterSystemName: String

  implicit val dispatcher = system().dispatcher

  def dffAction(dffFuture: Future[DataFlowFormat]): Action[AnyContent] = Action.async {
    for {
      dff <- dffFuture
      json = enrichDataflow(dff).toJson
    } yield Ok { json }
  }

  def traverseProxy(request: BinaryPickle): Action[AnyContent] = dffAction {
    val remoteView = system().actorSelection(s"akka.tcp://$masterSystemName/user/view")

    for {
      pickled <- remoteView.ask(request)(askTimeout).mapTo[BinaryPickle]
      ViewProtocol.Traversed(dff) = pickled.unpickle[ViewProtocol.Traversed]
    } yield dff
  }

  override def traverse(startId: Long) = traverseProxy {
    ViewProtocol.Traverse(Some(startId), maxTraverseNodes, maxTraverseDepth).pickle
  }

  override def traverseNew() = traverseProxy {
    ViewProtocol.Traverse(None, maxTraverseNodes, maxTraverseDepth).pickle
  }

  def dff(id: Long) = dffAction {
    val remoteView = system().actorSelection(s"akka.tcp://$masterSystemName/user/view")
    val req = ViewProtocol.GetDFF(id).pickle
    for {
      pickled <- remoteView.ask(req)(askTimeout).mapTo[BinaryPickle]
      ViewProtocol.DFF(dff) = pickled.unpickle[ViewProtocol.DFF]
    } yield dff
  }
}
