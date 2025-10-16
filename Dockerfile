# R + RStudio Server
FROM rocker/rstudio:4.3.1

# System deps for tidyverse, rstan/rstanarm/cmdstanr, sf/arrow, etc.
USER root
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    g++ \
    gfortran \
    make \
    git \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libssl-dev \
    libudunits2-dev \
    libgdal-dev \
    zlib1g-dev \
    pandoc \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# R packages (install to site-library so both root/rstudio see them)
RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org')" \
 && R -e "install.packages(c('tidyverse','arrow','brms','Rcpp','rstan'), repos = 'https://cloud.r-project.org')" \
 && R -e "install.packages('rstanarm', repos = 'https://cloud.r-project.org')" \
 && R -e "install.packages('cmdstanr', repos = c('https://mc-stan.org/r-packages/', getOption('repos')))"

# Pre-install CmdStan (faster cold start). Put in a world-readable location.
RUN mkdir -p /opt/cmdstan \
 && R -e "cmdstanr::install_cmdstan(dir='/opt/cmdstan', cores=2, overwrite=TRUE)"

# Let cmdstanr find it by default
ENV CMDSTAN=/opt/cmdstan

# App workspace
USER rstudio
WORKDIR /home/rstudio/project

# Copy your project (adjust path as needed)
COPY --chown=rstudio:rstudio . /home/rstudio/project

# EXPOSE is informational; Railway uses $PORT. Keep it for clarity.
EXPOSE 8787

# Start RStudio Server on the port Railway assigns.
# Auth: set PASSWORD as a Railway secret. Example: PASSWORD=<strong-secret>
# Default user is 'rstudio' (already created by rocker/rstudio).
USER root
CMD ["/usr/lib/rstudio-server/bin/rserver", \
     "--server-daemonize=0", \
     "--server-user=rstudio", \
     "--www-port=${PORT}"]

