// =====================================================================
// CONSULTAS DO POWER QUERY · Chuva nas Fazendas · MS Florestal
// Cada bloco abaixo é UMA consulta. No Power BI Desktop:
//   Página Inicial > Transformar dados > Nova fonte > Consulta nula
//   > Editor Avançado > apagar tudo > colar o bloco > Concluído
//   > renomear a consulta com o nome indicado em "NOME DA CONSULTA".
// Antes, crie o parâmetro CaminhoFazendas (passo 2 do guia).
// =====================================================================


// ---------------------------------------------------------------------
// NOME DA CONSULTA: Fazendas
// Lê a planilha Fazendas.xlsx (tabela "Fazendas": id, fazenda, Coordenadas)
// e converte as coordenadas em graus para latitude e longitude decimais.
// ---------------------------------------------------------------------
let
    GrausParaDecimal = (texto as text) as number =>
        let
            t = Text.Trim(texto),
            hemisferio = Text.Upper(Text.End(t, 1)),
            corpo = Text.Start(t, Text.Length(t) - 1),
            partes = List.Select(List.Transform(Text.SplitAny(corpo, "°º'’""″”"), Text.Trim), each _ <> ""),
            numero = (x as text) as number => Number.FromText(Text.Replace(x, ",", "."), "en-US"),
            graus = numero(partes{0}),
            minutos = if List.Count(partes) > 1 then numero(partes{1}) else 0,
            segundos = if List.Count(partes) > 2 then numero(partes{2}) else 0,
            valor = graus + minutos / 60 + segundos / 3600
        in
            if List.Contains({"S", "W", "O"}, hemisferio) then -valor else valor,

    Planilha = Excel.Workbook(File.Contents(CaminhoFazendas), null, true),
    Tabela = Planilha{[Item = "Fazendas", Kind = "Table"]}[Data],
    Validas = Table.SelectRows(Tabela, each [id] <> null and [Coordenadas] <> null and Text.Trim(Text.From([Coordenadas])) <> ""),
    Texto = Table.TransformColumns(Validas, {
        {"id", each Text.Trim(Text.From(_)), type text},
        {"fazenda", each Text.Trim(Text.From(_)), type text},
        {"Coordenadas", each Text.Trim(Text.From(_)), type text}
    }),
    ComPartes = Table.AddColumn(Texto, "Partes", each List.Select(Text.Split([Coordenadas], " "), each _ <> "")),
    ComLatitude = Table.AddColumn(ComPartes, "Latitude", each GrausParaDecimal([Partes]{0}), type number),
    ComLongitude = Table.AddColumn(ComLatitude, "Longitude", each GrausParaDecimal([Partes]{1}), type number),
    ComFrente = Table.AddColumn(ComLongitude, "Frente", each
        let p = Text.Split([fazenda], " - ") in if List.Count(p) > 1 then Text.Trim(List.Last(p)) else "Outras", type text),
    ComNome = Table.AddColumn(ComFrente, "Nome curto", each Text.Trim(Text.Split([fazenda], " - "){0}), type text),
    Final = Table.RemoveColumns(ComNome, {"Partes"})
in
    Final


// ---------------------------------------------------------------------
// NOME DA CONSULTA: Modelos
// Tabela fixa com os 3 modelos de previsão.
// ---------------------------------------------------------------------
let
    Fonte = #table(
        type table [Modelo = text, Chave = text, Origem = text, Ordem = Int64.Type],
        {
            {"ECMWF", "ecmwf_ifs025", "Europa (Centro Europeu)", 1},
            {"GFS", "gfs_seamless", "Estados Unidos (NOAA)", 2},
            {"ICON", "icon_seamless", "Alemanha (DWD)", 3}
        }
    )
in
    Fonte


