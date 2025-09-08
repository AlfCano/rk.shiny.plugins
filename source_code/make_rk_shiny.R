local({
# Golden Rule 1: This R script is the single source of truth.
# It programmatically defines and generates all plugin files.

# --- PRE-FLIGHT CHECK ---
# Stop if the user is accidentally running this inside an existing plugin folder
if(basename(getwd()) == "rk.shiny.plugins") {
  stop("Your current working directory is already 'rk.shiny.plugins'. Please navigate to the parent directory ('..') before running this script to avoid creating a nested folder structure.")
}

# Require "rkwarddev"
require(rkwarddev)
rkwarddev.required("0.08-1")

# --- GLOBAL SETTINGS ---
plugin_name <- "rk.shiny.plugins"

# =========================================================================================
# PACKAGE DEFINITION (GLOBAL METADATA)
# =========================================================================================
package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard plugin package to launch interactive Shiny interfaces.",
      version = "1.0.2",
      url = "https://github.com/AlfCano/rk.survey.design",
      license = "GPL (>= 3)"
    )
)

# =========================================================================================
# COMPONENT DEFINITION 1: rpivotTable (Main Component)
# =========================================================================================

# --- UI Definition for rpivotTable ---

# TAB 1: Configuration
# The varselector MUST have an explicit id.name.
pivot_df_selector <- rk.XML.varselector(id.name = "dataframe_source_id", label = "Objects in workspace")

# All varslots now source from the explicit "dataframe_source_id"
pivot_data_slot <- rk.XML.varslot(id.name = "data_slot", label = "Dataset (drag here)", source = "dataframe_source_id")
attr(pivot_data_slot, "required") <- "1"
attr(pivot_data_slot, "classes") <- "data.frame"

rows_varslot <- rk.XML.varslot(label = "Pre-populate Rows (optional)", source = "dataframe_source_id", id.name="rows_slot")
attr(rows_varslot, "multi") <- "1"

cols_varslot <- rk.XML.varslot(label = "Pre-populate Columns (optional)", source = "dataframe_source_id", id.name="cols_slot")
attr(cols_varslot, "multi") <- "1"

config_tab_content <- rk.XML.row(
    pivot_df_selector,
    rk.XML.col(pivot_data_slot, rows_varslot, cols_varslot)
)


# TAB 2: Options
aggregator_dropdown <- rk.XML.dropdown(label = "Aggregator", id.name = "drp_aggregator", options = list(
    "Count" = list(val = "Count", chk = TRUE), "Sum" = list(val = "Sum"), "Average" = list(val = "Average"),
    "Sum as Fraction of Total" = list(val = "Sum as Fraction of Total"), "Sum as Fraction of Rows" = list(val = "Sum as Fraction of Rows"),
    "Sum as Fraction of Columns" = list(val = "Sum as Fraction of Columns")
))
renderer_dropdown <- rk.XML.dropdown(label = "Renderer", id.name = "drp_renderer", options = list(
    "Table" = list(val = "Table", chk = TRUE), "Table Barchart" = list(val = "Table Barchart"),
    "Heatmap" = list(val = "Heatmap"), "Row Heatmap" = list(val = "Row Heatmap"), "Col Heatmap" = list(val = "Col Heatmap")
))
width_input <- rk.XML.input(label = "Width (e.g., 100% or 800px)", initial = "100%", id.name = "inp_width")
height_input <- rk.XML.input(label = "Height (e.g., 400px)", initial = "400px", id.name = "inp_height")

options_tab_content <- rk.XML.col(aggregator_dropdown, renderer_dropdown, width_input, height_input)

# TAB 3: Output Options
pivot_save_object <- rk.XML.saveobj(
    label = "Save pivot table to",
    initial = "pivot.table.output",
    id.name = "save_pivot"
)
output_tab_content <- rk.XML.row(rk.XML.col(pivot_save_object))

# Assemble the final UI dialog
pivot_dialog <- rk.XML.dialog(
    label = "Interactive Pivot Table (rpivotTable)",
    child = rk.XML.tabbook(
      tabs = list(
        "Configuration" = config_tab_content,
        "Options" = options_tab_content,
        "Output" = output_tab_content
      )
    )
)

# --- Help File Definition for rpivotTable ---
pivot_help <- rk.rkh.doc(
    summary = rk.rkh.summary(text = "Creates an interactive pivot table from a data.frame."),
    usage = rk.rkh.usage(text = "Select a data.frame and optionally pre-populate the rows and columns on the 'Configuration' tab. Further options can be set on the 'Options' tab."),
    sections = list(
        rk.rkh.section(title="Configuration", text="Select the data.frame to use for the pivot table. Once a data.frame is selected, you can also pre-select columns to appear in the rows and columns of the initial pivot table.", short="Configuration"),
        rk.rkh.section(title="Options", text="Select the default Aggregator, Renderer, and specify the width and height of the pivot table widget.", short="Options")
    ),
    title = rk.rkh.title(text = "rpivotTable")
)


