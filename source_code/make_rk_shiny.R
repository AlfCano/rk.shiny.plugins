# make_shiny_package.R
# This script generates a SINGLE RKWard package containing all THREE
# Shiny plugins, using the correct component architecture.

local({
  # =========================================================================================
  # PREPARATION SECTION
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  output.dir <- "."
  overwrite <- TRUE
  guess.getter <- FALSE
  rk.set.indent(by = "\t")

  # =========================================================================================
  # PACKAGE DEFINITION (GLOBAL METADATA)
  # =========================================================================================
  package_about <- rk.XML.about(
    name = "rk.shiny.plugins",
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard plugin package to launch interactive Shiny interfaces.",
      version = "1.0.1", # Corrected version
      url = "https://github.com/AlfCano/rk.survey.design",
      license = "GPL (>= 3)"
    )
  )

  # =========================================================================================
  # COMPONENT DEFINITION 1: rpivotTable (Main Component)
  # =========================================================================================
  js_pivot_calculate <- "
    var data_frame = getValue(\"data_slot\");
    echo('result <- rpivotTable(data = ' + data_frame + ')\\n');
  "
  # 'printout' now only handles visible output. Saving is handled by rk.plugin.skeleton.
  js_pivot_printout <- "
    echo('rk.header(\\\"Interactive Pivot Table\\\")\\n');
    echo('print(result)\\n');
  "

  pivot_df_selector <- rk.XML.varselector(id.name = "dataframe_source", label = "Objects in workspace")
  pivot_data_slot <- rk.XML.varslot(id.name = "data_slot", label = "Dataset (drag here)", source = "dataframe_source")
  attr(pivot_data_slot, "required") <- "1"
  attr(pivot_data_slot, "classes") <- "data.frame"

  # Correct saveobj definition
  pivot_save_object <- rk.XML.saveobj(label = "Save pivot table to", initial = "result", id.name = "save_pivot")

  pivot_dialog <- rk.XML.dialog(
    label = "Interactive Pivot Table (rpivotTable)",
    child = rk.XML.tabbook(
      tabs = list(
        "Configuration" = rk.XML.row(rk.XML.col(pivot_df_selector), rk.XML.col(pivot_data_slot)),
        "Output Options" = rk.XML.row(rk.XML.col(pivot_save_object))
      )
    )
  )
  pivot_help <- rk.rkh.doc(
    summary = rk.rkh.summary(text = "Creates a pivot table from a data.frame and saves it to an object."),
    usage = rk.rkh.usage(text = "Drag the data.frame to the slot and assign a name for the output object."),
    sections = list(
        rk.rkh.section(title="Configuration", text="Define the data.frame to use.", short="Configuration")
    ),
    title = rk.rkh.title(text = "rpivotTable")
  )

  # =========================================================================================
  # COMPONENT DEFINITION 2: ggplot_shiny (Additional Component)
  # =========================================================================================
  js_ggplot_calculate <- "
    var data_frame = getValue(\"data_slot\");
    echo('result <- ggplot_shiny(dataset = ' + data_frame + ')\\n');
  "
  js_ggplot_printout <- "
    echo('rk.header(\\\"Launching ggplot Interface\\\")\\n');
    echo('print(result)\\n');
  "
  ggplot_df_selector <- rk.XML.varselector(id.name = "dataframe_source", label = "Objects in workspace")
  ggplot_data_slot <- rk.XML.varslot(id.name = "data_slot", label = "Dataset (drag here)", source = "dataframe_source")
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
      "ggplot_shiny",
      xml = list(dialog = ggplot_dialog),
      js = list(require = "ggplotgui", calculate = js_ggplot_calculate, printout = js_ggplot_printout, results.header = FALSE),
      rkh = list(help = ggplot_help),
      hierarchy = list("Shiny", "ggplot GUI"),
      provides = c("dialog", "logic")
  )

  # =========================================================================================
  # COMPONENT DEFINITION 3: ggquickeda (Additional Component)
  # =========================================================================================
  js_ggquickeda_calculate <- "
    var data_frame = getValue(\"data_slot\");
    echo('result <- run_ggquickeda(data = ' + data_frame + ')\\n');
  "
  js_ggquickeda_printout <- "
    echo('rk.header(\\\"Launching ggquickeda Interface\\\")\\n');
    echo('print(result)\\n');
  "
  ggquickeda_df_selector <- rk.XML.varselector(id.name = "dataframe_source", label = "Objects in workspace")
  ggquickeda_data_slot <- rk.XML.varslot(id.name = "data_slot", label = "Dataset (drag here)", source = "dataframe_source")
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
      hierarchy = list("Shiny", "ggquickeda"),
      provides = c("dialog", "logic")
  )

  # =========================================================================================
  # PACKAGE CREATION (THE MAIN CALL)
  # =========================================================================================
  plugin.dir <- rk.plugin.skeleton(
    about = package_about,
    path = output.dir,
    guess.getter = guess.getter,
    # Define the main component here
    xml = list(dialog = pivot_dialog),
    js = list(require = "rpivotTable", calculate = js_pivot_calculate, printout = js_pivot_printout, results.header = FALSE),
    rkh = list(help = pivot_help),
    provides = c("dialog", "logic"),
    # Pass the list of ADDITIONAL components.
    components = list(ggplot_shiny_component, ggquickeda_component),
    pluginmap = list(
        name = "rk.shiny.plugins",
        hierarchy = list("Shiny", "rpivotTable"), # Hierarchy of the main component
        po_id = "rk.shiny.plugins"
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    overwrite = overwrite,
    load = TRUE,
    show = FALSE
  )

  message("Package files for '", package_about@name, "' generated successfully in '", plugin.dir, "'!")
  message("NEXT STEP: Open RKWard, navigate to the '", plugin.dir, "' folder, and run the following commands:")
  message("rkwarddev::rk.updatePluginMessages(pluginmap = \"inst/rkward/rk.shiny.plugins.rkmap\", default_po = \"rk.shiny.plugins\")")
  message("devtools::install()")
})
