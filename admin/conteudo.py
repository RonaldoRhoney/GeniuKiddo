"""Núcleo do Painel Admin do Genius Kiddo: lê, valida, formata e salva o
conteúdo do app (assets/content/*.json e lib/l10n/app_*.arb).

Só biblioteca padrão do Python — nada para instalar. As regras de validação
espelham os testes do app (test/school_world_test.dart,
test/school_lessons_test.dart e afins), pra o painel nunca salvar um
conteúdo que o app recusaria.
"""

from __future__ import annotations

import json
import re
import subprocess
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
CLIENT = RAIZ / "client"
CONTEUDO = CLIENT / "assets" / "content"
L10N = CLIENT / "lib" / "l10n"
LABELS = CLIENT / "lib" / "content" / "labels.dart"

# Valores que o código do app conhece (o resto é dado).
TIPOS_TRILHA = {"paint", "listen", "match", "trace", "speak"}
ARTES_PINTURA = {"garden", "house", "flower"}  # lib/features/activities/paint/paint_art.dart
GLIFOS = {"1", "O"}  # lib/features/activities/trace/trace_glyphs.dart
AULAS = {"shapes", "count", "paint", "letters", "rhythm", "sorting"}
MISSOES = {"build", "lessons", "level"}
GENEROS = {"m", "f"}
FORMAS = {"circle", "square", "triangle", "star", "heart"}  # nome em shapeX no ARB


# --------------------------------------------------------------- leitura


def idiomas() -> list[str]:
    """Códigos dos idiomas que têm ARB (pt primeiro: é o modelo)."""
    codigos = sorted(p.stem.removeprefix("app_") for p in L10N.glob("app_*.arb"))
    return sorted(codigos, key=lambda c: (c != "pt", c))


def carregar() -> dict:
    return {
        "items": json.loads((CONTEUDO / "items.json").read_text("utf-8")),
        "trail": json.loads((CONTEUDO / "trail.json").read_text("utf-8")),
        "school": json.loads((CONTEUDO / "school.json").read_text("utf-8")),
        "arb": {
            c: json.loads((L10N / f"app_{c}.arb").read_text("utf-8"))
            for c in idiomas()
        },
        "idiomas": idiomas(),
        "artes": sorted(ARTES_PINTURA),
        "glifos": sorted(GLIFOS),
        "tiposTrilha": sorted(TIPOS_TRILHA),
    }


# ----------------------------------------------------- nomes dos itens


def pascal(item_id: str) -> str:
    return "".join(p.capitalize() for p in re.split(r"[_-]", item_id))


def chave_nome(item_id: str) -> str:
    """Chave ARB do nome do item (formas usam shapeX, o resto itemX)."""
    return ("shape" if item_id in FORMAS else "item") + pascal(item_id)


# ------------------------------------------------------------ validação


def _iniciais_por_idioma(conteudo: dict) -> dict[str, set[str]]:
    letras = conteudo["school"].get("lessons", {}).get("letters", {}).get("items", [])
    out = {}
    for c, arb in conteudo["arb"].items():
        fold = {}
        for par in arb.get("letterFold", "").split(","):
            if "=" in par:
                a, b = par.split("=", 1)
                fold[a.strip().lower()] = b.strip().lower()
        ini = set()
        for i in letras:
            nome = arb.get(chave_nome(i), "")
            if nome:
                c0 = nome.strip().lower()[0]
                ini.add(fold.get(c0, c0).upper())
        out[c] = ini
    return out


