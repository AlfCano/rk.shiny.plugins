// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(esquisse)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated
var df = getValue("esq_data"); echo("esquisse::esquisser(" + df + ")\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Esquisse Plot Builder results")).print();
echo("rk.header(\"Esquisse Launched\")\n");

}

