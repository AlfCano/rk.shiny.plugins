// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(pivottabler)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var df = getValue("pt_data"); var rows = getValue("pt_rows").split("\n"); var cols = getValue("pt_cols").split("\n");
    var meas = getValue("pt_meas"); var wght = getValue("pt_wght"); var func = getValue("pt_func");
    function cleanVar(v) { return v ? v.split(/[\[\"\]]|\$/).filter(Boolean).pop() : ""; }

    echo("pt <- pivottabler::PivotTable$new(); pt$addData(" + df + ")\n");
    rows.forEach(function(r){ var c=cleanVar(r); if(c) echo("pt$addRowDataGroups('" + c + "')\n"); });
    cols.forEach(function(c){ var cl=cleanVar(c); if(cl) echo("pt$addColumnDataGroups('" + cl + "')\n"); });

    var m=cleanVar(meas), w=cleanVar(wght), calc="n()";
    if(func=="n") { calc = wght ? "sum("+w+", na.rm=TRUE)" : "n()"; }
    else if(m) {
        if(func=="sum") calc = wght ? "sum("+m+"*"+w+", na.rm=TRUE)" : "sum("+m+", na.rm=TRUE)";
        else if(func=="mean") calc = wght ? "stats::weighted.mean("+m+", "+w+", na.rm=TRUE)" : "mean("+m+", na.rm=TRUE)";
    }
    echo("pt$defineCalculation(calculationName='Result', summariseExpression='" + calc + "')\n");
    echo("pt$evaluatePivot()\n");
    echo("pt_res <- pt\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("ProfessionalTable results")).print();
echo("rk.header('Professional Pivot Table')\nprint(pt_res$renderPivot())\n");

}

