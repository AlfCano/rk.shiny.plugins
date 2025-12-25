local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  plugin_name <- "rk.shiny.plugins"

  if(basename(getwd()) == plugin_name) {
    stop("Please run this script from the parent directory to avoid nested folders.")
  }

  package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "A collection of interactive Shiny interfaces for RKWard.",
      version = "1.1.0",
      url = "https://github.com/AlfCano/rk.shiny.plugins",
      license = "GPL (>= 3)"
    )
  )

  # --- Shared Resources ---
  shared_var_selector <- rk.XML.varselector(id.name = "shared_workspace_selector", label = "Objects in workspace")

  # =========================================================================================
  # VISUALIZATION GROUP
  # Hierarchy: Shiny > Visualization
  # =========================================================================================
  h_viz <- list("Shiny", "Visualization")

  # --- 1. Pivot Table (rpivotTable) [MAIN COMPONENT] ---
  piv_data <- rk.XML.varslot(id.name = "piv_data", label = "Dataset", source = "shared_workspace_selector", classes = "data.frame", required = TRUE)
  piv_rows <- rk.XML.varslot(id.name = "piv_rows", label = "Pre-populate Rows", source = "shared_workspace_selector", multi = TRUE)
  piv_cols <- rk.XML.varslot(id.name = "piv_cols", label = "Pre-populate Cols", source = "shared_workspace_selector", multi = TRUE)
  piv_opts <- rk.XML.col(
      rk.XML.dropdown(label = "Aggregator", id.name = "piv_agg", options = list("Count"=list(val="Count", chk=TRUE), "Sum"=list(val="Sum"), "Average"=list(val="Average"))),
      rk.XML.dropdown(label = "Renderer", id.name = "piv_ren", options = list("Table"=list(val="Table", chk=TRUE), "Heatmap"=list(val="Heatmap"), "Bar Chart"=list(val="Bar Chart"))),
      rk.XML.input(label = "Height", initial = "500px", id.name = "piv_h")
  )
  piv_dialog <- rk.XML.dialog(label = "Interactive Pivot Table", child = rk.XML.tabbook(tabs = list("Data" = rk.XML.row(shared_var_selector, rk.XML.col(piv_data, piv_rows, piv_cols)), "Options" = piv_opts)))

  js_piv_calc <- '
      var df=getValue("piv_data"); var rows=getValue("piv_rows"); var cols=getValue("piv_cols");
      var agg=getValue("piv_agg"); var ren=getValue("piv_ren"); var h=getValue("piv_h");
      function cleanList(lst) { if (!lst) return ""; var arr = (typeof lst === "string") ? [lst] : lst; return "c(" + arr.map(function(x){ return "\\\"" + x.split("$").pop().split("[[").pop().replace(/[\\]\\"]/g, "") + "\\\"" }).join(",") + ")"; }
      var opts = []; opts.push("data=" + df);
      if (rows) opts.push("rows=" + cleanList(rows)); if (cols) opts.push("cols=" + cleanList(cols));
      if (agg != "Count") opts.push("aggregatorName=\\\"" + agg + "\\\"");
      if (ren != "Table") opts.push("rendererName=\\\"" + ren + "\\\"");
      opts.push("height=\\\"" + h + "\\\"");
      echo("rpivot_res <- rpivotTable::rpivotTable(" + opts.join(", ") + ")\\n");
  '
  js_piv_print <- 'echo("rk.header(\\"Interactive Pivot Table\\");\\nprint(rpivot_res)\\n");'


  # --- 2. ggplot GUI (Original ggplotgui) ---
  # UNCHANGED from your snippet
  js_ggplot_calculate <- "
      var data_frame = getValue(\"data_slot\");
      echo('result <- ggplot_shiny(dataset = ' + data_frame + ')\\n');
  "
  js_ggplot_printout <- "
      echo('rk.header(\\\"Launching ggplot Interface\\\")\\n');
      echo('print(result)\\n');
  "
  # Note: I am adapting the ID to match the shared selector to keep the XML clean,
  # but the logic remains identical to your snippet.
  ggplot_data_slot <- rk.XML.varslot(id.name = "data_slot", label = "Dataset (drag here)", source = "shared_workspace_selector", classes = "data.frame", required = TRUE)

  ggplot_dialog <- rk.XML.dialog(
      label = "Interactive Plot Builder (ggplot)",
      child = rk.XML.row(shared_var_selector, rk.XML.col(ggplot_data_slot))
  )
  ggplot_help <- rk.rkh.doc(
      summary = rk.rkh.summary(text = "Launches an interactive GUI to build plots with ggplot2."),
      usage = rk.rkh.usage(text = "Drag the data.frame to the slot and run."),
      sections = list(
          rk.rkh.section(title="Configuration", text="Define the data.frame to use.", short="Configuration")
      ),
      title = rk.rkh.title(text = "ggplot GUI")
  )

  comp_ggplot <- rk.plugin.component(
        "ggplot GUI",
        xml = list(dialog = ggplot_dialog),
        js = list(require = "ggplotgui", calculate = js_ggplot_calculate, printout = js_ggplot_printout, results.header = FALSE),
        rkh = list(help = ggplot_help),
        hierarchy = h_viz,
        provides = c("dialog", "logic")
  )


  # --- 3. Esquisse Plot Builder (New Esquisse) ---
  esq_data <- rk.XML.varslot(id.name = "esq_data", label = "Dataset", source = "shared_workspace_selector", classes = "data.frame", required = TRUE)
  esq_dialog <- rk.XML.dialog(label = "Esquisse (Tableau-style)", child = rk.XML.row(shared_var_selector, rk.XML.col(esq_data)))
  js_esq_calc <- 'var df = getValue("esq_data"); echo("esquisse::esquisser(" + df + ")\\n");'
  js_esq_print <- 'echo("rk.header(\\"Esquisse Launched\\")\\n");'

  comp_esq <- rk.plugin.component("Esquisse Plot Builder", xml=list(dialog=esq_dialog), js=list(require="esquisse", calculate=js_esq_calc, printout=js_esq_print), hierarchy=h_viz)


  # =========================================================================================
  # EXPLORATION GROUP
  # Hierarchy: Shiny > Exploration
  # =========================================================================================
  h_exp <- list("Shiny", "Exploration")

  # --- 4. Automated EDA Report (DataExplorer) ---
  exp_data <- rk.XML.varslot(id.name = "exp_data", label = "Dataset", source = "shared_workspace_selector", classes = "data.frame", required = TRUE)
  exp_dialog <- rk.XML.dialog(label = "Automated Data Report", child = rk.XML.row(shared_var_selector, rk.XML.col(exp_data)))
  js_exp_calc <- 'var df = getValue("exp_data"); echo("DataExplorer::create_report(" + df + ")\\n");'
  js_exp_print <- 'echo("rk.header(\\"Generating DataExplorer Report... check your browser.\\")\\n");'

  comp_exp <- rk.plugin.component("Automated EDA Report", xml=list(dialog=exp_dialog), js=list(require="DataExplorer", calculate=js_exp_calc, printout=js_exp_print), hierarchy=h_exp)

  # --- 5. Quick EDA (ggquickeda) ---
  quick_data <- rk.XML.varslot(id.name = "quick_data", label = "Dataset", source = "shared_workspace_selector", classes = "data.frame", required = TRUE)
  quick_dialog <- rk.XML.dialog(label = "Quick EDA", child = rk.XML.row(shared_var_selector, rk.XML.col(quick_data)))
  js_quick_calc <- 'var df = getValue("quick_data"); echo("ggquickeda::run_ggquickeda(" + df + ")\\n");'
  js_quick_print <- 'echo("rk.header(\\"ggquickeda Launched\\")\\n");'

  comp_quick <- rk.plugin.component("Quick EDA", xml=list(dialog=quick_dialog), js=list(require="ggquickeda", calculate=js_quick_calc, printout=js_quick_print), hierarchy=h_exp)


  # =========================================================================================
  # STATISTICS GROUP
  # Hierarchy: Shiny > Statistics
  # =========================================================================================
  h_stat <- list("Shiny", "Statistics")

  # --- 6. Factoshiny ---
  fact_data <- rk.XML.varslot(id.name = "fact_data", label = "Data or PCA/CA Object", source = "shared_workspace_selector", required = TRUE)
  fact_dialog <- rk.XML.dialog(label = "Factoshiny (Multivariate)", child = rk.XML.row(shared_var_selector, rk.XML.col(fact_data)))
  js_fact_calc <- 'var df = getValue("fact_data"); echo("Factoshiny::Factoshiny(" + df + ")\\n");'
  js_fact_print <- 'echo("rk.header(\\"Factoshiny Launched\\")\\n");'

  comp_fact <- rk.plugin.component("Factoshiny (PCA/CA/MCA)", xml=list(dialog=fact_dialog), js=list(require="Factoshiny", calculate=js_fact_calc, printout=js_fact_print), hierarchy=h_stat)

  # --- 7. Shinystan ---
  stan_obj <- rk.XML.varslot(id.name = "stan_obj", label = "Fitted Model Object (stanreg/brms/mcmc)", source = "shared_workspace_selector", required = TRUE)
  stan_dialog <- rk.XML.dialog(label = "Shinystan Diagnostics", child = rk.XML.row(shared_var_selector, rk.XML.col(stan_obj)))
  js_stan_calc <- 'var obj = getValue("stan_obj"); echo("shinystan::launch_shinystan(" + obj + ")\\n");'
  js_stan_print <- 'echo("rk.header(\\"Shinystan Launched\\")\\n");'

  comp_stan <- rk.plugin.component("Shinystan Diagnostics", xml=list(dialog=stan_dialog), js=list(require="shinystan", calculate=js_stan_calc, printout=js_stan_print), hierarchy=h_stat)


  # =========================================================================================
  # PSYCHOMETRICS GROUP
  # Hierarchy: Shiny > Psychometrics
  # =========================================================================================
  h_psy <- list("Shiny", "Psychometrics")

  # --- 8. ShinyItemAnalysis ---
  sia_text <- rk.XML.text("Click Submit to launch the ShinyItemAnalysis suite.\n(Data can be uploaded inside the app or selected from built-in examples).")
  sia_dialog <- rk.XML.dialog(label = "Shiny Item Analysis", child = rk.XML.col(sia_text))
  js_sia_calc <- 'echo("ShinyItemAnalysis::startShinyItemAnalysis()\\n");'
  js_sia_print <- 'echo("rk.header(\\"ShinyItemAnalysis Launched\\")\\n");'

  comp_sia <- rk.plugin.component("Shiny Item Analysis", xml=list(dialog=sia_dialog), js=list(require="ShinyItemAnalysis", calculate=js_sia_calc, printout=js_sia_print), hierarchy=h_psy)


  # =========================================================================================
  # SKELETON BUILD
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",

    # Define Main Component
    xml = list(dialog = piv_dialog),
    js = list(require = "rpivotTable", calculate = js_piv_calc, printout = js_piv_print),

    # Add ALL components
    components = list(
        comp_ggplot,  # Original (ggplotgui)
        comp_esq,     # New (esquisse)
        comp_exp,
        comp_quick,
        comp_fact,
        comp_stan,
        comp_sia
    ),

    # Define Menu Entry
    pluginmap = list(
        name = "Pivot Table",
        hierarchy = h_viz
    ),

    create = c("pmap", "xml", "js", "desc"),
    overwrite = TRUE,
    load = TRUE,
    show = FALSE
  )

  message("Package 'rk.shiny.plugins' (v1.1.0) generated.")
  message("MENU LOCATION: Top Level 'Shiny' Menu.")
  message("Includes both 'ggplot GUI' and 'Esquisse'.")
})
