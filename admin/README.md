# Painel Admin do Genius Kiddo

Ferramenta **só para o Rhoney**, que roda **só no computador dele**. Não vai para dentro do app, não fica na internet e não lê nenhum dado das crianças.

## Abrir

```bash
cd ~/Documentos/MyApps/geniuskiddo
python3 admin/painel.py
```

Depois abra **http://127.0.0.1:8765** no navegador. Para fechar, use `Ctrl+C` no terminal.

Não precisa instalar nada: usa só o Python que já vem no Linux. O botão "Rodar testes do app" usa o Flutter em `~/flutter-sdk`.

## O que dá para fazer (Parte A, sem internet)

| Aba | O que muda |
|---|---|
| **Itens** | Figuras do app: emoji, nome em cada idioma e gênero por idioma (— no idioma sem gênero, como o inglês). Dá para **criar um item novo**: o painel liga o nome no código (`client/lib/content/labels.dart`) e gera as traduções. |
| **Trilha** | As 8 etapas em ordem (a próxima só abre quando a anterior termina): tipo, arte ou glifo, itens, rodadas e título em cada idioma. Artes e glifos novos precisam de código, então só dá para escolher os que já existem. |
| **Escola** | Economia (estrelas, custos), espaços (série, ícone, visual por nível, nome e descrição), objetivos do ano, parâmetros das aulas (rodadas, figuras da Biblioteca, frutas e legumes, arte do Ateliê) e bichinhos por região. |
| **Mapa** | O mapa da escola desenhado: **arraste um terreno** para mudar a posição. Também muda o tamanho do mundo e as regiões das séries. |
| **Textos** | Todos os textos do app, um idioma por coluna (o português é o modelo), com busca. Vazio fica em vermelho. |

Botões do topo:

- **Validar:** confere tudo com as mesmas regras dos testes do app (figura usada existe, nome em todos os idiomas, terreno dentro do mundo e sem sobrepor, tradução sem marcador inventado, Biblioteca com 4 iniciais por idioma…).
- **Salvar:** valida e, só se estiver tudo certo, grava os arquivos e gera as traduções. **O commit fica com você:** o painel mostra quais arquivos mudaram.
- **Rodar testes do app:** roda a suíte completa do Flutter (1 a 2 minutos).
- **Recarregar dos arquivos:** descarta o que não foi salvo.

Depois de salvar, gere um APK ou AAB novo para ver a mudança no celular. Para os testers receberem, aumente a versão em `client/pubspec.yaml` (ex.: `1.0.1+2`).

## Segurança

- Escuta só em `127.0.0.1`: nada de fora do computador alcança o painel.
- Confere o cabeçalho `Host` e exige o cabeçalho `X-Painel` em toda gravação, então um site aberto no navegador não consegue mandar o painel salvar nada.
- Credenciais do Google (Parte B) ficam em `admin/secrets/`, fora do git.

## Parte B: números do Google Play (próxima etapa)

Vai entrar depois que o app estiver no Google Play (teste interno). Ele lê só os números que o próprio Google mede: instalações por país e por versão do Android, travamentos e a contagem regressiva do teste fechado. Nunca lê nada do app da criança. Precisa de uma configuração única no Google Cloud (projeto **sem faturamento**) e no Play Console; o passo a passo vem junto.

## Testes do painel

```bash
python3 -m unittest discover -s admin/tests
```
