install.packages('devtools')
devtools::install_github("ipeaGIT/geobr")
devtools::install_github("jaredhuling/jcolors")
library("basedosdados")
library(tidyverse)
library(zoo)
library("reshape2")
library(sf)
library(geobr)
library(ggplot2)
library(jcolors)
library(lubridate)
set_billing_id("projeto-ciencia-de-dados-2022")

query <- bdplyr("br_sp_gov_ssp.ocorrencias_registradas")
OR <- bd_collect(query)
query <- bdplyr("br_sp_gov_ssp.produtividade_policial")
PP <- bd_collect(query)

sp_mun <- read_municipality(code_muni=35, year=2018)
sp_mun$code_muni = as.character(sp_mun$code_muni)

completo = full_join(OR, PP)%>%
  left_join(sp_mun, by = c('id_municipio' = 'code_muni')) %>% sf::st_as_sf()
#NA's
descritivo = do.call(cbind, lapply(completo, summary))%>% as.data.frame()
descritivo = descritivo[,-c(1:4,28,42:45)]


sp_descr = completo%>%
filter(id_municipio == '3550308')
sp_descr= do.call(cbind, lapply(sp_descr, summary))%>% as.data.frame()
sp_descr = sp_descr[,-c(1:4,28,42:45)]


#THEME SET 
theme_set(theme_bw())
theme_update(scale_color_jcolors('rainbow'))

#dir create for plots
dir.create('plots')
#mapa or 
plot = completo %>%
  filter(ano %in% c(2008,2012,2016,2020), mes == 8)%>%
  ggplot()+
  geom_sf(aes(fill= furto_outros),alpha=0.8,col="white")+
  facet_wrap(~ano)+
  scale_fill_jcolors_contin(palette = "pal11")+
  labs(
    title = 'Outros furtos no estado de São Paulo no mês de Agosto',
    fill = 'Número de furtos',
    caption = 'Fonte: Dados da Secretaria de Segurança Pública do Estado de São Paulo'
  )
ggsave(file = 'plots/mapa_furtos.jpeg',plot,  width=10, height=8)


plot = completo %>%
  filter(ano %in% c(2008,2012,2016,2020), mes == 8)%>%
  filter( !regiao_ssp %in% c('Capital', 'Grande São Paulo (exclui a Capital)' ))%>%
  ggplot()+
  geom_sf(aes(fill= furto_outros),alpha=0.8,col="white")+
  facet_wrap(~ano)+
  scale_fill_jcolors_contin(palette = "pal11")+
  labs(
    title = 'Outros furtos no estado de São Paulo no mês de Agosto',
    subtitle = 'Excluindo Grande São Paulo (capital inclusive)',
    fill = 'Número de furtos',
    caption = 'Fonte: Dados da Secretaria de Segurança Pública do Estado de São Paulo'
  )
ggsave(file = 'plots/mapa_furtos2.jpeg',plot,  width=10, height=8)



#vendo mapa sp p/ PP
plot = completo %>%
  filter(ano %in% c(2008,2012,2016,2020), mes == 8)%>%
  ggplot()+
  geom_sf(aes(fill= total_de_inqueritos_policiais_instaurados),
          alpha=0.8,col="white")+
  facet_wrap(~ano)+
  scale_fill_jcolors_contin(palette = "pal11")+
  labs(
    title = 'Total de inquéritos policiais instaurado de São Paulo',
    fill = 'Número de inquéritos',
    caption = 'Fonte: Dados da Secretaria de Segurança Pública do Estado de São Paulo'
  )
ggsave(file = 'plots/mapa_inqueritos.jpeg',plot,  width=10, height=8)


plot = completo %>%
  filter(ano %in% c(2008,2012,2016,2020), mes == 8)%>%
  filter( !regiao_ssp %in% c('Capital', 'Grande São Paulo (exclui a Capital)' ))%>%
  ggplot()+
  geom_sf(aes(fill= total_de_inqueritos_policiais_instaurados),
          alpha=0.8,col="white")+
  facet_wrap(~ano)+
  scale_fill_jcolors_contin(palette = "pal11")+
  labs(
    title = 'Total de inquéritos policiais instaurado de São Paulo',
    fill = 'Número de inquéritos',
    caption = 'Fonte: Dados da Secretaria de Segurança Pública do Estado de São Paulo'
  )
