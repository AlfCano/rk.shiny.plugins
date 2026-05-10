// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(shinypivottabler)\n");	echo("require(shiny)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

      var df = getValue("sp_data");
      if (!df || df === "") { df = "data.frame(Error='No data selected')"; }

      echo("options(shiny.launch.browser = TRUE)\n");
      echo("app_res <<- shiny::shinyApp(\n");
      echo("  ui = shiny::fluidPage(\n");
      echo("    shiny::tags$style('body { background-color: white; }'),\n");
      echo("    shinypivottabler::shinypivottablerUI('piv')\n");
      echo("  ),\n");
      echo("  server = function(input, output, session) {\n");
      echo("    shiny::callModule(module = shinypivottabler::shinypivottabler, id = 'piv', data = " + df + ")\n");
      echo("  }\n");
      echo(")\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Interactive Pivot Table results")).print();

      echo("rk.header('Interactive Pivot Table (Shiny)')\n");
      echo("rk.print('Launching interface in your default web browser...<br><b>To return to RKWard, close the browser tab and press ESC in the R console.</b>')\n");
      echo("shiny::runApp(app_res, launch.browser = TRUE)\n");
  

}

