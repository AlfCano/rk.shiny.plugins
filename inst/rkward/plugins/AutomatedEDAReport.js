// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(DataExplorer)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated
var df = getValue("exp_data"); echo("DataExplorer::create_report(" + df + ")\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Automated EDA Report results")).print();
echo("rk.header(\"Generating DataExplorer Report... check your browser.\")\n");

}

