// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(ggquickeda)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var data_frame = getValue("data_slot");
    echo('result <- run_ggquickeda(data = ' + data_frame + ')\n');
  
}

function printout(is_preview){
	// printout the results

    echo('rk.header(\"Lanzando Interfaz de ggquickeda\")\n');
    echo('print(result)\n');
  

}

