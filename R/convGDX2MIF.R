#' Read in GDX from BRICK and write *.mif reporting
#'
#' Read in all information from GDX file that was generated with BRICK and
#' create the *.mif reporting
#'
#' @param gdx file path to a BRICK gdx
#' @param tmpl character, BRICK reporting template. There has to be a brickSets
#'   mapping named with the same suffix: \code{brickSets_<tmpl>.yaml}
#' @param file name of the mif file which will be written, if no name is
#'   provided a magpie object containing all the reporting information is
#'   returned
#' @param scenario scenario name that is used in the *.mif reporting
#' @param t numeric vector of reporting periods (years)
#'
#' @author Robin Hasse
#'
#' @importFrom magclass mbind add_dimension write.report getSets<-
#' @export

convGDX2MIF <- function(gdx, tmpl = NULL, file = NULL, scenario = "default", t = NULL) {

  # PREPARE --------------------------------------------------------------------

  # common time steps
  if (is.null(t)) {
    t <- as.numeric(as.character(readGdxSymbol(gdx, "ttot", asMagpie = FALSE)[[1]]))
  }

  # central object containing all output data
  output <- NULL



  # REPORT VARIABLES -----------------------------------------------------------

  ## Stock ====
  message("running reportBuildingStock ...")
  output <- mbind(output, reportBuildingStock(gdx, tmpl)[, t, ])

  ## Construction ====
  message("running reportConstruction ...")
  output <- mbind(output, reportConstruction(gdx, tmpl)[, t, ])

  ## Demolition ====
  message("running reportDemolition ...")
  output <- mbind(output, reportDemolition(gdx, tmpl)[, t, ])


  # FINISH ---------------------------------------------------------------------

  # Add dimension names "scenario.model.variable"
  getSets(output)[3] <- "variable"
  output <- add_dimension(output, dim = 3.1, add = "model", nm = "BRICK")
  output <- add_dimension(output, dim = 3.1, add = "scenario", nm = scenario)

  # either write the *.mif or return the magpie object
  if (!is.null(file)) {
    write.report(output, file = file, ndigit = 7)
  } else {
    return(output)
  }

}
