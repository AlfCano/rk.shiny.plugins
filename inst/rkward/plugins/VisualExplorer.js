// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(GWalkR)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated
var df = getValue("gw_data"); echo("gw_res <- GWalkR::gwalkr(" + df + ")\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Visual Explorer results")).print();
echo("rk.header('GWalkR Visual Explorer'); print(gw_res)\n");

}

