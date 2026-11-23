# Chuva nas Fazendas

Painel para ver, de relance, se está chovendo ou se vai chover em cada fazenda.
Usa os dados gratuitos da [Open-Meteo](https://open-meteo.com/), a mesma fonte das consultas do Excel.

## Como abrir no computador da empresa (sem instalar nada)

1. Baixe o arquivo `painel-chuva.html`.
2. Dê dois cliques nele: ele abre no navegador (Edge ou Chrome).

Ele já vem com as 16 fazendas e busca a previsão sozinho, de novo a cada 30 minutos.

## O que aparece

- **Mapa**: as fazendas pintadas pela chuva do momento escolhido. Fazenda com chuva pulsa.
- **Momento**: Agora, Hoje, Amanhã e os próximos dias. O botão ▶ passa os dias um a um, como um radar.
- **Região**: filtra RRP, CPG, ACL etc. (o que vem depois do " - " no nome).
- **Leitura geral**: quantas fazendas estão com chuva agora, no dia escolhido, nas próximas 24 h e quanto choveu nos últimos 7 dias.
- **Fazendas**: para cada uma, se está chovendo agora, a chuva hora a hora nas próximas 24 h, a previsão dos próximos 7 dias e o total dos últimos 7 dias.
  Clique numa fazenda para abrir as próximas 48 h, o histórico e o ajuste manual.

## Regras (botões − e + na tela)

| Situação no dia | Padrão |
|---|---|
| Sem chuva | menos de 4 mm |
| Chuva fraca | de 4 a 6 mm |
| Chuva | acima de 6 mm |
| Chovendo agora | modelo indica 0,5 mm/h ou mais na hora atual |

## Ajuste manual

Ao abrir uma fazenda, dá para informar:

- a chuva medida no pluviômetro hoje (substitui a previsão do dia);
- se está chovendo agora, confirmado no campo;
- uma observação.

O ajuste vale só para o dia e fica salvo no navegador daquele computador.

## Trocar a lista de fazendas

No fim da página, em **Lista de fazendas**, cole as colunas do Excel (`id`, `fazenda`, `Coordenadas`).
As coordenadas podem estar em graus (`19°52'39.33"S 53°01'08.98"W`) ou em decimal, em duas colunas.

## Se não carregar

Se aparecer "Não foi possível buscar a previsão", a rede está bloqueando `api.open-meteo.com` no navegador.
Peça à TI para liberar esse endereço. Enquanto isso, o painel mostra dados de exemplo.

Os valores são do modelo de previsão (não são medição de radar nem de estação).
