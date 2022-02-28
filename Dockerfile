FROM rocker/tidyverse:4.0.0


RUN R -e 'install.packages("basedosdados")'
RUN R -e 'install.packages("zoo")'
RUN R -e 'install.packages("reshape2")'
RUN R -e 'install.packages("sf")'
RUN R -e 'install.packages("geobr")'
RUN R -e 'install.packages("ggplot2")'
RUN R -e 'install.packages("lubridate")'
RUN R -e 'install.packages("devtools")'

CMD Rscript /script.R






