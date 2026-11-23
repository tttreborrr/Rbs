"""Monta guia-powerbi.html a partir de _guia-modelo.html, consultas-power-query.pq e medidas-dax.dax.

Uso: python3 gerar-guia.py  (rode de dentro da pasta powerbi)
"""
import html
import re
from pathlib import Path

AQUI = Path(__file__).parent


def bloco(titulo, codigo):
    return (
        '<div class="code"><div class="bar"><span>' + html.escape(titulo) + '</span>'
        '<button type="button">Copiar</button></div><pre>' + html.escape(codigo.strip("\n")) + "</pre></div>"
    )


def consultas():
    texto = (AQUI / "consultas-power-query.pq").read_text(encoding="utf-8")
    partes = re.split(r"// -{20,}\n// NOME DA CONSULTA: (\w+)\n", texto)
    saida = []
    for i in range(1, len(partes), 2):
        nome, corpo = partes[i], partes[i + 1]
        linhas = corpo.split("\n")
        # tira o comentário de explicação do topo, até a linha de traços
        fim = next(n for n, l in enumerate(linhas) if l.startswith("// ---"))
        explicacao = " ".join(l[3:].strip() for l in linhas[:fim] if l.startswith("//"))
        codigo = "\n".join(linhas[fim + 1:]).strip()
        saida.append('<h3>' + html.escape(nome) + '</h3><p>' + html.escape(explicacao) + '</p>' + bloco("Consulta " + nome, codigo))
    return "\n".join(saida)


def dax():
    texto = (AQUI / "medidas-dax.dax").read_text(encoding="utf-8")
    blocos = [b.strip("\n") for b in re.split(r"\n\s*\n", texto)]
    tabelas, medidas = [], []
    for b in blocos:
        linhas = [l for l in b.split("\n") if not l.lstrip().startswith("//")]
        if not linhas:
            continue
        codigo = "\n".join(linhas)
        nome = codigo.split("=")[0].strip()
        destino = tabelas if "GENERATESERIES" in codigo else medidas
        destino.append(bloco(("Tabela " if destino is tabelas else "Medida ") + nome, codigo))
    return "\n".join(tabelas), "\n".join(medidas)


modelo = (AQUI / "_guia-modelo.html").read_text(encoding="utf-8")
t, m = dax()
saida = modelo.replace("{{PQ}}", consultas()).replace("{{DAX_TABLES}}", t).replace("{{DAX_MEASURES}}", m)
(AQUI / "guia-powerbi.html").write_text(saida, encoding="utf-8")
print("guia-powerbi.html gerado")
