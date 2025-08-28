// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(rpivotTable)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var data_frame = getValue("data_slot");
    echo('result <- rpivotTable(data = ' + data_frame + ')\n');
  
}

function printout(is_preview){
	// printout the results

    echo('rk.header(\"Interactive Pivot Table\")\n');
    echo('print(result)\n');
  
	//// save result object
	// read in saveobject variables
	var savePivot = getValue("save_pivot");
	var savePivotActive = getValue("save_pivot.active");
	var savePivotParent = getValue("save_pivot.parent");
	// assign object to chosen environment
	if(savePivotActive) {
		echo(".GlobalEnv$" + savePivot + " <- result\n");
	}

}

