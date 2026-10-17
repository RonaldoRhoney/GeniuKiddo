# Licenças de ativos — Genius Kiddo

Registro exigido pela seção 12.5 (item de aceite de conformidade) e R12 da especificação
formal: toda fonte, imagem, som e música usada no app precisa de licença e origem registradas.

## Fonte

| Ativo | Origem | Licença | Arquivo |
|---|---|---|---|
| Baloo 2 (fonte variável, pesos 500/700/800 usados) | [Google Fonts](https://fonts.google.com/specimen/Baloo+2), repositório oficial [google/fonts](https://github.com/google/fonts/tree/main/ofl/baloo2) | SIL Open Font License 1.1 (OFL) | `assets/fonts/Baloo2-Variable.ttf`, texto da licença em `assets/fonts/OFL.txt` |

Empacotada localmente no app (nunca carregada de `fonts.googleapis.com`), por exigência de R3
(zero requisição de rede na área da criança) e da seção 9.3 da especificação.

## Efeitos sonoros e música de fundo (M3)

| Ativo | Origem | Licença | Arquivo |
|---|---|---|---|
| `pop`, `good`, `win`, `oops`, `build` (efeitos curtos) e `pad0`–`pad3` (notas do Pátio: 262, 330, 392 e 523 Hz) | Gerados por síntese (osciladores senoidais/triangulares), mesmo desenho sonoro já aprovado nos protótipos HTML — renderizados em WAV por `tool/gen_audio.py` | Autoria própria (RhoneyInc) — nenhum conteúdo de terceiros, nenhuma licença externa envolvida | `assets/sfx/*.wav` |
| `music_loop.wav` (trilha de fundo em loop) | Mesma melodia/harmonia pentatônica já codificada nos protótipos, renderizada em WAV pelo mesmo script | Autoria própria (RhoneyInc) | `assets/music/music_loop.wav` |

**Interino, não final.** Seção 4.4 da especificação: "no app final, usar trilhas originais
GRAVADAS" — o áudio acima é sintetizado por código, não uma gravação/composição de verdade.
Serve pra M3 entregar som real e testável agora, sem esperar produção musical. Troca pelos
ativos finais (composição/gravação profissional) é trabalho do M8 — Conteúdo e conformidade —
e não deve exigir nenhuma mudança de código, só substituir os arquivos nos mesmos caminhos.

## Ícones e artes

Nenhuma ilustração final foi adicionada ainda — a Fase 1 usa placeholders de código (formas
geométricas via `CustomPainter`, emoji do sistema como substituto de ilustração). Entra no M8.

### Ícone do app (launcher)

| Ativo | Origem | Licença | Arquivo |
|---|---|---|---|
| Ícone do app (rosto do Kiddo) | Desenhado por código (`tool/gen_app_icon.py`, Pillow), mesmas cores/coordenadas de `app/guide_avatar.dart` | Autoria própria (RhoneyInc) | `assets/icon/icon.png`, `assets/icon/icon_foreground.png` |

Aplicado aos ícones nativos do Android via `flutter_launcher_icons` (pacote dev, MIT, só gera os
PNGs em build-time — não entra no app compilado, sem rede). Interino como o resto da identidade
visual: troca por arte final ilustrada é trabalho do M8, sem mudar o fluxo de geração.
