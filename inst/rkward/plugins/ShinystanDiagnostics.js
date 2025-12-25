// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(shinystan)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated
var obj = getValue("stan_obj"); echo("shinystan::launch_shinystan(" + obj + ")\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Shinystan Diagnostics results")).print();
echo("rk.header(\"Shinystan Launched\")\n");

}

