# Painel de Colheita × Chuva

Painel visual que mostra, por talhão, se vai chover, quanto choveu nos últimos dias e **qual talhão colher primeiro**.
Usa os dados gratuitos da [Open-Meteo](https://open-meteo.com/), a mesma fonte das consultas do Excel.

## Como usar no computador da empresa (sem instalar nada)

1. Baixe o arquivo `painel-colheita.html`.
2. Dê dois cliques nele: ele abre no navegador (Edge ou Chrome).
3. Clique em **Configurar talhões e regras**, cole as colunas do Excel e clique em **Salvar e atualizar**.

As colunas são estas (a primeira linha pode ser o cabeçalho):

| Talhão | Latitude | Longitude | Área (ha) | Prioridade (1–5) |
|---|---|---|---|---|
| T01 | -21,170 | -47,810 | 45 | 5 |

A configuração fica salva no navegador. O painel se atualiza sozinho a cada 1 hora; também dá para clicar em **Atualizar agora**.

## O que o painel mostra

- **Indicadores**: quantos talhões estão aptos hoje, quando vem a próxima chuva forte, quanto choveu e quanto vai chover.
- **O que colher hoje**: ranking dos talhões. Primeiro vêm os aptos hoje e, entre eles, os de maior prioridade e os que vão pegar chuva mais cedo.
- **Mapa**: posição dos talhões coloridos pela situação de hoje.
- **Grade talhão × dia**: histórico (cinza) e previsão (verde = pode colher, amarelo = atenção, vermelho = não colher).
- **Gráfico de chuva diária** do talhão selecionado.
- **Plano de colheita sugerido**: distribui a área pelos dias bons, de acordo com a capacidade em ha/dia.

## Regras (ajustáveis na tela)

| Situação | Quando |
|---|---|
| ✕ Não colher | chuva prevista ≥ 2 mm **ou** chance de chuva ≥ 60% |
| ! Atenção | solo úmido (≥ 15 mm nos 2 dias anteriores), chance entre 35% e 60% ou garoa |
| ✓ Pode colher | nenhum dos casos acima |

## Se não carregar

Se aparecer "Não consegui acessar a Open-Meteo", a rede está bloqueando `api.open-meteo.com` para o navegador.
Peça à TI para liberar esse endereço. Enquanto isso, o painel mostra dados de exemplo.
