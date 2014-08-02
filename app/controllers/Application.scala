package controllers

import geneticmachine.machine.{GeneticMachine, RemoteView, Neo4jDB}
import play.api._
import play.api.mvc._

object Application extends Controller {

  def index = Action {
    Ok {
      views.html.dff()
    }
  }

  def show = Action {
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