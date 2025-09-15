# Use a base image with R pre-installed. The rocker project provides well-maintained images.
FROM rocker/r-ver:4.3.1

# Install system dependencies as root.
# `libglpk-dev` is for the `igraph` package, `git` and `make` for CmdStan.
RUN apt-get update -qq && apt-get install -y \
    g++ \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libssl-dev \
    libudunits2-dev \
    libgdal-dev \
    pandoc \
    pandoc-citeproc \
    zlib1g-dev \
    git \
    make \
    libglpk-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install renv first, as it's required for the next step.
RUN R -e "install.packages('renv')"

# Install CRAN packages using renv
RUN R -e "renv::install(c('tidyverse', 'arrow', 'brms', 'Rcpp', 'rstan'))"

# Install rstanarm and its dependencies separately using install.packages()
RUN R -e "install.packages('rstanarm')"

# Install cmdstanr from the Stan R-universe repository
RUN R -e "install.packages('cmdstanr', repos = c('https://mc-stan.org/r-packages/', getOption('repos')))"

# Create the directory for CmdStan installation as root
RUN mkdir -p /opt/cmdstan

# Pre-install CmdStan
RUN Rscript -e "cmdstanr::install_cmdstan(dir = '/opt/cmdstan', cores = 2, overwrite = TRUE)"

# Set the CMDSTAN environment variable so cmdstanr can find the installation.
ENV CMDSTAN=/opt/cmdstan

# Switch to the `rstudio` user. This is a best practice for security.
# The base image `rocker/r-ver` already creates this user.
USER rstudio

# Set the working directory for the application
WORKDIR /home/rstudio/project

# Copy your R project files into the container.
# The `--chown` flag ensures the files are owned by the `rstudio` user.
COPY --chown=rstudio:rstudio . /home/rstudio/project

# Define the command to run your R script when the container starts.
CMD ["Rscript", "your_script.R"]