def validar(conteudo: dict) -> list[str]:
    """Lista de problemas (vazia = pode salvar)."""
    erros: list[str] = []
    items = conteudo["items"]
    trail = conteudo["trail"]
    school = conteudo["school"]
    arbs = conteudo["arb"]

    # Itens: emoji, gênero por idioma, nome em todos os idiomas.
    for iid, it in items.items():
        if not re.fullmatch(r"[a-z][a-z0-9_]*", iid):
            erros.append(f"Item '{iid}': o id deve ter só letras minúsculas, números e _.")
        if not str(it.get("emoji", "")).strip():
            erros.append(f"Item '{iid}': falta o emoji.")
        for lang, g in (it.get("gender") or {}).items():
            if lang not in arbs:
                erros.append(f"Item '{iid}': gênero para o idioma '{lang}', que não existe.")
            if g not in GENEROS:
                erros.append(f"Item '{iid}': gênero '{g}' inválido (use m ou f).")
        for lang, arb in arbs.items():
            if not str(arb.get(chave_nome(iid), "")).strip():
                erros.append(f"Item '{iid}': sem nome em '{lang}' (chave {chave_nome(iid)}).")

    def item_existe(i: str, onde: str):
        if i not in items:
            erros.append(f"{onde}: o item '{i}' não existe em items.json.")

    # Trilha.
    ids = set()
    for n, no in enumerate(trail, 1):
        onde = f"Trilha, etapa {n}"
        if no.get("id") in ids:
            erros.append(f"{onde}: id '{no.get('id')}' repetido.")
        ids.add(no.get("id"))
        tipo = no.get("type")
        if tipo not in TIPOS_TRILHA:
            erros.append(f"{onde}: tipo '{tipo}' desconhecido.")
        if tipo == "paint" and no.get("art") not in ARTES_PINTURA:
            erros.append(f"{onde}: arte '{no.get('art')}' não existe ({', '.join(sorted(ARTES_PINTURA))}).")
        if tipo == "trace" and no.get("glyph") not in GLIFOS:
            erros.append(f"{onde}: glifo '{no.get('glyph')}' não existe ({', '.join(sorted(GLIFOS))}).")
        if tipo in {"listen", "match", "speak"}:
            lista = no.get("items") or []
            minimo = {"listen": 4, "match": 4, "speak": 1}[tipo]
            if len(lista) < minimo:
                erros.append(f"{onde}: precisa de pelo menos {minimo} itens.")
            for i in lista:
                item_existe(i, onde)
        r = no.get("rounds", 3)
        if not isinstance(r, int) or r < 1:
            erros.append(f"{onde}: rodadas devem ser um número inteiro ≥ 1.")
        for lang, arb in arbs.items():
            chave = "trailNode" + pascal(str(no.get("id", "")))
            if chave not in arb:
                erros.append(f"{onde}: sem título em '{lang}' (chave {chave}).")

    # Escola: mundo, terrenos e regiões (como test/school_world_test.dart).
    world = school.get("world", {})
    w, h, lot = world.get("width", 0), world.get("height", 0), world.get("lotSize", 0)
    grades = school.get("grades", [])
    regioes = school.get("regions", [])
    if {r.get("grade") for r in regioes} != set(range(len(grades))):
        erros.append("Escola: precisa de exatamente uma região por série.")
    espacos = school.get("spaces", [])
    for s in espacos:
        sid, x, y = s.get("id"), s.get("x", 0), s.get("y", 0)
        if s.get("lesson") not in AULAS:
            erros.append(f"Espaço '{sid}': aula '{s.get('lesson')}' desconhecida.")
        if x - lot / 2 < 0 or y - lot / 2 < 0 or x + lot / 2 > w or y + lot / 2 > h:
            erros.append(f"Espaço '{sid}': o terreno sai do mundo ({w}×{h}).")
        reg = next((r for r in regioes if r.get("grade") == s.get("grade")), None)
        if reg and not (reg["x"] <= x <= reg["x"] + reg["width"] and reg["y"] <= y <= reg["y"] + reg["height"]):
            erros.append(f"Espaço '{sid}': fora da região da própria série.")
        for lang, arb in arbs.items():
            if f"spaceName_{sid}" not in arb:
                erros.append(f"Espaço '{sid}': sem nome em '{lang}'.")
    for i, a in enumerate(espacos):
        for b in espacos[i + 1:]:
            if abs(a.get("x", 0) - b.get("x", 0)) < lot and abs(a.get("y", 0) - b.get("y", 0)) < lot:
                erros.append(f"Espaços '{a.get('id')}' e '{b.get('id')}': terrenos sobrepostos.")
    for r in regioes:
        for i in r.get("animals", []):
            item_existe(i, f"Região da série {r.get('grade')}")
    if len(school.get("missions", [])) != len(grades):
        erros.append("Escola: precisa de uma lista de objetivos por série.")
    for g, ms in enumerate(school.get("missions", [])):
        for m in ms:
            if m.get("type") not in MISSOES:
                erros.append(f"Objetivos da série {g}: tipo '{m.get('type')}' desconhecido.")
            if not isinstance(m.get("n"), int) or m.get("n") < 1:
                erros.append(f"Objetivos da série {g}: quantidade inválida.")
    custos = school.get("costs", {})
    if custos.get("build", 0) < 1 or any(c < 1 for c in custos.get("upgrade", [])):
        erros.append("Escola: custos devem ser ≥ 1.")

    # Aulas: listas de itens.
    lessons = school.get("lessons", {})
    for i in lessons.get("letters", {}).get("items", []):
        item_existe(i, "Biblioteca")
    srt = lessons.get("sorting", {})
    for i in srt.get("fruits", []) + srt.get("veggies", []):
        item_existe(i, "Refeitório")
    if len(srt.get("fruits", [])) < srt.get("fruitCount", 3):
        erros.append("Refeitório: menos frutas do que as que a aula sorteia.")
    if len(srt.get("veggies", [])) < srt.get("veggieCount", 2):
        erros.append("Refeitório: menos legumes do que os que a aula sorteia.")
    arts = lessons.get("paint", {}).get("artByGrade", [])
    if len(arts) != len(grades) or any(a not in ARTES_PINTURA for a in arts):
        erros.append("Ateliê: precisa de uma arte conhecida por série.")
    # Biblioteca: o Pré II mostra 4 letras — cada idioma precisa de 4 iniciais
    # diferentes entre as figuras.
    for lang, ini in _iniciais_por_idioma(conteudo).items():
        if len(ini) < 4:
            erros.append(f"Biblioteca em '{lang}': só {len(ini)} iniciais diferentes (precisa de 4).")

    # Traduções: mesmas chaves e mesmos marcadores {x} em todos os idiomas.
    modelo = idiomas()[0]
    base = {k for k in arbs[modelo] if not k.startswith("@")}
    for lang, arb in arbs.items():
        chaves = {k for k in arb if not k.startswith("@")}
        for k in sorted(base - chaves):
            erros.append(f"Texto '{k}': falta em '{lang}'.")
        for k in sorted(chaves - base):
            erros.append(f"Texto '{k}': existe em '{lang}' mas não em '{modelo}'.")
        for k in base & chaves:
            # Um idioma pode usar menos marcadores (o inglês ignora o
            # gênero), nunca um que o modelo não declara.
            declarados = set((arbs[modelo].get("@" + k) or {}).get("placeholders", {}))
            permitidos = declarados or set(_marcadores(arbs[modelo][k]))
            extras = set(_marcadores(arb[k])) - permitidos
            if extras:
                erros.append(f"Texto '{k}' em '{lang}': marcador {{{', '.join(sorted(extras))}}} que não existe em '{modelo}'.")
    return erros


