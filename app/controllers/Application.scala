package controllers

import controllers.db.ViewProxy
import geneticmachine.machine.{GeneticMachine, RemoteView, Neo4jDB}
import play.api.mvc._

object Application extends ViewProxy {

  new GeneticMachine(dbPath = "../genetic-machine/genetic-machine-db") with Neo4jDB with RemoteView

  override lazy val masterSystemName: String = "GeneticMachine@127.0.0.1:7778"

  def index = Action {
    Ok {
      views.html.dff()
    }
  }

  def genealogy() = Action {
    Ok {
      views.html.genealogy()
    }
  }

  def experiments = Action {
    Ok {
      views.html.experiment()
    }
  }
}