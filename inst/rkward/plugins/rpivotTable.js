// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(rpivotTable)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    // Load GUI values
    var data_frame = getValue("data_slot");
    var rows_full = getValue("rows_slot");
    var cols_full = getValue("cols_slot");
    var aggregator = getValue("drp_aggregator");
    var renderer = getValue("drp_renderer");
    var width = getValue("inp_width");
    var height = getValue("inp_height");

    // Helper function in JS to extract the pure column name
    function getColumnName(fullVarName) {
        if (!fullVarName) return "";
        if (fullVarName.indexOf("[[") > -1) { return fullVarName.match(/\[\[\"(.*?)\"\]\]/)[1]; }
        else if (fullVarName.indexOf("$") > -1) { return fullVarName.substring(fullVarName.lastIndexOf("$") + 1); }
        else { return fullVarName; }
    }

    // Start building the R command
    var options = new Array();
    options.push("data = " + data_frame);

    // Add optional arguments only if the user provided input.
    if(rows_full){
        // Robustness check: if only one item is selected, getValue() returns a string, not an array.
        // We must convert it to an array before we can use .map().
        var rows_array = Array.isArray(rows_full) ? rows_full : [rows_full];
        var row_names = rows_array.map(function(item) { return '\"' + getColumnName(item) + '\"'; }).join(',');
        options.push("rows = c(" + row_names + ")");
    }
    if(cols_full){
        var cols_array = Array.isArray(cols_full) ? cols_full : [cols_full];
        var col_names = cols_array.map(function(item) { return '\"' + getColumnName(item) + '\"'; }).join(',');
        options.push("cols = c(" + col_names + ")");
    }
    if(aggregator != "Count"){
        options.push("aggregatorName = \"" + aggregator + "\"");
    }
    if(renderer != "Table"){
        options.push("rendererName = \"" + renderer + "\"");
    }
    options.push("width = \"" + width + "\"");
    options.push("height = \"" + height + "\"");

    // The final object name must match the saveobj initial argument.
    echo("pivot.table.output <- rpivotTable(" + options.join(", ") + ")\n");

}

function printout(is_preview){
	// printout the results

    echo("rk.header(\"Interactive Pivot Table\")\n");
    echo("print(pivot.table.output)\n");

	//// save result object
	// read in saveobject variables
	var savePivot = getValue("save_pivot");
	var savePivotActive = getValue("save_pivot.active");
	var savePivotParent = getValue("save_pivot.parent");
	// assign object to chosen environment
	if(savePivotActive) {
		echo(".GlobalEnv$" + savePivot + " <- pivot.table.output\n");
	}

}

