// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(ShinyItemAnalysis)\n");
}

function calculate(is_preview){
	// the R code to be evaluated
echo("ShinyItemAnalysis::startShinyItemAnalysis()\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Shiny Item Analysis results")).print();
echo("rk.header(\"ShinyItemAnalysis Launched\")\n");

}

