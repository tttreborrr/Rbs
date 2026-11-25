# Chuva nas Fazendas

Painel para ver, de relance, se está chovendo ou se vai chover em cada fazenda.
Usa os dados gratuitos da [Open-Meteo](https://open-meteo.com/), a mesma fonte das consultas do Excel.

## Como abrir no computador da empresa (sem instalar nada)

1. Baixe o arquivo `painel-chuva.html`.
2. Dê dois cliques nele: ele abre no navegador (Edge ou Chrome).

Ele já vem com as 16 fazendas e busca a previsão sozinho, de novo a cada 30 minutos.

## Tela inicial

Ao abrir, aparece a tela para escolher **frentes** e **fazendas**. Clique no nome da frente para marcar todas dela, ou em cada fazenda. Depois clique em **Iniciar**: o painel busca e mostra só as marcadas. O botão **Trocar fazendas** (no topo) volta para essa tela. A escolha fica salva.

A lista completa pode vir de uma **planilha do Excel** (.xlsx ou .csv): botão **Carregar planilha do Excel** ou arraste o arquivo para a tela inicial. O painel procura as colunas pelo nome do cabeçalho: nome da fazenda (`fazenda`), coordenadas (`Coordenadas`, ou `Latitude` e `Longitude`), e, se houver, `id`/`Código` e `Frente`. Sem coluna Frente, a frente é o que vem depois do " - " no nome.

## Áreas das fazendas no mapa

Embaixo do mapa, **Carregar áreas (shape, KML)** aceita: `.zip` do shapefile, os arquivos `.shp` + `.dbf` + `.prj` juntos, `.kml`, `.kmz` ou `.geojson`. Shapefile em UTM (SIRGAS 2000, zonas 21S/22S etc.) é convertido para graus no próprio navegador; em coordenadas geográficas também funciona. Outras projeções (por exemplo Policônica) precisam ser exportadas em UTM, geográfico ou KML.

Cada área é ligada a uma fazenda da lista pelo código ou pelo nome (automático, ou escolhendo a coluna em "Ligar pela coluna") e fica com a cor da chuva da fazenda. A barra **Opacidade** deixa as áreas mais ou menos transparentes. As áreas ficam guardadas no navegador e vão junto no arquivo do mês (se não forem grandes demais).

## Pasta conectada (lista e áreas lidas sozinhas)

**Conectar pasta** (na tela inicial ou embaixo do mapa) escolhe uma pasta do computador, da rede ou do OneDrive. O painel lê dela:

- a planilha de fazendas (a primeira `.xlsx`/`.csv` com colunas de fazenda e coordenadas; as que têm "fazenda" no nome vêm primeiro);
- todas as áreas: shapefiles (`.shp` + `.dbf` + `.prj`, inclusive em subpastas), `.zip`, `.kml`, `.kmz`, `.geojson`.

O navegador lembra a pasta. Em cada visita ele pede uma confirmação (o clique em **Iniciar** ou em **Ler pasta** já serve) e o painel lê a pasta de novo; enquanto aberto, confere a cada 30 minutos se algum arquivo mudou. Funciona no Edge e no Chrome.

## Madeira segura, volume e TPC por talhão

**Carregar planilha de operações** (embaixo do mapa, ou deixando a planilha na pasta conectada) lê uma planilha com as colunas `ID`, `id_projeto`, `cd_talhao`, `data_operacao`, `vlr_volume_ajustado`, `% Madeira Segura` e `TPC`. As linhas são juntadas por talhão:

- volume ajustado: soma;
- madeira segura: média ponderada pelo volume;
- TPC: dias desde a operação mais antiga do talhão, contados até hoje (a planilha mostra que TPC = hoje − data da operação);
- primeira e última operação.

Cada talhão é ligado ao shape pelo código do projeto + código do talhão (007-01, 7-01 e 00701 valem igual) ou pelo ID completo (6194007-01). Se a ligação automática falhar, escolha as colunas do shape em "Ligar talhões".

No mapa, **Colorir: Chuva / TPC** troca a cor dos talhões. TPC: **vermelho** abaixo de 30 dias, **amarelo** de 30 a 45 dias, **verde** acima de 45 dias (contorno branco para destacar do satélite). A madeira segura aparece na tabela e ao passar o mouse. Passando o mouse aparecem volume, madeira segura, TPC e datas. A tabela **Madeira nos talhões** ordena por fazenda, talhão, madeira segura, volume, TPC, última operação ou chuva; o botão **Ver** leva o mapa até o talhão. **Expandir mapa** recolhe a leitura geral e aumenta o mapa.

O componente do mapa (Leaflet 1.9.4, licença BSD-2) vem embutido no arquivo; da internet vêm só as imagens do satélite e das ruas (server.arcgisonline.com). Para o mapa continuar leve, os contornos são simplificados ao carregar (tolerância de cerca de 1 metro) e desenhados em canvas.

## Estradas cascalhadas

Em **Configurações do mapa › Estradas**, carregue o shape de estradas (linhas: `.zip`, `.shp`+`.dbf`+`.prj`, `.kml`, `.kmz`, `.geojson`). Elas ficam numa camada separada, por cima dos talhões, em bege com contorno escuro, e podem ser ligadas e desligadas no canto do mapa ("Estradas cascalhadas"). Na pasta conectada, arquivos de linhas viram estradas e de polígonos viram talhões automaticamente.

## Configurações do mapa

Os botões de carregar talhões, estradas, pasta e planilha de operações ficam em **⚙ Configurações do mapa** (recolhido). Embaixo do mapa ficam visíveis só a opacidade (100% por padrão) e um resumo do que está carregado.

## O que aparece

- **Mapa**: mapa de verdade, com zoom, satélite e nomes de estradas (Esri). As fazendas são pintadas pela chuva do momento escolhido; fazenda com chuva pulsa. Se a rede bloquear o mapa, aparece um mapa simples no lugar.
- **Momento**: Agora, Hoje, Amanhã e os próximos dias. O botão ▶ passa os dias um a um, como um radar.
- **Frente**: filtra as frentes de carregamento RRP, CPG, ACL etc. (o que vem depois do " - " no nome).
- **Leitura geral**: quantas fazendas estão com chuva agora, no dia escolhido, nas próximas 24 h e quanto choveu nos últimos 7 dias.
- **Fazendas**: para cada uma, se está chovendo agora, a chuva hora a hora nas próximas 24 h, a previsão dos próximos 7 dias e o total dos últimos 7 dias.
  Clique numa fazenda para abrir as próximas 48 h, o histórico e o ajuste manual.

## Modelos de previsão

No topo dá para escolher o modelo: **ECMWF** (europeu, o mesmo que o Windy mostra por padrão), **GFS** (americano), **ICON** (alemão) ou a **Média** dos três.
Nas células dos próximos 7 dias, as três bolinhas mostram o que cada modelo prevê (vazia = sem chuva, meio cheia = chuva fraca, cheia = chuva).
Ao abrir uma fazenda aparece a tabela comparando os três e um link para abrir o mesmo ponto no Windy.

No fim da página há uma **Legenda** com as cores, siglas, a ficha de cada modelo (quem faz, detalhe, para que serve, confiança) e como o painel funciona.

## Regras (botões − e + na tela)

| Situação no dia | Padrão |
|---|---|
| Sem chuva | menos de 4 mm |
| Chuva | de 4 a 6 mm |
| Chuva forte | acima de 6 mm |
| Chovendo agora | modelo indica 0,5 mm/h ou mais na hora atual |

## Ajuste manual

Ao abrir uma fazenda, dá para informar:

- a chuva medida no pluviômetro hoje (substitui a previsão do dia);
- se está chovendo agora, confirmado no campo;
- uma observação.

O ajuste vale só para o dia e fica salvo no navegador daquele computador.

## Lista do mês, logo e arquivo para compartilhar

- A lista colada fica salva no navegador daquele computador.
- **Baixar painel com esta lista** gera um novo `.html` com a lista, as regras e a logo dentro. Guarde um por mês ou mande pelo Teams.
- A **logo** é escolhida em "Lista de fazendas, logo e arquivo do mês" (imagem PNG ou JPG do computador).

## Trocar a lista de fazendas

No fim da página, em **Lista de fazendas**, cole as colunas do Excel (`id`, `fazenda`, `Coordenadas`).
As coordenadas podem estar em graus (`19°52'39.33"S 53°01'08.98"W`) ou em decimal, em duas colunas.

## Se não carregar

Se aparecer "Não foi possível buscar a previsão", a rede está bloqueando `api.open-meteo.com` no navegador.
Peça à TI para liberar esse endereço. Enquanto isso, o painel mostra dados de exemplo.

Os valores são do modelo de previsão (não são medição de radar nem de estação).

## Power BI (pasta `powerbi/`)

Kit para montar o mesmo relatório no Power BI, com atualização automática:

- `guia-powerbi.html`: passo a passo com botão de copiar em cada código (abra no navegador)
- `Fazendas.xlsx`: planilha da lista do mês (tabela "Fazendas")
- `consultas-power-query.pq`: as consultas do Power Query
- `medidas-dax.dax`: tabelas de limite e medidas
- `tema-msflorestal.json`: tema com as cores da MS Florestal

O guia é gerado a partir dos arquivos `.pq` e `.dax` com `python3 powerbi/gerar-guia.py`.
