// NOME DA CONSULTA: Diagnostico
// Testa cada parte separadamente e mostra OK ou a mensagem de erro de cada uma.
// Clique em cada linha do resultado para ver o texto completo. Depois pode apagar esta consulta.
let
    Base = "https://api.open-meteo.com",
    Pequena = [latitude = "-20.5278", longitude = "-54.1677", daily = "precipitation_sum", timezone = "America/Campo_Grande"],
    Completa = Pequena & [
        current = "precipitation",
        hourly = "precipitation,precipitation_probability",
        daily = "precipitation_sum,precipitation_probability_max",
        models = "ecmwf_ifs025,gfs_seamless,icon_seamless",
        past_days = "7",
        forecast_days = "7"
    ],
    TestarApi = (q as record, cabecalhos as record) as text =>
        let
            r = try Json.Document(Web.Contents(Base, [RelativePath = "v1/forecast", Query = q, Headers = cabecalhos]))
        in
            if r[HasError] then "ERRO: " & r[Error][Message]
            else "OK: " & Text.Combine(Record.FieldNames(r[Value]), ", "),
    TestarPlanilha =
        let
            r = try Table.RowCount(Excel.Workbook(File.Contents(CaminhoFazendas), null, true){[Item = "Fazendas", Kind = "Table"]}[Data])
        in
            if r[HasError] then "ERRO: " & r[Error][Message] else "OK: " & Text.From(r[Value]) & " fazendas",
    Resultado = #table({"Teste", "Resultado"}, {
        {"1 Planilha Fazendas.xlsx", TestarPlanilha},
        {"2 Open-Meteo, chamada pequena", TestarApi(Pequena, [])},
        {"3 Open-Meteo, chamada completa", TestarApi(Completa, [])},
        {"4 Completa, sem compressão", TestarApi(Completa, [#"Accept-Encoding" = "identity"])},
        {"5 Completa, só gzip", TestarApi(Completa, [#"Accept-Encoding" = "gzip"])}
    })
in
    Resultado
