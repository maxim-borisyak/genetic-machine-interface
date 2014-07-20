package controllers

import play.api._
import play.api.mvc._
import common.dataflow._
import play.api.libs.json._

object Application extends Controller {

  def index = Action {
    Ok {
      views.html.index {
        Json.prettyPrint {
          enrichDataflow(DataFlowFormat.sample).toJson
        }
      }
    }
  }

  def dff(id: Long) = Action {
    Ok {
      val gDB = new geneticmachine.db.drivers.Neo4JDriver("../genetic-machine/genetic-machine-db")
      val response = enrichDataflow(gDB.load(id)).toJson
      gDB.shutdown()
      response
    }
  }
}