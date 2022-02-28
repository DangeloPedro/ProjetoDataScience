FROM rocker/tidyverse:4.0.0


RUN R -e 'install.packages("basedosdados")'
RUN R -e 'install.packages("zoo")'
RUN R -e 'install.packages("reshape2")'
RUN R -e 'install.packages("sf")'
RUN R -e 'install.packages("geobr")'
RUN R -e 'install.packages("ggplot2")'
RUN R -e 'install.packages("lubridate")'
RUN R -e 'install.packages("devtools")'

RUN install2.r -r http://bioconductor.org/packages/3.0/bioc --deps TRUE \
    phyloseq \
    && rm -rf /tmp/downloaded_packages/

FROM rocker/r-ubuntu:18.04   

# Install required libraries -- using prebuild binaries where available
RUN apt-get update && apt-get install -y \
    git \
    r-cran-data.table \
    r-cran-devtools \
    r-cran-doparallel \
    r-cran-dygraphs \
    r-cran-foreach \
    r-cran-fs \
    r-cran-future.apply \
    r-cran-gh \
    r-cran-git2r \
    r-cran-igraph \
    r-cran-memoise \
    r-cran-microbenchmark \
    r-cran-png \
    r-cran-rcpparmadillo \
    r-cran-rex \
    r-cran-rsqlite \
    r-cran-runit \
    r-cran-shiny \
    r-cran-stringdist \
    r-cran-testthat \
    r-cran-tidyverse \
    r-cran-tinytest \
    r-cran-xts \
    sqlite3 \
    sudo

# Install additional R packages from CRAN (on top of the ones 
# pre-built as r-cran-*)
RUN install.r bench diffobj flexdashboard lintr ttdo unix

RUN installGithub.r jaredhuling/jcolors
RUN installGithub.r ipeaGIT/geobr
CMD Rscript /script.R






