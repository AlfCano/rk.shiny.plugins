# rk.shiny.plugins

![Version](https://img.shields.io/badge/Version-1.1.1-orange)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.data.wrangling/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.data.wrangling/actions/workflows/lintr.yml)


## RKWard Shiny Plugins Package and Generator

## Synopsis

This repository contains a single R script, `make_rk_shiny.R`, designed to programmatically generate a complete RKWard plugin package using the `rkwarddev` R package.

The resulting R package, `rk.shiny.plugins`, bundles several interactive data visualization and analysis tools (Shiny apps and HTML widgets) into a single, easy-to-install RKWard extension. The entire development process is encapsulated within the R script, making it reproducible, easy to maintain, and simple to extend with new plugins.

## Features

*   **Programmatic Generation**: The entire plugin structure, including all `.xml`, `.js`, and help files, is generated from a single R script. There is no need to manually edit XML or other plugin files.
*   **Single, Unified Package**: All interactive plugins are bundled into one package for easy distribution and installation.
*   **Categorized Menu Structure**: Plugins are organized logically under a top-level **"Shiny"** menu (Visualization, Exploration, Statistics, Psychometrics).
*   **Extensible by Design**: The component-based architecture makes it straightforward to add new interactive plugins to the package by simply defining a new component in the script.

## Plugins Included

This package currently generates the following plugins, accessible from the **Shiny** menu in RKWard:

### 📊 Visualization
*   **Interactive Pivot Table**: Creates a powerful drag-and-drop pivot table with heatmaps and bar charts. (Depends on `rpivotTable`).
*   **ggplot GUI**: The classic "point-and-click" interface for building `ggplot2` graphics. (Depends on `ggplotgui`).
*   **Esquisse Plot Builder**: A modern, "Tableau-style" drag-and-drop builder for ggplot2. (Depends on `esquisse`).

### 🔍 Exploration
*   **Automated EDA Report**: Automatically generates a complete HTML data profiling report (missing values, correlations, histograms) in one click. (Depends on `DataExplorer`).
*   **Quick EDA**: A comprehensive Shiny gadget for fast exploratory data analysis and filtering. (Depends on `ggquickeda`).

### 📈 Statistics
*   **Factoshiny**: Interactive multivariate analysis (PCA, CA, MCA) with dynamic graph customization and clustering. (Depends on `Factoshiny`).
*   **Shinystan Diagnostics**: Interactive visual diagnostics for Bayesian models (MCMC chains, posterior distributions, R-hat). (Depends on `shinystan`).

### 🧠 Psychometrics
*   **Shiny Item Analysis**: A comprehensive suite for Classical Test Theory (CTT) and Item Response Theory (IRT) analysis. (Depends on `ShinyItemAnalysis`).

## How to Use

Follow these steps to generate, compile, and install the complete plugin package.

### Prerequisites

Ensure you have R, RKWard, and the necessary R packages installed. You can install all required R packages by running this command in your R console:

```{r echo=TRUE, eval=FALSE}
install.packages(c(
  "devtools", "rkwarddev", 
  "rpivotTable", "ggplotgui", "esquisse", 
  "ggquickeda", "DataExplorer", 
  "Factoshiny", "shinystan", "ShinyItemAnalysis"
))
```

#### Troubleshooting: Errors installing `devtools` or missing binary dependencies (Windows)

If you encounter errors mentioning "non-zero exit status", "namespace is already loaded", or requirements for compilation (compiling from source) when installing packages, it is likely because the R version bundled with RKWard is older than the current CRAN standard.

**Workaround:**
Until a new, more recent version of R (current bundled version is 4.3.3) is packaged into the RKWard executable, these issues will persist. To fix this:

1.  Download and install the latest version of R (e.g., 4.5.2 or newer) from [CRAN](https://cloud.r-project.org/).
2.  Open RKWard and go to the **Settings** (or Preferences) menu.
3.  Run the **"Installation Checker"**.
4.  Point RKWard to the newly installed R version.

This "two-step" setup (similar to how RStudio operates) ensures you have access to the latest pre-compiled binaries, avoiding the need for RTools and manual compilation.  

### Installation

If you have installed `RKWard >= 0.7.4`, you can use the install functionality directly from git. As shown here: [Shiny apps on RKWard](https://docs.google.com/presentation/d/1o8Sd197UYkWc4YPAriTVX0oZHVYuxsbB304vPRrbra8/edit?slide=id.g382e8f418b2_0_0#slide=id.g382e8f418b2_0_0)

You just need to add:
*   **User name:** "AlfCano"
*   **Repository:** "rk.shiny.plugins"

Or, just run the next command in your R console:

```{r echo=TRUE, eval=FALSE}
local({
## Prepare
require(devtools)
## Install
  install_github(
    repo="AlfCano/rk.shiny.plugins"
  )
## Print Result
rk.header ("Results of installing from git")
})
```

### Generator

To run the generator script yourself (if modifying the plugins), the `rkwarddev` package is needed.

```{r echo=TRUE, eval=FALSE}
install.packages("rkwarddev")
```

## Author

*   **Alfonso Cano** (alfonso.cano@correo.buap.mx)
*   *Assisted by Gemini, a large language model from Google.*