ggsave(file = 'plots/mapa_inqueritos2.jpeg',plot,  width=10, height=8)

completo$data = as.yearmon(paste(completo$ano, completo$mes), "%Y %m")
completo =  st_drop_geometry(completo)


#graficos de linha

plot = completo%>%
  filter(id_municipio == '3550308')%>%
  select(data, homicidio_doloso, homicidio_culposo_por_acidente_de_transito,
         lesao_corporal_culposa_outras,  total_de_estupro,
         roubo_de_carga)%>%
  melt(id = 'data')%>%
  ggplot(aes(x=data, y=value, colour=variable)) +
  labs(
    title = 'Ocorrências registradas ao longo dos anos',
    y = 'Valor', 
    x = 'Data',
    color = 'Ocorrência',
    caption = 'Fonte: Dados da Secretaria de Segurança Pública do Estado de São Paulo'
  )+
  geom_line(size=1.4)+
  geom_rect(
    alpha = 0.005,
    xmin = completo$data[122964],
    xmax = Inf,
    ymin = -Inf,
    ymax = Inf
  )+
  scale_color_jcolors(palette = "rainbow",
                      label = c("Homicídio Doloso",
                                'Homicídio Culposo - Acidente de trânsito',
                                'Lesão Corporal Culposa - Outras',
                                'Total de Estupros',
                                'Roubos de Carga'))+
  annotate("text", x = completo$data[122964], y = 500, 
           label = "Pandemia Covid-19",
           color = "red", fontface = 2)
ggsave(file = 'plots/linhas_or1.jpeg',plot,  width=10, height=8)


plot = completo%>%
  filter(id_municipio == '3550308')%>%
  select(data, total_de_roubo_outros, furto_outros)%>%
  melt(id = 'data')%>%
  ggplot(aes(x=data, y=value, colour=variable)) +
  labs(
    title = 'Ocorrências registradas ao longo dos anos',
    y = 'Valor', 
    x = 'Data',
    color = 'Ocorrência',
    caption = 'Fonte: Dados da Secretaria de Segurança Pública do Estado de São Paulo'
  )+
  geom_line(size=1.4)+
  geom_rect(
    alpha = 0.005,
    xmin = completo$data[122964],
    xmax = Inf,
    ymin = -Inf,
    ymax = Inf
  )+
  scale_color_jcolors(palette = "rainbow",
                      label = c('Total de Roubos - outros',
                                'Furtos - outros')
                      )+
  annotate("text", x = completo$data[122964], y = 5000, 
           label = "Pandemia Covid-19",
           color = "red", fontface = 2)
ggsave(file = 'plots/linhas_or2.jpeg',plot,  width=10, height=8)


plot = completo%>%
  filter(id_municipio == '3550308')%>%
  select(data, ocorrencias_de_porte_ilegal_de_arma,
         numero_de_armas_de_fogo_apreendidas)%>%
  melt(id = 'data')%>%
  ggplot(aes(x=data, y=value, colour=variable)) +
  labs(
    title = 'Produtividade Policial',
    y = 'Valor', 
    x = 'Data',
    color = 'Variável',
    caption = 'Fonte: Dados da Secretaria de Segurança Pública do Estado de São Paulo'
  )+
  geom_line(size=1.4)+
  geom_rect(
    alpha = 0.005,
    xmin = completo$data[122964],
    xmax = Inf,
    ymin = -Inf,
    ymax = Inf
  )+
  scale_color_jcolors(palette = "rainbow",
                      label = c('Ocorrências de Porte Ilegal de Arma',
                                'Número de Armas de Fogo Apreendidas')
  )+
  annotate("text", x = completo$data[122964], y = 750, 
           label = "Pandemia Covid-19",
           color = "red", fontface = 2)
ggsave(file = 'plots/linhas_pp1.jpeg',plot,  width=10, height=8)


#graficos de scatter plot
#ggsave