// ---------------------------------------------------------------------
// NOME DA CONSULTA: RespostasAPI
// Para cada fazenda, busca na Open-Meteo: chuva de agora, hora a hora e
// por dia (7 dias para trás e 7 para a frente), nos 3 modelos.
// Esta consulta lê a planilha e chama a API no mesmo lugar de propósito:
// assim o Power BI Online consegue atualizar sozinho.
// Depois de criar, clique com o botão direito nela e DESMARQUE
// "Habilitar carga" (ela é só intermediária).
// ---------------------------------------------------------------------
let
    GrausParaDecimal = (texto as text) as number =>
        let
            t = Text.Trim(texto),
            hemisferio = Text.Upper(Text.End(t, 1)),
            corpo = Text.Start(t, Text.Length(t) - 1),
            partes = List.Select(List.Transform(Text.SplitAny(corpo, "°º'’""″”"), Text.Trim), each _ <> ""),
            numero = (x as text) as number => Number.FromText(Text.Replace(x, ",", "."), "en-US"),
            graus = numero(partes{0}),
            minutos = if List.Count(partes) > 1 then numero(partes{1}) else 0,
            segundos = if List.Count(partes) > 2 then numero(partes{2}) else 0,
            valor = graus + minutos / 60 + segundos / 3600
        in
            if List.Contains({"S", "W", "O"}, hemisferio) then -valor else valor,

    // Pede a resposta compactada em gzip: em alguns computadores o Power BI
    // não consegue abrir a resposta no formato "deflate" (erro "Dados inválidos
    // encontrados durante a decodificação"). Se não der, tenta sem compressão.
    Pedir = (lat as number, lon as number, compressao as text) as record =>
        let
            j = Json.Document(
                Web.Contents(
                    "https://api.open-meteo.com",
                    [
                        RelativePath = "v1/forecast",
                        Query = [
                            latitude = Number.ToText(lat, "0.0000", "en-US"),
                            longitude = Number.ToText(lon, "0.0000", "en-US"),
                            current = "precipitation",
                            hourly = "precipitation,precipitation_probability",
                            daily = "precipitation_sum,precipitation_probability_max",
                            models = "ecmwf_ifs025,gfs_seamless,icon_seamless",
                            past_days = "7",
                            forecast_days = "7",
                            timezone = "America/Campo_Grande"
                        ],
                        Headers = [#"Accept-Encoding" = compressao],
                        Timeout = #duration(0, 0, 2, 0)
                    ]
                )
            )
        in
            if Record.HasFields(j, {"daily", "hourly", "current"}) then j else error "Resposta da Open-Meteo sem os dados de chuva",
    Chamar = (lat as number, lon as number) as record =>
        try Pedir(lat, lon, "gzip") otherwise Pedir(lat, lon, "identity"),

    Planilha = Excel.Workbook(File.Contents(CaminhoFazendas), null, true),
    Tabela = Planilha{[Item = "Fazendas", Kind = "Table"]}[Data],
    Validas = Table.SelectRows(Tabela, each [id] <> null and [Coordenadas] <> null and Text.Trim(Text.From([Coordenadas])) <> ""),
    Pontos = Table.AddColumn(Validas, "Ponto", each
        let p = List.Select(Text.Split(Text.Trim(Text.From([Coordenadas])), " "), each _ <> "")
        in [Lat = GrausParaDecimal(p{0}), Lon = GrausParaDecimal(p{1})]),
    ComId = Table.TransformColumns(Table.SelectColumns(Pontos, {"id", "Ponto"}), {{"id", each Text.Trim(Text.From(_)), type text}}),
    ComResposta = Table.AddColumn(ComId, "Resposta", each Chamar([Ponto][Lat], [Ponto][Lon])),
    Final = Table.SelectColumns(ComResposta, {"id", "Resposta"})
in
    Final


// ---------------------------------------------------------------------
// NOME DA CONSULTA: ChuvaDiaria
// Uma linha por fazenda × dia × modelo.
// DiaRel: 0 = hoje, 1 = amanhã, -1 = ontem...
// ---------------------------------------------------------------------
let
    Fonte = RespostasAPI,
    Modelos = {{"ECMWF", "ecmwf_ifs025"}, {"GFS", "gfs_seamless"}, {"ICON", "icon_seamless"}},
    ParaData = (x as text) as date => Date.FromText(Text.Start(x, 10), [Format = "yyyy-MM-dd", Culture = "en-US"]),
    Linhas = Table.AddColumn(Fonte, "Linhas", (r) =>
        let
            d = r[Resposta][daily],
            hoje = ParaData(r[Resposta][current][time]),
            datas = List.Transform(d[time], ParaData),
            n = List.Count(datas),
            porModelo = List.Transform(Modelos, (m) =>
                let
                    mm = Record.FieldOrDefault(d, "precipitation_sum_" & m{1}, null),
                    chance = Record.FieldOrDefault(d, "precipitation_probability_max_" & m{1}, null)
                in
                    if mm = null then null
                    else Table.FromColumns(
                        {
                            datas,
                            List.Repeat({m{0}}, n),
                            mm,
                            if chance = null then List.Repeat({null}, n) else chance,
                            List.Transform(datas, each Duration.Days(_ - hoje))
                        },
                        {"Data", "Modelo", "mm", "Chance", "DiaRel"}
                    )
            )
        in
            Table.Combine(List.RemoveNulls(porModelo))
    ),
    Expandido = Table.ExpandTableColumn(Table.SelectColumns(Linhas, {"id", "Linhas"}), "Linhas", {"Data", "Modelo", "mm", "Chance", "DiaRel"}),
    ComTipo = Table.AddColumn(Expandido, "Tipo", each if [DiaRel] < 0 then "Histórico" else if [DiaRel] = 0 then "Hoje" else "Previsão", type text),
    ComDia = Table.AddColumn(ComTipo, "Dia", each
        if [DiaRel] = 0 then "Hoje"
        else if [DiaRel] = 1 then "Amanhã"
        else Date.ToText([Data], [Format = "ddd dd/MM", Culture = "pt-BR"]), type text),
    Tipos = Table.TransformColumnTypes(ComDia, {
        {"id", type text}, {"Data", type date}, {"Modelo", type text},
        {"mm", type number}, {"Chance", Int64.Type}, {"DiaRel", Int64.Type}
    })
in
    Tipos


// ---------------------------------------------------------------------
// NOME DA CONSULTA: ChuvaHoraria
// Uma linha por fazenda × hora × modelo, das últimas 24 h às próximas 48 h.
// HorasRel: 0 = hora atual, 1 = próxima hora...
// ---------------------------------------------------------------------
let
    Fonte = RespostasAPI,
    Modelos = {{"ECMWF", "ecmwf_ifs025"}, {"GFS", "gfs_seamless"}, {"ICON", "icon_seamless"}},
    ParaDataHora = (x as text) as datetime => DateTime.FromText(Text.Replace(x, "T", " "), [Format = "yyyy-MM-dd HH:mm", Culture = "en-US"]),
    Linhas = Table.AddColumn(Fonte, "Linhas", (r) =>
        let
            h = r[Resposta][hourly],
            agora = ParaDataHora(r[Resposta][current][time]),
            horaAtual = #datetime(Date.Year(agora), Date.Month(agora), Date.Day(agora), Time.Hour(agora), 0, 0),
            horas = List.Transform(h[time], ParaDataHora),
            n = List.Count(horas),
            rel = List.Transform(horas, each Duration.TotalHours(_ - horaAtual)),
            porModelo = List.Transform(Modelos, (m) =>
                let
                    mm = Record.FieldOrDefault(h, "precipitation_" & m{1}, null),
                    chance = Record.FieldOrDefault(h, "precipitation_probability_" & m{1}, null)
                in
                    if mm = null then null
                    else Table.FromColumns(
                        {horas, List.Repeat({m{0}}, n), mm, if chance = null then List.Repeat({null}, n) else chance, rel},
                        {"Data e hora", "Modelo", "mm", "Chance", "HorasRel"}
                    )
            )
        in
            Table.SelectRows(Table.Combine(List.RemoveNulls(porModelo)), each [HorasRel] >= -24 and [HorasRel] < 48)
    ),
    Expandido = Table.ExpandTableColumn(Table.SelectColumns(Linhas, {"id", "Linhas"}), "Linhas", {"Data e hora", "Modelo", "mm", "Chance", "HorasRel"}),
    Tipos = Table.TransformColumnTypes(Expandido, {
        {"id", type text}, {"Data e hora", type datetime}, {"Modelo", type text},
        {"mm", type number}, {"Chance", Int64.Type}, {"HorasRel", Int64.Type}
    })
in
    Tipos


// ---------------------------------------------------------------------
// NOME DA CONSULTA: ChuvaAgora
// Uma linha por fazenda × modelo com a chuva da hora atual (mm/h).
// ---------------------------------------------------------------------
let
    Fonte = RespostasAPI,
    Modelos = {{"ECMWF", "ecmwf_ifs025"}, {"GFS", "gfs_seamless"}, {"ICON", "icon_seamless"}},
    Linhas = Table.AddColumn(Fonte, "Linhas", (r) =>
        let
            c = r[Resposta][current],
            h = r[Resposta][hourly],
            posicao = List.PositionOf(h[time], Text.Start(c[time], 13) & ":00"),
            linhas = List.Transform(Modelos, (m) =>
                let
                    atual = Record.FieldOrDefault(c, "precipitation_" & m{1}, null),
                    lista = Record.FieldOrDefault(h, "precipitation_" & m{1}, null),
                    valor = if atual <> null then atual else if lista <> null and posicao >= 0 then lista{posicao} else null
                in
                    {m{0}, valor})
        in
            #table({"Modelo", "mm/h"}, linhas)
    ),
    Expandido = Table.ExpandTableColumn(Table.SelectColumns(Linhas, {"id", "Linhas"}), "Linhas", {"Modelo", "mm/h"}),
    Tipos = Table.TransformColumnTypes(Expandido, {{"id", type text}, {"Modelo", type text}, {"mm/h", type number}})
in
    Tipos


// ---------------------------------------------------------------------
// NOME DA CONSULTA: Atualizacao
// Hora local da previsão (fuso de Campo Grande) e a data de "hoje".
// ---------------------------------------------------------------------
let
    Fonte = RespostasAPI,
    Hora = DateTime.FromText(Text.Replace(Fonte{0}[Resposta][current][time], "T", " "), [Format = "yyyy-MM-dd HH:mm", Culture = "en-US"]),
    Tabela = #table(type table [#"Hora local" = datetime, Hoje = date], {{Hora, Date.From(Hora)}})
in
    Tabela
