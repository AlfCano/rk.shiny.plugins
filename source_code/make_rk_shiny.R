# make_shiny_package.R
# Este script genera un ÚNICO paquete de RKWard que contiene los TRES plugins
# de Shiny (rpivotTable, ggplotgui, ggquickeda), usando la arquitectura de componentes correcta.

local({
  # =========================================================================================
  # SECCIÓN DE PREPARACIÓN
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  output.dir <- "."
  overwrite <- TRUE
  guess.getter <- FALSE
  rk.set.indent(by = "\t")

  # =========================================================================================
  # DEFINICIÓN DEL PAQUETE (METADATOS GLOBALES)
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
      desc = "Un paquete de plugins de RKWard para lanzar interfaces interactivas de Shiny.",
      version = "1.0.0",
      url = "https://github.com/AlfCano/rk.survey.design", # Puede ser actualizado
      license = "GPL (>= 3)"
    )
  )

  # =========================================================================================
  # DEFINICIÓN DEL COMPONENTE 1: rpivotTable
  # =========================================================================================

  # --- JS para rpivotTable ---
  js_pivot_calculate <- "
    var data_frame = getValue(\"data_slot\");
    echo('result <- rpivotTable(data = ' + data_frame + ')\\n');
  "
  js_pivot_printout <- "
    var object_name = getValue(\"save_pivot.objectname\");
    var workplace = getValue(\"save_pivot.parent\");
    var full_object_name = workplace + '$' + object_name;
    echo('rk.header(\\\"Tabla Dinámica Interactiva\\\")\\n');
    echo('print(result)\\n');
  "

  # --- Diálogo para rpivotTable ---
  pivot_df_selector <- rk.XML.varselector(id.name = "dataframe_source", label = "Objetos en el entorno de trabajo")
  pivot_data_slot <- rk.XML.varslot(id.name = "data_slot", label = "Set de datos (arrastre aquí)", source = "dataframe_source")
  attr(pivot_data_slot, "required") <- "1"
  attr(pivot_data_slot, "classes") <- "data.frame"
  pivot_save_object <- rk.XML.saveobj(label = "Guardar tabla dinámica en", initial = "result", id.name = "save_pivot")
  attr(pivot_save_object, "checkable") <- "false"

  pivot_dialog <- rk.XML.dialog(
    label = "Tabla Dinámica Interactiva (rpivotTable)",
    child = rk.XML.tabbook(
      tabs = list(
        "Configuración" = rk.XML.row(rk.XML.col(pivot_df_selector), rk.XML.col(pivot_data_slot)),
        "Opciones de Salida" = rk.XML.row(rk.XML.col(pivot_save_object))
      )
    )
  )

  # --- Ayuda para rpivotTable ---
  pivot_help <- rk.rkh.doc(
    summary = rk.rkh.summary(text = "Crea una tabla dinámica interactiva a partir de un data.frame seleccionado y la guarda en un objeto de R."),
    usage = rk.rkh.usage(text = "1. Arrastre el data.frame deseado al cajón 'Set de datos'.\n2. En 'Opciones de Salida', asigne un nombre al objeto que contendrá la tabla dinámica.\n3. Ejecute el análisis."),
    sections = list(
        rk.rkh.section(title="Configuración", text="Define el data.frame que se utilizará para crear la tabla.", short="Configuración"),
        rk.rkh.section(title="Opciones de Salida",text="Define el nombre del objeto de R que almacenará la tabla dinámica.", short="Salida")
    ),
    title = rk.rkh.title(text = "rpivotTable")
  )

  # --- Creación del COMPONENTE rpivotTable ---
  rpivotTable_component <- rk.plugin.component(
      "rpivotTable",
      xml = list(dialog = pivot_dialog),
      js = list(require = "rpivotTable", calculate = js_pivot_calculate, printout = js_pivot_printout, results.header = FALSE),
      rkh = list(help = pivot_help),
      hierarchy = list("Shiny", "rpivotTable"),
      provides = c("dialog", "logic")
  )

  # =========================================================================================
  # DEFINICIÓN DEL COMPONENTE 2: ggplot_shiny
  # =========================================================================================

  # --- JS para ggplot_shiny ---
  js_ggplot_calculate <- "
    var data_frame = getValue(\"data_slot\");
    echo('result <- ggplot_shiny(dataset = ' + data_frame + ')\\n');
  "
  js_ggplot_printout <- "
    echo('rk.header(\\\"Lanzando Interfaz de ggplot\\\")\\n');
    echo('print(result)\\n');
  "

  # --- Diálogo para ggplot_shiny ---
  ggplot_df_selector <- rk.XML.varselector(id.name = "dataframe_source", label = "Objetos en el entorno de trabajo")
  ggplot_data_slot <- rk.XML.varslot(id.name = "data_slot", label = "Set de datos (arrastre aquí)", source = "dataframe_source")
  attr(ggplot_data_slot, "required") <- "1"
  attr(ggplot_data_slot, "classes") <- "data.frame"

  ggplot_dialog <- rk.XML.dialog(
    label = "Constructor Interactivo de Gráficos (ggplot)",
    child = rk.XML.row(rk.XML.col(ggplot_df_selector), rk.XML.col(ggplot_data_slot))
  )

  # --- Ayuda para ggplot_shiny ---
  ggplot_help <- rk.rkh.doc(
    summary = rk.rkh.summary(text = "Lanza una interfaz gráfica interactiva (Shiny Gadget) para construir gráficos con la sintaxis de ggplot2."),
    usage = rk.rkh.usage(text = "1. Arrastre el data.frame que desea visualizar al cajón 'Set de datos'.\n2. Ejecute el análisis."),
    sections = list(
        rk.rkh.section(title="Configuración", text="Define el data.frame que se utilizará como base para la creación de gráficos.", short="Configuración")
    ),
    title = rk.rkh.title(text = "ggplot GUI")
  )

  # --- Creación del COMPONENTE ggplot_shiny ---
  ggplot_shiny_component <- rk.plugin.component(
      "ggplot_shiny",
      xml = list(dialog = ggplot_dialog),
      js = list(require = "ggplotgui", calculate = js_ggplot_calculate, printout = js_ggplot_printout, results.header = FALSE),
      rkh = list(help = ggplot_help),
      hierarchy = list("Shiny", "ggplot GUI"),
      provides = c("dialog", "logic")
  )

  # =========================================================================================
  # DEFINICIÓN DEL COMPONENTE 3: ggquickeda
  # =========================================================================================

  # --- JS para ggquickeda ---
  js_ggquickeda_calculate <- "
    var data_frame = getValue(\"data_slot\");
    echo('result <- run_ggquickeda(data = ' + data_frame + ')\\n');
  "
  js_ggquickeda_printout <- "
    echo('rk.header(\\\"Lanzando Interfaz de ggquickeda\\\")\\n');
    echo('print(result)\\n');
  "

  # --- Diálogo para ggquickeda ---
  ggquickeda_df_selector <- rk.XML.varselector(id.name = "dataframe_source", label = "Objetos en el entorno de trabajo")
  ggquickeda_data_slot <- rk.XML.varslot(id.name = "data_slot", label = "Set de datos (arrastre aquí)", source = "dataframe_source")
  attr(ggquickeda_data_slot, "required") <- "1"
  attr(ggquickeda_data_slot, "classes") <- "data.frame"

  ggquickeda_dialog <- rk.XML.dialog(
    label = "Análisis Exploratorio Interactivo (ggquickeda)",
    child = rk.XML.row(rk.XML.col(ggquickeda_df_selector), rk.XML.col(ggquickeda_data_slot))
  )

  # --- Ayuda para ggquickeda ---
  ggquickeda_help <- rk.rkh.doc(
    summary = rk.rkh.summary(text = "Lanza una interfaz gráfica interactiva para el análisis exploratorio de datos."),
    usage = rk.rkh.usage(text = "1. Arrastre el data.frame que desea analizar al cajón 'Set de datos'.\n2. Ejecute el análisis."),
    sections = list(
        rk.rkh.section(title="Configuración", text="Define el data.frame que se utilizará para el análisis.", short="Configuración")
    ),
    title = rk.rkh.title(text = "ggquickeda GUI")
  )

  # --- Creación del COMPONENTE ggquickeda ---
  ggquickeda_component <- rk.plugin.component(
      "ggquickeda",
      xml = list(dialog = ggquickeda_dialog),
      js = list(require = "ggquickeda", calculate = js_ggquickeda_calculate, printout = js_ggquickeda_printout, results.header = FALSE),
      rkh = list(help = ggquickeda_help),
      hierarchy = list("Shiny", "ggquickeda"),
      provides = c("dialog", "logic")
  )

  # =========================================================================================
  # SECCIÓN DE CREACIÓN DEL PAQUETE (LA LLAMADA PRINCIPAL)
  # =========================================================================================
  plugin.dir <- rk.plugin.skeleton(
    about = package_about,
    path = output.dir,
    guess.getter = guess.getter,
    # Se pasa la lista de TODOS los componentes.
    components = list(rpivotTable_component, ggplot_shiny_component, ggquickeda_component),
    pluginmap = list(
        name = "rk.shiny.plugins", # El nombre del .rkmap maestro para el paquete
        po_id = "rk.shiny.plugins"
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    overwrite = overwrite,
    load = TRUE,
    show = FALSE # Como solicitaste, se desactiva la previsualización
  )

  message("¡Archivos del paquete '", package_about@name, "' generados con éxito en '", plugin.dir, "'!")
  message("SIGUIENTE PASO: Abra RKWard, navegue a la carpeta '", plugin.dir, "' y ejecute los siguientes comandos:")
  message("rkwarddev::rk.updatePluginMessages(pluginmap = \"inst/rkward/rk.shiny.plugins.rkmap\", default_po = \"rk.shiny.plugins\")")
  message("devtools::install()")
})