# --- JavaScript Logic for rpivotTable ---
# CORRECTED JAVASCRIPT: Handles cases where getValue() returns a single string instead of an array.
js_pivot_calculate <- '
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
        if (fullVarName.indexOf("[[") > -1) { return fullVarName.match(/\\[\\[\\\"(.*?)\\\"\\]\\]/)[1]; }
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
        var row_names = rows_array.map(function(item) { return \'\\"\' + getColumnName(item) + \'\\"\'; }).join(\',\');
        options.push("rows = c(" + row_names + ")");
    }
    if(cols_full){
        var cols_array = Array.isArray(cols_full) ? cols_full : [cols_full];
        var col_names = cols_array.map(function(item) { return \'\\"\' + getColumnName(item) + \'\\"\'; }).join(\',\');
        options.push("cols = c(" + col_names + ")");
    }
    if(aggregator != "Count"){
        options.push("aggregatorName = \\"" + aggregator + "\\"");
    }
    if(renderer != "Table"){
        options.push("rendererName = \\"" + renderer + "\\"");
    }
    options.push("width = \\"" + width + "\\"");
    options.push("height = \\"" + height + "\\"");

    // The final object name must match the saveobj initial argument.
    echo("pivot.table.output <- rpivotTable(" + options.join(", ") + ")\\n");
'

js_pivot_printout <- '
    echo("rk.header(\\"Interactive Pivot Table\\")\\n");
    echo("print(pivot.table.output)\\n");
'

# =========================================================================================
# COMPONENT DEFINITION 2: ggplot_shiny (Additional Component) - UNCHANGED
# =========================================================================================
js_ggplot_calculate <- "
    var data_frame = getValue(\"data_slot\");
    echo('result <- ggplot_shiny(dataset = ' + data_frame + ')\\n');
  "
js_ggplot_printout <- "
    echo('rk.header(\\\"Launching ggplot Interface\\\")\\n');
    echo('print(result)\\n');
  "
ggplot_df_selector <- rk.XML.varselector(id.name = "ggplot_dataframe_source_id", label = "Objects in workspace")
ggplot_data_slot <- rk.XML.varslot(id.name = "data_slot", label = "Dataset (drag here)", source = "ggplot_dataframe_source_id")
attr(ggplot_data_slot, "required") <- "1"
attr(ggplot_data_slot, "classes") <- "data.frame"

ggplot_dialog <- rk.XML.dialog(
    label = "Interactive Plot Builder (ggplot)",
    child = rk.XML.row(rk.XML.col(ggplot_df_selector), rk.XML.col(ggplot_data_slot))
)
ggplot_help <- rk.rkh.doc(
    summary = rk.rkh.summary(text = "Launches an interactive GUI to build plots with ggplot2."),
    usage = rk.rkh.usage(text = "Drag the data.frame to the slot and run."),
    sections = list(
        rk.rkh.section(title="Configuration", text="Define the data.frame to use.", short="Configuration")
    ),
    title = rk.rkh.title(text = "ggplot GUI")
)

ggplot_shiny_component <- rk.plugin.component(
      "ggplot GUI",
      xml = list(dialog = ggplot_dialog),
      js = list(require = "ggplotgui", calculate = js_ggplot_calculate, printout = js_ggplot_printout, results.header = FALSE),
      rkh = list(help = ggplot_help),
      hierarchy = list("Shiny", "ggplot GUI"),
      provides = c("dialog", "logic")
)

# =========================================================================================
# COMPONENT DEFINITION 3: ggquickeda (Additional Component) - UNCHANGED
# =========================================================================================
js_ggquickeda_calculate <- "
    var data_frame = getValue(\"data_slot\");
    echo('result <- run_ggquickeda(data = ' + data_frame + ')\\n');
  "
js_ggquickeda_printout <- "
    echo('rk.header(\\\"Launching ggquickeda Interface\\\")\\n');
    echo('print(result)\\n');
  "
ggquickeda_df_selector <- rk.XML.varselector(id.name = "ggquickeda_dataframe_source_id", label = "Objects in workspace")
ggquickeda_data_slot <- rk.XML.varslot(id.name = "data_slot", label = "Dataset (drag here)", source = "ggquickeda_dataframe_source_id")
attr(ggquickeda_data_slot, "required") <- "1"
attr(ggquickeda_data_slot, "classes") <- "data.frame"

ggquickeda_dialog <- rk.XML.dialog(
    label = "Interactive Exploratory Analysis (ggquickeda)",
    child = rk.XML.row(rk.XML.col(ggquickeda_df_selector), rk.XML.col(ggquickeda_data_slot))
)
ggquickeda_help <- rk.rkh.doc(
    summary = rk.rkh.summary(text = "Launches an interactive GUI for exploratory data analysis."),
    usage = rk.rkh.usage(text = "Drag the data.frame to the slot and run."),
    sections = list(
        rk.rkh.section(title="Configuration", text="Define the data.frame to use.", short="Configuration")
    ),
    title = rk.rkh.title(text = "ggquickeda GUI")
)

ggquickeda_component <- rk.plugin.component(
      "ggquickeda",
      xml = list(dialog = ggquickeda_dialog),
      js = list(require = "ggquickeda", calculate = js_ggquickeda_calculate, printout = js_ggquickeda_printout, results.header = FALSE),
      rkh = list(help = ggquickeda_help),
      hierarchy = list("Shiny", "Quick EDA"),
      provides = c("dialog", "logic")
)

# =========================================================================================
# PACKAGE CREATION (THE MAIN CALL)
# =========================================================================================
plugin.dir <- rk.plugin.skeleton(
    about = package_about,
    path = ".",
    # Define the main component here
    xml = list(dialog = pivot_dialog),
    js = list(require = "rpivotTable", calculate = js_pivot_calculate, printout = js_pivot_printout, results.header = FALSE),
    rkh = list(help = pivot_help),
    provides = c("dialog", "logic"),
    # Pass the list of ADDITIONAL components.
    components = list(ggplot_shiny_component, ggquickeda_component),
    pluginmap = list(
        name = "rpivotTable",
        hierarchy = list("Shiny", "Pivot Table"), # Hierarchy of the main component
        po_id = "rpivotTable"
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    overwrite = TRUE,
    load = TRUE,
    show = FALSE
)

message("Package files for '", package_about@name, "' generated successfully in '", plugin.dir, "'!")
})
