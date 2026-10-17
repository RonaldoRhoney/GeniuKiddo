"""Testes do núcleo do painel (só leitura dos arquivos reais; nada é gravado).

Rodar:  python3 -m unittest discover -s admin/tests
"""

import copy
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import conteudo as c  # noqa: E402


class ConteudoReal(unittest.TestCase):
    def setUp(self):
        self.d = c.carregar()

    def test_conteudo_atual_e_valido(self):
        self.assertEqual(c.validar(self.d), [])

    def test_salvar_sem_mudancas_gera_arquivos_identicos(self):
        self.assertEqual(c.formatar_items(self.d["items"]), (c.CONTEUDO / "items.json").read_text("utf-8"))
        self.assertEqual(c.formatar_trail(self.d["trail"]), (c.CONTEUDO / "trail.json").read_text("utf-8"))
        self.assertEqual(c.formatar_school(self.d["school"]), (c.CONTEUDO / "school.json").read_text("utf-8"))
        for lang in self.d["idiomas"]:
            self.assertEqual(c.formatar_arb(self.d["arb"][lang]), (c.L10N / f"app_{lang}.arb").read_text("utf-8"))
        labels = c.LABELS.read_text("utf-8")
        self.assertEqual(c.gerar_labels(self.d["items"], labels), labels)


class Validacao(unittest.TestCase):
    def setUp(self):
        self.d = copy.deepcopy(c.carregar())

    def assertErro(self, trecho):
        erros = c.validar(self.d)
        self.assertTrue(any(trecho in e for e in erros), f"esperava '{trecho}' em {erros}")

    def test_item_usado_que_nao_existe(self):
        self.d["trail"][1]["items"].append("unicornio")
        self.assertErro("'unicornio' não existe")

    def test_item_sem_nome_num_idioma(self):
        self.d["items"]["rabbit"] = {"emoji": "🐰", "gender": {"pt": "m"}}
        self.d["arb"]["pt"]["itemRabbit"] = "coelho"
        self.assertErro("sem nome em 'en'")

    def test_genero_invalido(self):
        self.d["items"]["dog"]["gender"]["pt"] = "x"
        self.assertErro("gênero 'x' inválido")

    def test_terrenos_sobrepostos(self):
        sala = self.d["school"]["spaces"][0]
        horta = self.d["school"]["spaces"][1]
        horta["x"], horta["y"] = sala["x"] + 10, sala["y"] + 10
        self.assertErro("terrenos sobrepostos")

    def test_terreno_fora_do_mundo(self):
        self.d["school"]["spaces"][0]["x"] = 5
        self.assertErro("sai do mundo")

    def test_traducao_faltando(self):
        del self.d["arb"]["en"]["schoolBuilt"]
        self.assertErro("Texto 'schoolBuilt': falta em 'en'")

    def test_marcador_inventado_na_traducao(self):
        self.d["arb"]["en"]["schoolBuilt"] = "So pretty, {nome}!"
        self.assertErro("marcador {nome}")

    def test_ingles_pode_ignorar_o_genero(self):
        # "Tap the {name}!" não usa {gender}: válido pra idioma sem gênero.
        self.assertNotIn("listenPrompt", " ".join(c.validar(self.d)))

    def test_arte_desconhecida(self):
        self.d["trail"][0]["art"] = "castelo"
        self.assertErro("arte 'castelo' não existe")


class Codigo(unittest.TestCase):
    def test_item_novo_entra_no_fim_e_apagado_sai(self):
        d = c.carregar()
        labels = c.LABELS.read_text("utf-8")
        items = dict(d["items"])
        items["rabbit"] = {"emoji": "🐰"}
        del items["dog"]
        novo = c.gerar_labels(items, labels)
        self.assertIn("'rabbit' => l10n.itemRabbit,", novo)
        self.assertNotIn("'dog' =>", novo)
        self.assertIn("'circle' => l10n.shapeCircle,", novo)
        # Fora do trecho marcado, nada muda.
        self.assertTrue(novo.startswith(labels[: labels.index("<painel:itens>")]))
        self.assertIn("_ => throw StateError", novo)


if __name__ == "__main__":
    unittest.main()
