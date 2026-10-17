# Genius Kiddo — Roteiro do Play Console

Checklist para subir o app (conta pessoal), com as respostas baseadas no comportamento real do app em 17/10/2026. Conferido contra o checklist RhoneyInc de políticas do Google Play e a timeline oficial de políticas (sem aviso novo em outubro de 2026; o prazo de 28/10 só afeta chat anônimo e permissão de contatos).

## 0. Antes de começar

- [ ] **Verificação de desenvolvedor (Brasil, desde 30/09/2026):** conferir no Play Console (Home) se não há pendência.
- [ ] **Nome "Genius Kiddo":** conferir disponibilidade na Play, no INPI e no Registro.br (pendente na especificação).
- [ ] **E-mail de suporte dedicado ao app** (a conta pessoal expõe o contato na ficha).
- [ ] **Política de privacidade publicada numa URL pública:** o texto está em `docs/legal/politica-de-privacidade.md`. Falta escolher onde hospedar e preencher o e-mail de contato.

## 1. Arquivo para enviar

- **AAB:** `client/build/app/outputs/bundle/release/app-release.aab`
- **Assinatura:** chave de envio em `client/android/keystore/genius-kiddo-release.jks`, com as senhas em `client/android/key.properties`. Nenhum dos dois vai para o git. **Faça cópia de segurança dos dois fora do computador** (pendrive, cofre de senhas). Sem eles, as próximas versões não podem ser enviadas com a mesma chave.
- Ativar a **Assinatura de apps do Google Play** (o Google guarda a chave final; a sua é só a de envio).
- `applicationId`: `com.rhoneyinc.genius_kiddo` · versão 1.0.0 (código 1) · API alvo 36 · mínima 24.
- **Permissões no manifesto final:** nenhuma permissão perigosa, e **sem INTERNET** e sem ACCESS_NETWORK_STATE (removida). Fica só uma permissão interna do AndroidX (`DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`), que não é visível ao usuário.

## 2. Conteúdo do app (Política do app)

| Formulário | Resposta |
|---|---|
| **Política de privacidade** | URL pública da política (seção 0). |
| **Anúncios** | O app **não contém anúncios**. |
| **Acesso ao app** | **Todo o app está disponível sem restrições** (não há login). A área dos pais abre segurando o botão "🔒 Pais" por 2 segundos — vale explicar isso no campo de instruções, para o revisor. |
| **Classificação de conteúdo** | Categoria **Educação / Referência**. Sem violência, sem conteúdo sexual, sem linguagem imprópria, sem drogas, sem apostas, **sem interação entre usuários**, **sem compartilhamento de localização**, **sem compras digitais**. Resultado esperado: Livre (L) / PEGI 3 / Everyone. |
| **Público-alvo e conteúdo** | Faixa **"5 anos ou menos"** (o app é para 3 a 5 anos). Isso coloca o app na **Política de Famílias**: sem anúncios, sem SDK de coleta, sem dados pessoais — todos já atendidos. |
| **Segurança dos dados** | **"O app não coleta nem compartilha nenhum dos tipos de dados exigidos."** Tudo fica no aparelho (preferências e progresso) e nada é transmitido. Criptografia em trânsito: não se aplica (não há transmissão). Exclusão de dados: não há conta; desinstalar ou limpar os dados do app apaga tudo. |
| **App de notícias / COVID / governo / financeiro / saúde** | Não. |
| **Recursos de IA de terceiros** | Não há (nenhuma IA embutida). |

## 3. Ficha da loja

- [ ] **Nome:** Genius Kiddo
- [ ] **Descrição curta** (até 80 caracteres), ex.: "Atividades e uma escolinha para crianças de 3 a 5 anos, sem internet."
- [ ] **Descrição completa:** trilha de 8 atividades, Escolinha que cresce com a série (Maternal, Pré I, Pré II), voz do Kiddo em português e inglês, sem anúncios, sem internet, sem coleta de dados, controle dos pais com pausa para descansar.
- [ ] **Ícone 512 × 512** (gerar a partir de `client/assets/icon/icon.png`).
- [ ] **Imagem de destaque 1024 × 500.**
- [ ] **Capturas de tela do celular** (mínimo 2): menu inicial, trilha, mapa da escola, uma aula, controle dos pais.
- [ ] **Categoria:** Educação. **Tags:** educação infantil.
- [ ] **E-mail de contato:** o e-mail de suporte dedicado.

## 4. Teste fechado (obrigatório para conta pessoal)

- No mínimo **12 testers inscritos por 14 dias contínuos** antes de pedir produção (se cair abaixo de 12, o prazo reinicia).
- Plano da especificação (seção 13): reunir **15 a 20 adultos** (pais, professores, conhecidos). Crianças não precisam ser testers. Não contratar serviço pago de testers.
- Antes do teste fechado, a especificação pede o **teste de usabilidade com 3 a 5 crianças de 3 a 5 anos**, com os pais.
- O app continua evoluindo durante o teste (mesmo modelo do MENTAL); cada nova versão precisa de **código de versão maior** no `pubspec.yaml` (`version: 1.0.1+2`, e assim por diante).

## 5. Pendências que ainda são do M8

- Vozes gravadas, músicas e artes finais, com licença registrada em `client/assets/LICENSES.md`.
- Link da política dentro do app (hoje o Controle dos pais mostra só o resumo; o link entra quando a URL existir, aberto fora do app e só depois do portão).
- Comprimir a música de fundo (WAV), que é a maior parte dos 53,8 MB do AAB.