def _marcadores(texto) -> list[str]:
    """Marcadores {nome} de uma mensagem, em qualquer profundidade do ICU
    (pega {name} dentro de um select; ignora o texto dos casos)."""
    if not isinstance(texto, str):
        return []
    # `(?<!\w)`: "other{azul}" é o texto de um caso, não um marcador.
    return re.findall(r"(?<!\w)\{(\w+)[,}]", texto)


# ------------------------------------------------------- formatação


def _linha(v) -> str:
    return json.dumps(v, ensure_ascii=False)


def formatar_items(items: dict) -> str:
    linhas = [f"  {_linha(k)}: {_linha(v)}" for k, v in items.items()]
    return "{\n" + ",\n".join(linhas) + "\n}\n"


def formatar_trail(trail: list) -> str:
    return "[\n" + ",\n".join("  " + _linha(n) for n in trail) + "\n]\n"


def formatar_school(school: dict) -> str:
    """Mesmo formato do arquivo à mão: uma entrada por linha nas listas."""
    out, chaves = ["{"], list(school.keys())
    for i, k in enumerate(chaves):
        v, virgula = school[k], "," if i < len(chaves) - 1 else ""
        if isinstance(v, list):
            out.append(f"  {_linha(k)}: [")
            out += [f"    {_linha(e)}" + ("," if j < len(v) - 1 else "") for j, e in enumerate(v)]
            out.append("  ]" + virgula)
        elif k == "lessons" and isinstance(v, dict):
            out.append(f"  {_linha(k)}: {{")
            sub = list(v.keys())
            out += [f"    {_linha(s)}: {_linha(v[s])}" + ("," if j < len(sub) - 1 else "") for j, s in enumerate(sub)]
            out.append("  }" + virgula)
        else:
            out.append(f"  {_linha(k)}: {_linha(v)}" + virgula)
    return "\n".join(out + ["}"]) + "\n"


