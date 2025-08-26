// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(ggplotgui)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var data_frame = getValue("data_slot");
    echo('result <- ggplot_shiny(dataset = ' + data_frame + ')\n');
  
}

function printout(is_preview){
	// printout the results

    echo('rk.header(\"Launching ggplot Interface\")\n');
    echo('print(result)\n');
  

}

