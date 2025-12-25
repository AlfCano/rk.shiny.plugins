// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(rpivotTable)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

      var df = getValue("piv_data");
      var rows = getValue("piv_rows"); var cols = getValue("piv_cols");
      var agg = getValue("piv_agg"); var ren = getValue("piv_ren"); var h = getValue("piv_h");
      
      // Helper to strip RKWard formatting from list
      function cleanList(lst) {
          if (!lst) return "";
          var arr = (typeof lst === "string") ? [lst] : lst;
          return "c(" + arr.map(function(x){ 
              return "\"" + x.split("$").pop().split("[[").pop().replace(/[\]\"]/g, "") + "\"" 
          }).join(",") + ")";
      }

      var opts = [];
      opts.push("data=" + df);
      if (rows) opts.push("rows=" + cleanList(rows));
      if (cols) opts.push("cols=" + cleanList(cols));
      if (agg != "Count") opts.push("aggregatorName=\"" + agg + "\"");
      if (ren != "Table") opts.push("rendererName=\"" + ren + "\"");
      opts.push("height=\"" + h + "\"");

      echo("rpivot_res <- rpivotTable::rpivotTable(" + opts.join(", ") + ")\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Interactive Pivot Table results")).print();
echo("rk.header(\"Interactive Pivot Table\");\nprint(rpivot_res)\n");

}