def formatar_arb(arb: dict) -> str:
    return json.dumps(arb, ensure_ascii=False, indent=2) + "\n"


# ------------------------------------------------- código dos nomes


def gerar_labels(items: dict, labels_atual: str) -> str:
    """Reescreve o trecho <painel:itens> do labels.dart a partir do items.json."""
    ini = labels_atual.index("// <painel:itens>")
    ini = labels_atual.index("\n", labels_atual.index("linha por item.", ini)) + 1
    fim = labels_atual.index("    // </painel:itens>")
    # Mantém a ordem atual das linhas (diff mínimo), tira os itens apagados
    # e acrescenta os novos no fim.
    existentes = re.findall(r"^    '([^']+)' => ", labels_atual[ini:fim], re.M)
    ordem = [i for i in existentes if i in items] + [i for i in items if i not in existentes]
    corpo = "".join(f"    '{i}' => l10n.{chave_nome(i)},\n" for i in ordem)
    return labels_atual[:ini] + corpo + labels_atual[fim:]


# ------------------------------------------------------------- salvar


def salvar(conteudo: dict) -> list[str]:
    """Valida e grava tudo. Não grava nada se houver erro."""
    erros = validar(conteudo)
    if erros:
        return erros
    (CONTEUDO / "items.json").write_text(formatar_items(conteudo["items"]), "utf-8")
    (CONTEUDO / "trail.json").write_text(formatar_trail(conteudo["trail"]), "utf-8")
    (CONTEUDO / "school.json").write_text(formatar_school(conteudo["school"]), "utf-8")
    for c, arb in conteudo["arb"].items():
        (L10N / f"app_{c}.arb").write_text(formatar_arb(arb), "utf-8")
    LABELS.write_text(gerar_labels(conteudo["items"], LABELS.read_text("utf-8")), "utf-8")
    return []


# ------------------------------------------------------ flutter / git


def _flutter() -> str:
    local = Path.home() / "flutter-sdk" / "bin" / "flutter"
    return str(local) if local.exists() else "flutter"


def gerar_traducoes() -> tuple[bool, str]:
    r = subprocess.run([_flutter(), "gen-l10n"], cwd=CLIENT, capture_output=True, text=True, timeout=300)
    return r.returncode == 0, (r.stdout + r.stderr)[-2000:]


def rodar_testes() -> tuple[bool, str]:
    ok, log = gerar_traducoes()
    if not ok:
        return False, log
    r = subprocess.run([_flutter(), "test"], cwd=CLIENT, capture_output=True, text=True, timeout=900)
    linhas = (r.stdout + r.stderr).strip().splitlines()
    falhas = [l for l in linhas if l.rstrip().endswith("[E]")]
    resumo = "\n".join(falhas[-15:] + linhas[-1:])
    return r.returncode == 0, resumo


def mudancas_git() -> str:
    r = subprocess.run(["git", "status", "--short", "--", "client/assets/content", "client/lib/l10n", "client/lib/content/labels.dart"],
                       cwd=RAIZ, capture_output=True, text=True)
    return r.stdout.strip()
