package controllers.db

import common.dataflow._
import geneticmachine.db.drivers.DBDriver
import play.api.mvc._

import common.dataflow.RichDataFlowFormat.enrichDataflow

trait DirectDB extends DBProxy {

  val dbPath: String = "../genetic-machine/genetic-machine-db"

  def withTemporaryDB(dbAction: DBDriver => DataFlowFormat) = Action {
    Ok {
      val graphDB = new geneticmachine.db.drivers.Neo4JDriver(dbPath)
      val result = dbAction(graphDB)
      graphDB.shutdown()
      enrichDataflow(result).toJson
    }
  }

  override def traverse(id: Long) = withTemporaryDB { gDB =>
    gDB.traverse(Some(id), maxTraverseNodes, maxTraverseDepth, traverseRelationShips)
  }

  override def traverseNew() = withTemporaryDB { gDB =>
    gDB.traverse(None, maxTraverseNodes, maxTraverseDepth, traverseRelationShips)
  }

  override def dff(id: Long) = {
    if (id >= 0) {
      withTemporaryDB { gDB =>
        gDB.load(id)
      }
    } else {
      Action {
        Ok {
          enrichDataflow(RichDataFlowFormat.randomDataflow(50, 5)).toJson
        }
      }
    }
  }
}