plot = completo %>%
filter(ano %in% seq(2005,2021,5),
       id_municipio == '3550308') %>%
  ggplot(aes(
    numero_de_armas_de_fogo_apreendidas,
    tentativa_de_homicidio,
    colour = factor(ano))
    )+
  geom_point(size=5)+
  geom_text(aes(
    label=ifelse(numero_de_armas_de_fogo_apreendidas>600 &
                   tentativa_de_homicidio>150,
                 as.character(mes),'')),hjust=0,vjust=0,
    color = '#000000')+
  labs(
    title = 'Relação entre tentativa de homicídio e número de armas apreendidas',
    subtitle = 'Número em cada ponto é o mês referente àquele ano',
    y = 'Tentativa de homicídio',
    x = 'Número de armas apreendidas', 
    color = 'Ano',
    caption = 'Fonte: Dados da Secretaria de Segurança Pública do Estado de São Paulo'
  )+scale_color_jcolors(palette = "rainbow")
ggsave(file = 'plots/scatter1.jpeg',plot,  width=10, height=8)
  
plot = completo %>%
  filter(ano %in% seq(2005,2021,5),
         id_municipio == '3550308') %>%
  ggplot(aes(
    total_de_estupro,
    numero_de_prisoes_efetuadas,
    colour = factor(ano))
  )+
  geom_point(size=5)+
  geom_text(aes(
    label=ifelse(total_de_estupro<150 &
                   numero_de_prisoes_efetuadas<2250&
                   ano == 2020,
                 as.character(mes),'')),hjust=0,vjust=0,
    color = '#000000')+labs(
    title = 'Relação entre tentativa de homicídio e número de armas apreendidas',
    subtitle = 'Número em cada ponto é o mês referente àquele ano',
    color = 'Ano',
    x = 'Total de estupros',
    y = 'Número de armas apreendidas',
    caption = 'Fonte: Dados da Secretaria de Segurança Pública do Estado de São Paulo'
  )+scale_color_jcolors(palette = "rainbow")
ggsave(file = 'plots/scatter2.jpeg',plot,  width=10, height=8)


#grafico com numeros de "afetados"

plot = completo %>%
  filter(id_municipio == '3550308')%>%
  select(
    numero_de_vitimas_em_homicidio_doloso,
    numero_de_vitimas_em_homicidio_doloso_por_acidente_de_transito,
    numero_de_vitimas_em_latrocinio,ano
  ) %>% group_by(ano)%>%
  summarise_all(.funs = sum, na.rm = T)%>%
  melt(id= 'ano')%>%
  ggplot(aes(fill=variable, y=value, x=ano)) + 
  geom_bar(position="stack", stat="identity")+
  scale_fill_brewer(palette = "Dark2",
                    label = c('Homícidio doloso',
                              'Homícidio doloso - acidente de trânsito',
                                                 'Latrocínio'))+
  labs(
    title = 'Número de vítimas, por ocorrência',
    caption = 'Fonte: Dados da Secretaria de Segurança Pública do Estado de São Paulo',
    x = 'Ano',
    y = 'Número de vítimas',
    fill = 'Tipo de ocorrência'
  )
ggsave(file = 'plots/stacked1.jpeg',plot,  width=10, height=8)

plot = completo %>%
  filter(id_municipio == '3550308')%>%
  select(numero_de_flagrantes_lavrados:numero_de_prisoes_efetuadas,
         ano
  ) %>% group_by(ano)%>%
  summarise_all(.funs = sum, na.rm = T)%>%
  melt(id= 'ano')%>%
  ggplot(aes(fill=variable, y=value, x=ano)) + 
  geom_bar(position="stack", stat="identity")+
  scale_fill_brewer(palette = "Dark2",
                    label = c('Flagrantes lavrados', 
                              'Infratores apreendidos em flagrante',
                              'Infratores apreendidos por mandado',
                              'Pessoas presas em flagrnate',
                              'Pessoas presas por mandado',
                              'Prisões efetuadas'))+
  labs(
    title = 'Número de pessoas lavradas, apreendidas e presas',
    caption = 'Fonte: Dados da Secretaria de Segurança Pública do Estado de São Paulo',
    x = 'Ano',
    y = 'Número de pessoas',
    fill = 'Produtividade policial'
  )
ggsave(file = 'plots/stacked2.jpeg',plot,  width=10, height=8)
