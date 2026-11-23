# Painel de Colheita × Chuva

Painel visual que mostra, por talhão, se vai chover, quanto choveu nos últimos dias e **qual talhão colher primeiro**.
Usa os dados gratuitos da [Open-Meteo](https://open-meteo.com/), a mesma fonte das consultas do Excel.

## Como usar no computador da empresa (sem instalar nada)

1. Baixe o arquivo `painel-colheita.html`.
2. Dê dois cliques nele: ele abre no navegador (Edge ou Chrome).
3. Clique em **Configurar talhões e regras**, cole as colunas do Excel e clique em **Salvar e atualizar**.

O painel já vem com as 16 fazendas (id, fazenda, coordenadas). Formatos aceitos ao colar:

| id | fazenda | Coordenadas | Área (ha) *opcional* | Prioridade 1–5 *opcional* |
|---|---|---|---|---|
| 1133 | HORTO BONITO | 19°52'39.33"S 53°01'08.98"W | | |

Também aceita latitude e longitude decimais em duas colunas (`-19,8776` e `-53,0192`).
A região (RRP, CPG, ACL...) é lida do que vem depois do " - " no nome e vira um filtro no topo.

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
| ✕ Não colher | chuva prevista **acima de 6 mm** (chuva de fato) |
| ! Atenção | chuva prevista entre 4 e 6 mm, solo úmido (mais de 6 mm nos 2 dias anteriores, somando só dias com 4 mm ou mais) ou chance de chuva ≥ 80% |
| ✓ Pode colher | nenhum dos casos acima (menos de 4 mm não conta como chuva) |

## Se não carregar

Se aparecer "Não consegui acessar a Open-Meteo", a rede está bloqueando `api.open-meteo.com` para o navegador.
Peça à TI para liberar esse endereço. Enquanto isso, o painel mostra dados de exemplo.
