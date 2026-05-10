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
      version = "1.2.0",
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

  # --- 1A. Interactive Pivot Table (shinypivottabler)[MAIN COMPONENT] ---
  sp_data <- rk.XML.varslot(id.name = "sp_data", label = "Dataset", source = "shared_workspace_selector", classes = "data.frame", required = TRUE)
  sp_dialog <- rk.XML.dialog(
    label = "Interactive Pivot Table (Shiny)",
    child = rk.XML.row(shared_var_selector, rk.XML.col(sp_data, rk.XML.text("This will launch the Interactive Pivot Table in your external web browser for maximum stability.")))
  )

  js_sp_calc <- '
      var df = getValue("sp_data");
      if (!df || df === "") { df = "data.frame(Error=\'No data selected\')"; }

      echo("options(shiny.launch.browser = TRUE)\\n");
      echo("app_res <<- shiny::shinyApp(\\n");
      echo("  ui = shiny::fluidPage(\\n");
      echo("    shiny::tags$style(\'body { background-color: white; }\'),\\n");
      echo("    shinypivottabler::shinypivottablerUI(\'piv\')\\n");
      echo("  ),\\n");
      echo("  server = function(input, output, session) {\\n");
      echo("    shiny::callModule(module = shinypivottabler::shinypivottabler, id = \'piv\', data = " + df + ")\\n");
      echo("  }\\n");
      echo(")\\n");
  '
  js_sp_print <- '
      echo("rk.header(\'Interactive Pivot Table (Shiny)\')\\n");
      echo("rk.print(\'Launching interface in your default web browser...<br><b>To return to RKWard, close the browser tab and press ESC in the R console.</b>\')\\n");
      echo("shiny::runApp(app_res, launch.browser = TRUE)\\n");
  '

  # --- 1B. Professional Pivot Table (pivottabler) ---
  piv_data <- rk.XML.varslot(id.name = "pt_data", label = "Dataset", source = "shared_workspace_selector", classes = "data.frame", required = TRUE)
  piv_rows <- rk.XML.varslot(id.name = "pt_rows", label = "Rows (Categorical)", source = "shared_workspace_selector", multi = TRUE, required = TRUE)
  piv_cols <- rk.XML.varslot(id.name = "pt_cols", label = "Columns (Categorical)", source = "shared_workspace_selector", multi = TRUE)
  piv_meas <- rk.XML.varslot(id.name = "pt_meas", label = "Measure (Continuous/Numeric)", source = "shared_workspace_selector", multi = FALSE)
  piv_wght <- rk.XML.varslot(id.name = "pt_wght", label = "Weight variable (Optional)", source = "shared_workspace_selector", multi = FALSE)
  piv_func <- rk.XML.dropdown(label = "Function", id.name = "pt_func", options = list("Count"=list(val="n", chk=TRUE), "Sum"=list(val="sum"), "Mean"=list(val="mean")))

  piv_tab_dialog <- rk.XML.dialog(label = "Professional Table (Static)", child = rk.XML.tabbook(tabs = list(
      "Variables" = rk.XML.row(shared_var_selector, rk.XML.col(piv_data, piv_rows, piv_cols)),
      "Aggregation" = rk.XML.col(piv_meas, piv_func, piv_wght))))

  js_pt_calc <- '
    var df = getValue("pt_data"); var rows = getValue("pt_rows").split("\\n"); var cols = getValue("pt_cols").split("\\n");
    var meas = getValue("pt_meas"); var wght = getValue("pt_wght"); var func = getValue("pt_func");
    function cleanVar(v) { return v ? v.split(/[\\[\\"\\]]|\\$/).filter(Boolean).pop() : ""; }

    echo("pt <- pivottabler::PivotTable$new(); pt$addData(" + df + ")\\n");
    rows.forEach(function(r){ var c=cleanVar(r); if(c) echo("pt$addRowDataGroups(\'" + c + "\')\\n"); });
    cols.forEach(function(c){ var cl=cleanVar(c); if(cl) echo("pt$addColumnDataGroups(\'" + cl + "\')\\n"); });

    var m=cleanVar(meas), w=cleanVar(wght), calc="n()";
    if(func=="n") { calc = wght ? "sum("+w+", na.rm=TRUE)" : "n()"; }
    else if(m) {
        if(func=="sum") calc = wght ? "sum("+m+"*"+w+", na.rm=TRUE)" : "sum("+m+", na.rm=TRUE)";
        else if(func=="mean") calc = wght ? "stats::weighted.mean("+m+", "+w+", na.rm=TRUE)" : "mean("+m+", na.rm=TRUE)";
    }
    echo("pt$defineCalculation(calculationName=\'Result\', summariseExpression=\'" + calc + "\')\\n");
    echo("pt$evaluatePivot()\\n");
    echo("pt_res <- pt\\n");
  '
  js_pt_print <- 'echo("rk.header(\'Professional Pivot Table\')\\nprint(pt_res$renderPivot())\\n");'
  comp_pt <- rk.plugin.component("Professional Pivot Table", xml=list(dialog=piv_tab_dialog), js=list(require="pivottabler", calculate=js_pt_calc, printout=js_pt_print), hierarchy=h_viz)

  # --- 1C. Visual Explorer (GWalkR) ---
  gw_data <- rk.XML.varslot(id.name = "gw_data", label = "Dataset", source = "shared_workspace_selector", classes = "data.frame", required = TRUE)
  gw_dialog <- rk.XML.dialog(label = "Visual Explorer (GWalkR)", child = rk.XML.row(shared_var_selector, rk.XML.col(gw_data)))
  js_gw_calc <- 'var df = getValue("gw_data"); echo("gw_res <- GWalkR::gwalkr(" + df + ")\\n");'
  js_gw_print <- 'echo("rk.header(\'GWalkR Visual Explorer\'); print(gw_res)\\n");'
  comp_gw <- rk.plugin.component("Visual Explorer", xml=list(dialog=gw_dialog), js=list(require="GWalkR", calculate=js_gw_calc, printout=js_gw_print), hierarchy=h_viz)

  # --- 2. ggplot GUI ---
  ggplot_data_slot <- rk.XML.varslot(id.name = "data_slot", label = "Dataset", source = "shared_workspace_selector", classes = "data.frame", required = TRUE)
  ggplot_dialog <- rk.XML.dialog(label = "Interactive Plot Builder (ggplot)", child = rk.XML.row(shared_var_selector, rk.XML.col(ggplot_data_slot)))
  js_ggplot_calc <- "var df = getValue('data_slot'); echo('result <- ggplotgui::ggplot_shiny(dataset = ' + df + ')\\n');"
  js_ggplot_print <- "echo('rk.header(\"Launching ggplot Interface\")\\n'); echo('print(result)\\n');"
  comp_ggplot <- rk.plugin.component("ggplot GUI", xml=list(dialog=ggplot_dialog), js=list(require="ggplotgui", calculate=js_ggplot_calc, printout=js_ggplot_print), hierarchy=h_viz)

  # --- 3. Esquisse Plot Builder ---
  esq_data <- rk.XML.varslot(id.name = "esq_data", label = "Dataset", source = "shared_workspace_selector", classes = "data.frame", required = TRUE)
  esq_dialog <- rk.XML.dialog(label = "Esquisse (Tableau-style)", child = rk.XML.row(shared_var_selector, rk.XML.col(esq_data)))
  js_esq_calc <- 'var df = getValue("esq_data"); echo("esquisse::esquisser(" + df + ")\\n");'
  js_esq_print <- 'echo("rk.header(\\"Esquisse Launched\\")\\n");'
  comp_esq <- rk.plugin.component("Esquisse Plot Builder", xml=list(dialog=esq_dialog), js=list(require="esquisse", calculate=js_esq_calc, printout=js_esq_print), hierarchy=h_viz)


  # =========================================================================================
  # EXPLORATION GROUP
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
  # =========================================================================================
  h_stat <- list("Shiny", "Statistics")

  # --- 6. Factoshiny ---
  fact_data <- rk.XML.varslot(id.name = "fact_data", label = "Data or PCA/CA Object", source = "shared_workspace_selector", required = TRUE)
  fact_dialog <- rk.XML.dialog(label = "Factoshiny (Multivariate)", child = rk.XML.row(shared_var_selector, rk.XML.col(fact_data)))
  js_fact_calc <- 'var df = getValue("fact_data"); echo("Factoshiny::Factoshiny(" + df + ")\\n");'
  js_fact_print <- 'echo("rk.header(\\"Factoshiny Launched\\")\\n");'
  comp_fact <- rk.plugin.component("Factoshiny", xml=list(dialog=fact_dialog), js=list(require="Factoshiny", calculate=js_fact_calc, printout=js_fact_print), hierarchy=h_stat)

  # --- 7. Shinystan ---
  stan_obj <- rk.XML.varslot(id.name = "stan_obj", label = "Fitted Model Object", source = "shared_workspace_selector", required = TRUE)
  stan_dialog <- rk.XML.dialog(label = "Shinystan Diagnostics", child = rk.XML.row(shared_var_selector, rk.XML.col(stan_obj)))
  js_stan_calc <- 'var obj = getValue("stan_obj"); echo("shinystan::launch_shinystan(" + obj + ")\\n");'
  js_stan_print <- 'echo("rk.header(\\"Shinystan Launched\\")\\n");'
  comp_stan <- rk.plugin.component("Shinystan Diagnostics", xml=list(dialog=stan_dialog), js=list(require="shinystan", calculate=js_stan_calc, printout=js_stan_print), hierarchy=h_stat)


  # =========================================================================================
  # PSYCHOMETRICS GROUP
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

    # 1. Main Component
    xml = list(dialog = sp_dialog),
    js = list(require = c("shinypivottabler", "shiny"), calculate = js_sp_calc, printout = js_sp_print),

    # 2. Sub-components (Names restored with spaces)
    components = list(
        comp_pt,
        comp_gw,
        comp_ggplot,
        comp_esq,
        comp_exp,
        comp_quick,
        comp_fact,
        comp_stan,
        comp_sia
    ),

    # 3. Entry point name
    pluginmap = list(
        name = "Interactive Pivot Table",
        hierarchy = h_viz
    ),

    create = c("pmap", "xml", "js", "desc"),
    overwrite = TRUE,
    load = TRUE,
    show = FALSE
  )

  message("================================================================")
  message("Package 'rk.shiny.plugins' (v1.2.0) generated successfully.")
  message("-> All menu names have been restored with spaces for better UI.")
  message("-> You can safely ignore 'For file names... was renamed to' warnings.")
  message("================================================================")
})
