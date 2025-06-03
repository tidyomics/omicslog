detect_repo_safe <- function(pkg, cran_pkgs = NULL, bioc_pkgs = NULL) {
  if (is.null(bioc_pkgs)) {
    suppressMessages({
      bioc_pkgs <- BiocManager::available()
    })
  }
  
  if (is.null(cran_pkgs)) {
    repos <- getOption("repos")
    if (is.null(repos) || identical(repos["CRAN"], "@CRAN@")) {
      repos["CRAN"] <- "https://cloud.r-project.org"
      options(repos = repos)
    }
    cran_pkgs <- rownames(available.packages())
  }
  
  if (pkg %in% cran_pkgs) {
    return("cran")
  } else if (pkg %in% bioc_pkgs) {
    return("bioc")
  } else {
    return("other")
  }
}

pkg_to_conda <- function(pkgs) {
  cran_pkgs <- rownames(available.packages())
  bioc_pkgs <- BiocManager::available()
  
  vapply(names(pkgs), function(pkg) {
    version <- as.character(pkgs[[pkg]]$Version)
    src <- detect_repo_safe(pkg, cran_pkgs, bioc_pkgs)
    
    if (src == "cran") {
      sprintf("r-%s=%s", tolower(pkg), version)
    } else if (src == "bioc") {
      sprintf("bioconductor-%s=%s", tolower(pkg), version)
    } else {
      NA_character_
    }
  }, character(1))
}

generate_conda_env_yml <- function(env_name = "r-env", file = "r-environment.yml") {
  pkgs <- sessionInfo()$otherPkgs
  if (is.null(pkgs)) {
    warning("No additional packages found in sessionInfo()$otherPkgs")
    return(invisible(NULL))
  }
  
  conda_specs <- pkg_to_conda(pkgs)
  conda_specs <- conda_specs[!is.na(conda_specs)]
  
  yml <- c(
    paste0("name: ", env_name),
    "channels:",
    "  - conda-forge",
    "  - bioconda",
    "  - defaults",
    "dependencies:",
    paste0("  - ", sort(unique(conda_specs)))
  )
  
  writeLines(yml, file)
  message("YAML environment file written to: ", file)
  invisible(file)
}

generate_dockerfile <- function(path = "Dockerfile",
                                base_image = "continuumio/miniconda3",
                                env_name = "r-env") {
  pkgs <- sessionInfo()$otherPkgs
  if (is.null(pkgs)) {
    warning("No additional packages found in sessionInfo()$otherPkgs")
    return(invisible(NULL))
  }
  
  # Convert to Conda package specs (e.g. r-dplyr=1.1.4)
  conda_specs <- pkg_to_conda(pkgs)
  conda_specs <- conda_specs[!is.na(conda_specs)]
  conda_specs_str <- paste(conda_specs, collapse = " ")
  
  dockerfile <- c(
    paste0("FROM ", base_image),
    "",
    "# Install system libraries required by many R packages",
    "RUN apt-get update && apt-get install -y \\",
    "    libcurl4-openssl-dev \\",
    "    libxml2-dev \\",
    "    libssl-dev && \\",
    "    apt-get clean && rm -rf /var/lib/apt/lists/*",
    "",
    "# Install mamba (optional but faster than conda)",
    "RUN conda install -n base -c conda-forge mamba",
    "",
    paste0("RUN mamba create -n ", env_name,
           " -c conda-forge -c bioconda -y ", conda_specs_str),
    "",
    "# Activate environment in bash sessions",
    "SHELL [\"/bin/bash\", \"-c\"]",
    paste0("RUN echo \"conda activate ", env_name, "\" >> ~/.bashrc"),
    paste0("ENV PATH=/opt/conda/envs/", env_name, "/bin:$PATH"),
    "",
    "CMD [\"R\"]"
  )
  
  writeLines(dockerfile, path)
  message("✅ Dockerfile written to: ", path)
  invisible(path)
}
