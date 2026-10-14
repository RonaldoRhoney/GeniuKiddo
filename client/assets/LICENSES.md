# Licenças de ativos — Genius Kiddo

Registro exigido pela seção 12.5 (item de aceite de conformidade) e R12 da especificação
formal: toda fonte, imagem, som e música usada no app precisa de licença e origem registradas.

## Fonte

| Ativo | Origem | Licença | Arquivo |
|---|---|---|---|
| Baloo 2 (fonte variável, pesos 500/700/800 usados) | [Google Fonts](https://fonts.google.com/specimen/Baloo+2), repositório oficial [google/fonts](https://github.com/google/fonts/tree/main/ofl/baloo2) | SIL Open Font License 1.1 (OFL) | `assets/fonts/Baloo2-Variable.ttf`, texto da licença em `assets/fonts/OFL.txt` |

Empacotada localmente no app (nunca carregada de `fonts.googleapis.com`), por exigência de R3
(zero requisição de rede na área da criança) e da seção 9.3 da especificação.

## Ícones, artes, sons e músicas

Nenhum ativo final (ilustrações originais, sons gravados, músicas compostas) foi adicionado
ainda — Fase 1/2 do roadmap técnico (M1) usa só placeholders de código (formas geométricas via
`CustomPainter`/SVG simples, sons sintetizados via `just_audio`/osciladores). Este arquivo deve
ser atualizado assim que cada ativo final entrar no projeto (M8 — Conteúdo e conformidade).
