# Genius Kiddo — Especificação Formal de Produto e Implementação

| Campo | Valor |
|---|---|
| **Versão** | 1.4 (atualizada por solicitação do Rhoney) |
| **Data** | 16/10/2026 |
| **Responsável** | Rhoney (Ronaldo Martins), RhoneyInc |
| **Destinatário** | Claude Code (implementação) |
| **Substitui** | A versão 1.0 deste documento, o rascunho `GENIUS_KIDDO_SPEC.md` e as anotações de conversa. Este é o único documento válido |
| **Referências visuais** | Protótipos HTML da Fase 1 e da Fase 2 (Anexo D) |

> **Convenção de status.** Cada requisito indica seu estado:
> **[DEFINIDO]** = decidido e pronto para implementar.
> **[PLANEJADO]** = decidido em conceito, mas ainda sem detalhamento final; exige plano aprovado antes de implementar.
> **[PENDENTE]** = depende de decisão do Rhoney. Não presuma.

### Histórico de versões
| Versão | Data | Mudanças |
|---|---|---|
| 1.0 | 13/10/2026 | Primeira versão formal consolidada (histórico, restrições, Fases 1 a 3, regras transversais, arquitetura, conformidade, roadmap) |
| 1.1 | 14/10/2026 | **Rabisco livre** ganha botão ✓ de conclusão (RF-06, RT-08, seção 6.10). **Fase 3 detalhada** (seção 8): subfases 3A e 3B, identidade e consentimento, tarefas do professor, ajuda entre alunos, custo, dados e retenção. Roadmap com M10 e M11. ADR 014 e 015 |
| 1.2 | 16/10/2026 | **Liberação em ordem** dentro de cada fase (RT-09, seção 4.12): na escola, espaços, aulas e objetivos abrem um de cada vez (seções 6.6 e 6.7, Anexo B). **RF-FASE-02** definido para a Fase 2 (libera ao concluir as 8 etapas). Decisões do M5: estrelas da escola separadas das da trilha, escolha da série atrás do portão, entrada 🏫 na trilha. **Voz** em pt-BR só com voz da região exata e sem internet (seção 4.3). **Estrutura para novos idiomas** (seções 4.5 e 10). Frases novas no Anexo C. ADR 016 e 017 |
| 1.3 | 16/10/2026 | **Menu inicial** (seção 5.1): nova raiz da navegação, com Trilha, Escolinha e Rabisco livre; trilha e escola ganham 🏠 para voltar a ele. **Sair do app** na área dos pais, atrás do portão (seção 4.7). Botão voltar do Android detalhado (seção 4.10). Entrada da Escolinha passa da trilha para o menu (RF-FASE-02) |
| 1.4 | 16/10/2026 | **Mundo explorável decidido: mapa livre** (seção 7, ADR 012). Detalhamento implementado no M6: mapa como dado, caminho na ordem de liberação, regiões por série cobertas por nuvens, seta de borda e botão 🎯, mãozinha de arrastar, vida no cenário |

---

## 0. Regras de trabalho para o Claude Code

1. **Plano antes do código.** Em cada marco (seção 15), apresente primeiro um plano curto (arquivos, pacotes, riscos, estimativa) e **aguarde aprovação** antes de escrever código.
2. **Documentos só sob pedido.** Não crie nem altere documentos de especificação, ADRs ou arquivos de documentação formal sem pedido explícito do Rhoney. Documentação técnica de código (comentários, README de build) é permitida.
3. **Idioma.** Converse sempre em português do Brasil. Comentários e mensagens de commit em português; nomes de código (classes, funções, chaves) em inglês.
4. **Custo zero.** Não adicione serviço pago, API paga, SDK de terceiros ou backend sem aprovação explícita.
5. **Aprovação de dependências.** Antes de adicionar qualquer pacote, informe: nome, licença, função, se acessa rede, se coleta identificadores. Pacotes proibidos estão na seção 11.3.
6. **Os protótipos são referência de comportamento, não de código.** Reproduza fluxo, parâmetros (anexos A e B) e identidade visual. Não copie o JavaScript.
7. **Itens [PENDENTE] e [PLANEJADO]** não devem ser implementados sem confirmação.
8. **Conformidade é requisito de aceitação** (seção 12), não etapa final. Qualquer funcionalidade que viole a seção 2 deve ser sinalizada e não implementada.
9. **As regras transversais (seção 4) valem para todas as fases**, atuais e futuras, e devem ser implementadas de forma centralizada.
10. **Commits pequenos e testados.** Cada marco termina com o checklist de aceite cumprido.

---

## 1. Visão e contexto

### 1.1 Produto
**Genius Kiddo** é um aplicativo infantil educativo, bilíngue (português e inglês), em que a criança **aprende brincando**: pinta, traça, ouve, associa, conta, repete palavras e, na Fase 2, **constrói e evolui a própria escolinha** acompanhando a sua série. Um personagem-guia (um gênio simpático), música de fundo, recompensas e feedback imediato conduzem tudo, **sem depender de leitura**. A intenção é ser extremamente intuitivo e de fácil uso.

### 1.2 Como a ideia evoluiu (síntese do histórico)
1. **Conceito inicial:** app com toda a lógica de pintar, cobrir, colorir, ouvir e falar, com musiquinhas de fundo, para a criança aprender brincando.
2. **Nome:** a criatividade da criança era o tema; após explorar alternativas, o Rhoney escolheu **Genius Kiddo**. A busca mostrou muitos apps com "Genius" e "Kids/Kiddo" (inclusive "Tiny Genius", "Little Genius", "Genius Kids"). Não foi encontrado app com o nome exato, mas o entorno é saturado, o que dificulta a busca na loja e o registro de marca.
3. **Restrições de produto:** custo zero de implementação, conformidade com Google Play, LGPD e legislação brasileira e estrangeira, **sem login para a criança**, Android + web, paleta de cores coerente com o propósito.
4. **Público:** crianças **a partir de 3 anos** (faixa de 3 a 5 anos, declarada como "5 anos ou menos" na Google Play).
5. **Publicação:** conta **pessoal** do desenvolvedor na Google Play (sem CNPJ), sujeita ao **teste fechado** de 12 testers por 14 dias.
6. **Bilíngue e progressivo:** app construído em português, com troca para inglês a qualquer momento (todo o conteúdo do idioma escolhido), e conteúdo liberado conforme a criança avança.
7. **Protótipo da Fase 1** (trilha de atividades) aprovado e implantado; voz ajustada para um tom mais infantil e amigável.
8. **Fase 2 — Escolinha:** inspirada nos jogos de fazenda, a criança constrói a escola aos poucos, evoluindo com a série (Maternal, Pré I, Pré II). Protótipo aprovado.
9. **Fase 3 (conceito detalhado):** Modo Turma opcional com **tarefas deixadas pelo professor** (3A) e **ajuda entre alunos** com pontos divididos (3B), com liberação sequencial das fases. O desenho foi refinado em conversa; faltam confirmações (seção 8.8).
10. **Regra transversal de áudio:** toda figura tocada fala o próprio nome; toque fora do pedido gera um som de erro sutil. Vale para todas as fases e versões.
11. **Experiência de exploração:** o Rhoney pediu que a escola deixe de ser linear e vire um **mundo que a criança arrasta** para ver outros ambientes, como nos jogos de fazenda. Anotado, a detalhar.
12. **Rabisco livre:** foi verificado que a atividade não tinha botão de conclusão. Adicionado o botão ✓ (RT-08), sem estrela, e aplicado no protótipo da Fase 1.

### 1.3 Público
| Item | Definição |
|---|---|
| **Criança** | A partir de 3 anos (Maternal 3, Pré I 4, Pré II 5). Declaração na Google Play: **"5 anos ou menos"**. Se o escopo incluir 6 anos ou mais (1º ano), rever a declaração e o conteúdo |
| **Comprador/responsável** | Pais, mães e responsáveis (e, na Fase 3, professores e escolas) |

### 1.4 Plataformas, idiomas e distribuição
- **Android** (Google Play) e **Web (PWA)**. iOS fora do escopo inicial.
- **Idiomas:** pt-BR (base) e en-US. Um idioma por vez, nunca misturados na mesma atividade.
- **Distribuição inicial:** somente Brasil. Expansão só após revisão de conformidade internacional.

### 1.5 Objetivos e fora de escopo
**Objetivos:** validar que uma criança de 3 a 5 anos usa o app sozinha; entregar as Fases 1 e 2; funcionar 100% offline, sem coleta de dados e aprovado na Families Policy da Google Play.

**Fora do escopo das Fases 1 e 2:** login de qualquer tipo, backend, sincronização, compras, anúncios, reconhecimento de voz, analytics, conteúdo baixado da rede, iOS, distribuição fora do Brasil, 1º ano ou séries acima do Pré II.

---

## 2. Princípios e restrições inegociáveis

| # | Restrição | Motivo |
|---|---|---|
| R1 | **A criança nunca faz login.** O app abre direto nas brincadeiras | Minimização de dados; usabilidade |
| R2 | **Nenhum dado pessoal é coletado, enviado ou armazenado fora do aparelho** (nas Fases 1 e 2) | LGPD art. 14, ECA Digital, Families Policy |
| R3 | **Funciona 100% offline.** Zero requisições de rede na área da criança (Fases 1 e 2) | Privacidade e custo zero |
| R4 | **Sem anúncios.** Sem SDK de anúncios | Families Policy; ECA Digital |
| R5 | **Sem analytics, sem crash reporting com envio de dados, sem identificador de aparelho** | Families Policy |
| R6 | **O microfone nunca é usado.** A atividade "Falar" é repetição guiada, sem captura de áudio | Privacidade da voz infantil |
| R7 | **Sem localização, contatos, câmera ou permissões sensíveis** | Families Policy |
| R8 | **Sem caixas de recompensa, prêmios aleatórios pagos ou pressão de compra** | ECA Digital; Google Play |
| R9 | **Compras e configurações só atrás do portão dos pais** | Segurança da criança |
| R10 | **Nunca usar "errou", "erro", "incorreto" com a criança.** Feedback sempre encorajador | Princípio pedagógico |
| R11 | **Custo zero de implementação e operação** (exceto a taxa única da conta Google Play) | Decisão de produto |
| R12 | **Nenhum conteúdo de terceiros sem licença comprovada** (músicas, imagens, fontes, sons) | Direitos autorais |
| R13 | **Toda figura tocada fala o próprio nome; toque fora do pedido gera som de erro sutil** (seção 4.1) | Aprendizagem e consistência |
| R14 | **Sem pressão de tempo:** nada decai, nada se perde por ausência, sem sequência ("streak"), sem contagem regressiva, sem notificação para estimular o uso | ECA Digital (limitação de recursos que estendem o uso); bem-estar infantil |
| R15 | **Fases futuras que exijam rede ou dados (Fase 3) são opcionais, desligadas por padrão e ativadas só pelos pais** | ECA Digital; Families Policy |

---

## 3. Modelo de fases do produto

| Fase | Nome | Conteúdo | Estado |
|---|---|---|---|
| **1** | Trilha de atividades | 8 etapas de atividades (pintar, ouvir, associar, traçar, falar) e rabisco livre | [DEFINIDO] |
| **2** | Escolinha do Kiddo | Construir e evoluir a escola por séries, com objetivos e aulas por espaço | [DEFINIDO] |
| **3** | Turma, tarefas do professor e ajuda entre alunos | **3A:** turma e tarefas do professor · **3B:** ajuda entre alunos (Modo Turma opcional) | [PLANEJADO] |

### 3.1 Liberação sequencial (RF-FASE)
- **RF-FASE-01 — A Fase N+1 só é liberada depois que a criança passa pela Fase N.** A regra vale para as fases atuais e futuras ("e assim sucessivamente").
- **RF-FASE-02 — Critério de liberação.** O critério é por **participação**, não por desempenho.
  - **Fase 2 [DEFINIDO]:** libera ao concluir as 8 etapas da Fase 1. Antes disso, o cartão **🏫 Escolinha** do menu inicial (seção 5.1) aparece apagado com 🔒, e tocar nele gera a fala "A Escolinha abre quando você terminar a trilha!". Depois de liberada, as duas fases continuam acessíveis pelo menu.
  - **Fase 3 [PENDENTE]:** proposta de partida, sujeita à confirmação: libera ao concluir a Fase 2 até o primeiro "passar de ano" (Maternal).
- **RF-FASE-03 — Os pais podem liberar manualmente** uma fase na área dos pais (atrás do portão), como já ocorre com "liberar todas as etapas".
- **RF-FASE-04 — A Fase 3 exige, em qualquer caso, o consentimento dos pais** (seção 8), independentemente de a criança já ter passado pela Fase 2.
- **RF-FASE-05 — Padronização de evolução.** Qualquer conteúdo vindo de fora da progressão normal (por exemplo, tarefas do professor ou ajuda de colegas) **deve respeitar a mesma evolução**: só aulas e espaços que a série da criança já liberou, com os mesmos custos e regras.

---

## 4. Regras transversais (valem para TODAS as fases e versões)

### 4.1 Áudio nas figuras (RT)
- **RT-01 — Tocar numa figura fala o nome dela**, no idioma ativo, em qualquer tela onde apareça: animais, objetos, frutas e legumes, formas, letras, números e cores. Vale tanto no acerto quanto no toque fora do pedido.
- **RT-02 — Acerto:** som de acerto, fala o nome primeiro e depois um elogio curto ("Gato! Muito bem!").
- **RT-03 — Toque fora do pedido:** toca um **som de erro sutil**, fala o nome do que foi tocado e repete o pedido ("Cachorro. … Toque no gato!"). Sem a palavra "errou", sem punição e sem perda de estrela. A figura pedida ganha um contorno de dica.
- **RT-04 — Som de erro:** duas notas senoidais graves e descendentes (≈ 247 Hz → 196 Hz), duração total menor que 0,35 s e volume bem abaixo do som de acerto. Nunca buzina, nunca tom agudo ou áspero. Claramente diferente dos sons de acerto (brilhantes e ascendentes).
- **RT-05 — Exceção:** figuras escondidas (a silhueta de "quem é a sombra?") só falam o nome depois de reveladas.
- **RT-06 — Centralização:** implementar em um único serviço (ex.: `ItemFeedback.correct(item)` e `ItemFeedback.wrong(tapped, requested)`) usado por todas as atividades, para a regra não divergir entre fases.
- **RT-07 — Aceite:** cada atividade que exibe figuras entra num checklist com os casos "toque no pedido", "toque fora do pedido" e "toque na figura de exibição", nos dois idiomas.

### 4.2 Personagem-guia
Um gênio simpático e amigável (turbante amarelo com joia coral, corpo roxo, cauda de fumaça azul), sempre visível no topo das telas de trilha, escola e atividade, com balão de fala e botão 🔊 para repetir a última instrução. **Toda instrução é falada** e também exibida no balão (para os pais).

### 4.3 Voz do guia (infantil e amigável)
- **Objetivo:** voz calorosa, aguda e animada, ritmo um pouco lento, frases curtas.
- **MVP (síntese de voz do sistema):**
  - Três tons configuráveis na área dos pais, padrão **"Fofa"**:

    | Tom | Pitch | Velocidade |
    |---|---|---|
    | Suave | 1,45 | 0,95 |
    | Fofa (padrão) | 1,75 | 0,92 |
    | Super fofa | 1,95 | 0,90 |

  - Falar por **frases** (uma utterance por frase), com +0,10 de pitch em frases exclamativas e +0,05 em perguntas.
  - **Seleção automática** da melhor voz do aparelho (preferência por vozes femininas, claras e jovens) e **escolha manual** na área dos pais, com botão "Testar a voz". Preferência salva por idioma.
  - **Região exata da voz:** só usar vozes do idioma **e da região** do idioma ativo (pt-BR nunca cai numa voz pt-PT; en-US nunca numa en-GB). Vozes só do idioma, sem a região exata, ficam como último recurso, quando o aparelho não tiver nenhuma da região. A lista de vozes da área dos pais segue a mesma regra.
  - **Voz sem internet:** preferir vozes do aparelho que funcionam offline (no motor do Google, as de sufixo `-local`; nunca as `-network`), para cumprir R3. No Android, a preferência automática é a voz padrão do motor, versão offline: `pt-br-x-afs-local` (pt-BR) e `en-us-x-sfg-local` (en-US).
  - Algumas vozes do sistema ignoram o pitch. É esperado.
- **Fase de conteúdo (voz gravada):** se existir clipe gravado para `chave + idioma`, tocar o clipe; senão, usar a síntese com o tom escolhido (fallback).
- **Diretrizes de gravação:** tom sorridente, energia alta e gentil, até ~6 palavras por frase, duas tomadas, 44,1 kHz mono, volume normalizado, OGG/Opus no Android. Inglês americano consistente.
- **[PENDENTE]** Quem grava as vozes (Rhoney, voluntário ou outra opção), principalmente o inglês.

### 4.4 Música e efeitos
- **Música de fundo** original, suave, em loop, com botão de silenciar sempre visível, em volume baixo para não competir com a voz.
- **Efeitos curtos:** `pop`, `good`, `win` e `oops` (som de erro sutil, RT-04), além de `build` na Fase 2.
- Pausar tudo quando o app vai para segundo plano; retomar ao voltar.
- **Web:** o áudio só inicia após o primeiro toque (a tela "Toque para começar" cumpre isso).
- Nos protótipos a música é gerada por código (escala pentatônica). No app final, usar **trilhas originais gravadas**, com a mesma sensação calma e alegre.

### 4.5 Idioma
- pt-BR e en-US, **um idioma por vez**. Primeira execução: dois cartões grandes ("Oi!" e "Hi!"), **sem bandeiras** (evita associar idioma a país).
- Troca a qualquer momento pela pílula **Oi! | Hi!** no topo e na área dos pais. Trocar durante uma atividade reinicia essa atividade no novo idioma.
- Mudam: voz, palavras, instruções, nomes das cores e rótulos. **Imagens e animações não contêm texto embutido.**
- **O progresso é compartilhado entre os idiomas** (ADR-003).
- **Novos idiomas virão (ADR-017).** Acrescentar um idioma deve exigir só dados: um arquivo de tradução novo, uma linha na lista central de idiomas (código, saudação, nome nativo e locale da voz) e o gênero dos itens no conteúdo. **Nenhuma tela pode ter regra fixa de idioma** (como "se for inglês, use 'the'"): artigos, concordância e regras de escrita ficam nas traduções (seção 10). Trocar de idioma traduz na hora tudo o que está na tela, inclusive o balão do guia.

### 4.6 Feedback, erro e progressão sem pressão
- Todo toque gera som, movimento ou brilho em até 100 ms.
- **Libera por participação, não por acerto.** Completar a atividade, mesmo com dicas, libera a próxima.
- Tentativas são ilimitadas e sem penalidade. Dicas visuais após o primeiro toque fora do pedido ou após inatividade.
- R14: sem decaimento, sem perda por ausência, sem contagem regressiva.

### 4.7 Área dos pais e portão
- **Portão:** botão que exige **segurar por 2 segundos** (a criança pequena não consegue). Cadeado pequeno no canto da tela, de propósito.
- Conteúdo comum a todas as fases: idioma; música e voz; **tom e escolha da voz** com botão de teste; **pausa para descansar**; progresso; aparência (automático, claro, escuro); resumo de privacidade em linguagem simples; link para política de privacidade e termos (abre fora do app, só após o portão); **Sair do app** (fecha o app; o progresso fica salvo). É o único jeito de fechar o app por dentro, para a criança não sair sem querer (seção 4.10).
- Fase 2 acrescenta: **série da criança** (com troca posterior), **liberar a Escolinha** antes de a trilha terminar (RF-FASE-03) e atalhos de progresso.

### 4.8 Pausa sugerida
Após o tempo configurado de uso contínuo (desligada, 5, 10, **15 padrão** ou 20 min), uma sobreposição com 😴 e a fala "Hora de descansar os olhinhos! Vamos beber água?". Só continua com o portão de segurar (pais). Se uma celebração estiver aberta, adiar a pausa. Implementada no protótipo da Fase 1; **obrigatória no app final** para todas as fases (alinha com a exigência de ferramentas de limite de tempo do ECA Digital).

### 4.9 Persistência local
Salvar localmente, sem dado pessoal: idioma, música, voz, tom, vozes escolhidas, progresso da Fase 1, estado da escola (estrelas, espaços e níveis, aulas, medalhas, série, objetivos resgatados), pausa, tema. **Nenhum identificador do usuário.** Perda de progresso ao reinstalar ou limpar dados é limitação conhecida e aceita nas Fases 1 e 2 (backup opcional só com conta dos pais, em fase futura).

### 4.10 Acessibilidade e segurança da criança
- Alvos de toque grandes (≥ 64 dp na área da criança; ≥ 44 dp nos pais).
- Contraste AA nos textos dos pais; **nunca informar só por cor** (nomes das cores falados e escritos); rótulos semânticos; respeitar "reduzir movimento".
- Tratar o botão voltar do Android: volta para a tela anterior (de uma atividade para a trilha ou a escola; da trilha ou da escola para o menu inicial). **No menu inicial, o voltar não fecha o app.** Sair do app só pela área dos pais, atrás do portão (seção 4.7). Links externos só após o portão.

### 4.11 Atividades livres: conclusão explícita (RT-08)
- **RT-08 — Toda atividade livre (sem objetivo definido, como o rabisco livre) precisa de um botão de conclusão ✓ claro**, grande, verde, no mesmo estilo dos demais botões de conclusão, para a criança saber como "terminar" e seguir.
- O botão fica **apagado enquanto não houver ação da criança** (ex.: tela em branco) e acende no primeiro uso; se tocado apagado, o guia incentiva ("Desenhe um pouquinho primeiro!") com o som sutil de erro (RT-04).
- A conclusão gera uma **celebração curta com ícone próprio da atividade**, sem estrela e sem recompensa, para a atividade continuar livre.
- O botão 🏠 continua como saída rápida.

### 4.12 Liberação em ordem (RT-09)
- **RT-09 — Dentro de cada fase, uma etapa, missão ou aula só desbloqueia quando a anterior for concluída.** Vale para as fases atuais e futuras (inclusive o Mundo explorável e a Fase 3).
- **Fase 1:** a trilha já segue a regra (seção 5.2).
- **Fase 2:** espaços, aulas e objetivos seguem a regra (seções 6.6 e 6.7).
- O item trancado aparece com 🔒; tocar nele gera o som sutil (RT-04) e a fala do guia dizendo o que vem primeiro. Nunca é punição: a sugestão 👆 sempre aponta o próximo passo permitido.
- **Atividades livres** (rabisco livre, RT-08) ficam fora da regra e continuam sempre abertas.
- **Progresso já salvo é respeitado:** o que já foi conquistado ou construído nunca volta a trancar; a regra vale para os próximos passos.

---

## 5. Fase 1 — Trilha de atividades [DEFINIDO]

### 5.1 Mapa de telas
```
Splash ("Toque para começar")
  └─ Escolha de idioma (só na 1ª vez)
       └─ Menu inicial (raiz)
            ├─ 🗺️ Trilha (Fase 1) ── 🏠 volta ao menu
            │    └─ Atividade (pintar | traçar | ouvir | associar | falar)
            ├─ 🏫 Escolinha (Fase 2; 🔒 até liberar, RF-FASE-02) ── 🏠 volta ao menu
            │    ├─ Escolha da série (1ª entrada, atrás do portão)
            │    └─ Aula do espaço
            ├─ 🖍️ Rabisco livre (sempre liberado, RT-08)
            └─ Portão dos pais → Área dos pais (inclui "Sair do app")
Portão dos pais também no canto da trilha e da escola.
Sobreposições: Celebração · Pausa para descansar
```

**Menu inicial.** É a raiz da navegação depois da abertura: o guia dá as boas-vindas ("Oi! Eu sou o Kiddo!" na 1ª vez, "Oi! Que bom te ver!" depois) e cada fase é um cartão grande, com ícone, nome e, na Trilha, o progresso ("8 de 8"). As fases futuras aparecem no menu com 🔒 até serem liberadas (RF-FASE-01 e RT-09). No topo ficam a pílula de idioma, a música, a aparência e o cadeado dos pais. Na trilha, o guia diz "Toque na estrela brilhante!" ou, com a trilha completa, "Você completou a trilha! Quer brincar de novo?".

### 5.2 Trilha (8 etapas)
| # | Tipo | Conteúdo |
|---|---|---|
| 1 | Pintar | Jardim (céu, sol, nuvem, chão, caule, pétalas, miolo) |
| 2 | Ouvir | Cachorro, gato, peixe, passarinho |
| 3 | Associar | Quem é a sombra? (6 itens, 3 rodadas) |
| 4 | Traçar | Número 1 |
| 5 | Falar | Bola, maçã, sol |
| 6 | Pintar | Casinha (céu, chão, parede, telhado, porta, janelas) |
| 7 | Ouvir | Maçã, banana, carro, bola |
| 8 | Traçar | Letra O |

Regras: libera por participação; etapas futuras aparecem **borradas** (mistério), sem cadeado em texto; tocar numa etapa bloqueada gera balanço leve, som suave e fala encorajadora; a etapa atual pulsa com uma mão 👆; **+1 estrela apenas na primeira conclusão**; **rabisco livre e música sempre liberados**.

### 5.3 Atividades
- **RF-01 Pintar por toque.** Desenho SVG com regiões pré-definidas; paleta de 6 cores; tocar na região a preenche; falar o nome da cor ao selecioná-la; concluída quando todas as regiões forem pintadas; dica (região pisca) após 7 s sem interação. Sem traço livre que exija precisão.
- **RF-02 Traçar com caminho imantado.** Caminho tracejado com faixa de tolerância larga; uma estrela segue o dedo; o trecho percorrido é preenchido em amarelo; o avanço só ocorre para frente (sem atalhos). Parâmetros no Anexo A.
- **RF-03 Ouvir e tocar.** 3 rodadas, 4 cartões (2×2), pedido falado ("Toque no gato!"). Segue RT-01 a RT-04.
- **RF-04 Associar (quem é a sombra).** 3 rodadas, silhueta e 3 opções. Acerto revela a figura colorida. Segue RT-05.
- **RF-05 Falar (repetir sem gravar).** 3 palavras; o guia diz a palavra e "agora é com você!"; a criança repete em voz alta e toca num botão grande ✓. Tocar na figura grande repete o nome. Aviso: "O app não grava a voz da criança". **Nenhum acesso ao microfone.**
- **RF-06 Rabisco livre.** Pincel grosso (24 px), 6 cores, botão limpar 🧽; sem salvar nem compartilhar. **Tem botão de conclusão ✓ (RT-08):** grande, verde, no canto inferior direito; fica apagado enquanto a tela está em branco e acende no primeiro traço; apaga de novo ao limpar. Tocar nele em branco: som sutil e fala "Desenhe um pouquinho primeiro!". Tocar depois de desenhar: celebração curta com 🎨 ("Que desenho lindo!"), **sem estrela**, e volta à trilha pelo ▶.

### 5.4 Celebração
Sobreposição com estrela grande, "+1" (só na primeira vez), confete leve, som de vitória, fala de elogio e botão ▶ grande.

---

## 6. Fase 2 — Escolinha do Kiddo [DEFINIDO]

### 6.1 Conceito
A criança **constrói a própria escolinha aos poucos**, como num jogo de fazenda, em ambiente escolar. Cada aula concluída rende estrelas; as estrelas constroem e melhoram espaços; a escola cresce junto com a **série** da criança, que também "passa de ano" ao cumprir objetivos.

### 6.2 Ciclo central
Fazer uma aula (cada espaço hospeda uma) → ganhar estrelas → construir ou melhorar espaços → ver a escola ganhar vida → cumprir objetivos → passar de ano → desbloquear novos espaços.

### 6.3 Séries
| Série | Idade | Espaços disponíveis | Dificuldade |
|---|---|---|---|
| Maternal 🧸 | 3 anos | Sala de aula, Horta, Ateliê de arte | Mais fácil |
| Pré I 🎒 | 4 anos | + Biblioteca, Pátio | Intermediária |
| Pré II 🎓 | 5 anos | + Refeitório | Mais difícil |

- **Escolha da série:** tela exclusiva para os pais, na primeira entrada na escola, **atrás do portão de segurar 2 segundos** (seção 4.7), para a criança não escolher sozinha (três cartões grandes com ícone, nome e idade). Mudança posterior na área dos pais, **sem apagar o que já foi construído**. A série é só uma configuração local; **não se coleta data de nascimento**.
- **[PLANEJADO]** Os espaços e as aulas podem se inspirar nos campos de experiência da BNCC para a educação infantil.

### 6.4 Espaços, aulas e níveis
| Espaço | Aula | Níveis visuais (1 → 3) |
|---|---|---|
| Sala de aula 🏫 | Formas e cores | 🏫 → 🏫🎒 → 🏫🎒🌈 |
| Horta 🌱 | Contar plantinhas | 🌱🌱 → 🥕🌱🥕 → 🌻🥕🌽🍅 |
| Ateliê de arte 🎨 | Pintar | 🖌️ → 🖌️🎨 → 🖼️🎨🖌️ |
| Biblioteca 📚 | Com qual letra começa? | 📖 → 📚📖 → 🏛️📚📖 |
| Pátio ⚽ | Repetir sequência de sons | ⚽ → ⚽🎠 → 🎠⚽🏀 |
| Refeitório 🍽️ | Separar frutas e legumes | 🍽️ → 🍎🍽️ → 🍎🥕🍽️ |

No app final, os emojis são **substituídos por ilustrações originais** (seção 9).

### 6.5 Economia (sem relógio)
- Início: **3 ⭐** e a **Sala de aula já construída (nível 1)**.
- **Aula concluída: +3 ⭐.** Objetivo cumprido: **+2 ⭐** e uma medalha 🏅.
- **Construir** um espaço: 3 ⭐. **Melhorar:** nível 2 custa 6 ⭐; nível 3 custa 10 ⭐.
- Estrelas só vêm de aulas e objetivos, **nunca de tempo real**.
- **As estrelas da escola são um contador próprio**, separado das estrelas da trilha (Fase 1). As estrelas da trilha ficam só na trilha, para a escola começar sempre com as mesmas 3 ⭐.

### 6.6 Interações na escola
- **Espaços em ordem (RT-09):** os espaços abrem na ordem Sala → Horta → Ateliê → Biblioteca → Pátio → Refeitório (ordem do `school.json`). O próximo só abre quando o anterior está **construído e já teve pelo menos 1 aula**. Antes disso aparece apagado com 🔒; tocar gera o som sutil e a fala "Ainda não! Primeiro: {espaço}." No início do jogo, portanto, a criança faz uma aula na Sala antes de construir a Horta.
- **Aulas em ordem (RT-09):** só uma aula fica liberada por vez, a **aula da vez**: primeiro um espaço construído que ainda não teve aula (na ordem); se todos já tiveram, rodízio na ordem dos espaços a partir da última aula feita. Nos outros espaços, **▶ Ter aula** fica apagado e o guia diz "A próxima aula é: {espaço}!".
- **Tocar num espaço construído** abre uma folha inferior com dois botões grandes: **▶ Ter aula** (aceso só na aula da vez) e **⬆️ Melhorar ⭐N** (apagado se faltar estrela). Melhorar um espaço já construído não segue ordem.
- **Tocar num espaço vazio liberado** oferece **🔨 Construir ⭐N**. Sem estrelas suficientes, oferece **▶ Ganhar estrelas**, que leva direto à aula da vez.
- **Espaço de série futura** aparece apagado com o ícone da série; tocar gera balanço leve e fala encorajadora ("Esse espaço chega no Pré I!").
- **Sugestão visível:** o próximo passo permitido pulsa com a mão 👆 (espaço novo da série já liberado, depois construção possível, depois melhoria possível, senão o espaço da aula da vez).
- **Crescimento visível:** animação e faíscas ao construir ou melhorar; a **população de alunos 🧒** cresce com o nível total da escola (máx. 14).
- O botão de melhoria (⬆️) aparece no espaço quando há estrelas suficientes.

### 6.7 Objetivos do ano e passar de ano
- Três objetivos por série, em **🏆 Objetivos** (medalhas 🏅, barra de progresso e botão "pegar ⭐+2" quando cumprido):

| Série | Objetivo 1 | Objetivo 2 | Objetivo 3 |
|---|---|---|---|
| Maternal | Construir 3 espaços | Fazer 6 aulas | Melhorar um espaço |
| Pré I | Construir 5 espaços | Fazer 12 aulas | Deixar um espaço no máximo |
| Pré II | Construir 6 espaços | Fazer 18 aulas | Deixar 2 espaços no máximo |

- **Objetivos em ordem (RT-09):** o objetivo 2 só fica disponível depois que o objetivo 1 for resgatado, e o 3 depois do 2. Os trancados aparecem com 🔒, sem barra e sem botão de resgatar.
- Contagem de aulas é **por ano** (reinicia ao passar de série). Contagem de espaços e níveis é absoluta.
- Com os 3 objetivos resgatados, aparece **🎓 Passar de ano**: cerimônia com confete, nova série, **objetivos reiniciados** e novos espaços brilhando como "novos". No Pré II, o mesmo botão vira **Formatura** (mensagem de conclusão; o 1º ano fica como "em breve").
- Após a formatura, tudo continua jogável.

### 6.8 Detalhe das aulas (por série)
- **Sala (formas e cores):** Maternal — 3 formas com cores fixas (círculo, quadrado, triângulo), pedido só pela forma. Pré I — 4 formas com cores variadas, pedido pela forma. Pré II — pedido por **forma + cor** ("o quadrado azul") entre 4 opções, só uma correta. 3 rodadas. Fala o nome da forma ao toque (RT).
- **Horta (contar):** a criança toca nas plantinhas para contar (aparece o número e a fala "um, dois, três…") e escolhe o número. Maternal conta 1–3; Pré I 1–5; Pré II 3–9. 3 rodadas; acerto faz as plantinhas crescerem (🌱 → 🌻).
- **Ateliê (pintar):** arte por série (flor, casinha, jardim). Mesmo comportamento do RF-01.
- **Biblioteca (letras):** mostra uma figura e 3 (Pré I) ou 4 (Pré II) letras; acerto fala "Cachorro começa com C!". 3 rodadas.
- **Pátio (sequência de sons):** 4 botões coloridos com símbolos e notas. Pré I repete sequências de 2 e 3; Pré II de 3 e 4. **Erro apenas repete a sequência**, sem falha. 2 rodadas.
- **Refeitório (separar):** 5 itens (3 frutas, 2 legumes) e duas cestas rotuladas; item errado volta com o som sutil e dica na cesta certa.
- Todas seguem as regras transversais (seção 4).

### 6.9 Pontos de atenção
- Construção por **toque em lotes prontos**, não arrastar livremente, para funcionar aos 3 anos.
- **Sem notificações** e **sem mecânica de volta diária** (R14).
- O protótipo da Fase 2 ainda é uma grade linear; a experiência de mundo explorável está na seção 7.

### 6.10 Rabisco livre na escola [PLANEJADO]
O protótipo da Fase 2 não inclui desenho livre. Se for incluído (por exemplo, no Ateliê de arte ou como atividade sempre liberada), **herda o RF-06 e o RT-08**: botão ✓ de conclusão, celebração sem estrela e nenhuma interferência na economia da escola.

---

## 7. Mundo explorável (a criança arrasta para ver os ambientes) [DEFINIDO: mapa livre]

**Motivação:** o Rhoney achou o app muito linear. A escola deve funcionar como nos jogos de fazenda: a criança **puxa e arrasta** para descobrir outros ambientes do terreno.

Requisitos candidatos (a detalhar e aprovar em plano antes de implementar):
- **RM-01 — O mundo é maior que a tela.** Arrastar com o dedo, com **inércia**, e fundo em camadas (nuvens e colinas) para dar profundidade.
- **RM-02 — Dica de arrastar.** Mãozinha animada na primeira vez e setas suaves nas bordas. Arrastar é habilidade motora em desenvolvimento aos 3 anos.
- **RM-03 — Plano B sem arrastar.** Tocar numa seta ou num ícone do ambiente leva a câmera até lá; o botão "ir ao espaço brilhante" também move a câmera sozinho.
- **RM-04 — Sem zoom por pinça** (difícil nessa idade). A escala fica fixa.
- **RM-05 — Terrenos fixos** para construir (sem posicionamento livre).
- **RM-06 — O mundo cresce com a série.** Áreas novas aparecem ao passar de ano.
- **RM-07 — Vida no cenário.** Alunos e bichinhos que, ao serem tocados, falam o nome (RT-01).
- **RM-08 — Acessibilidade e motricidade:** nenhum conteúdo essencial pode depender só de arrastar (RM-03).
- **Decisão (16/10/2026): mapa livre** (arrastar em todas as direções), escolhido pelo Rhoney em vez da faixa horizontal. Como o mapa livre é mais difícil aos 3 anos e facilita se perder, o desenho abaixo compensa isso com câmera que ajuda e regiões fechadas por nuvens.

### 7.1 Como o mapa livre funciona (M6)
- **Mapa como dado.** Tamanho do mundo, lado do terreno, posição (x, y) de cada espaço e retângulo de cada série ficam no `school.json`; nenhuma tela tem posição fixa no código. Teste automatizado confere que os terrenos cabem no mundo, não se sobrepõem e ficam na região da própria série.
- **Arranjo das séries:** Maternal no centro, Pré I à direita, Pré II acima. Mundo de cerca de 1300 × 2000 unidades (≈ 3 × 3 telas de celular), escala fixa.
- **Caminho na ordem de liberação (RT-09).** Um caminho de terra liga os espaços na ordem do `school.json` (Sala → Horta → Ateliê → Biblioteca → Pátio → Refeitório), então o próximo passo aparece no próprio mapa.
- **Séries futuras sob nuvens (RM-06).** A região de cada série acima da atual fica coberta por nuvens; tocar nelas faz o guia dizer quando aquela área chega. Ao passar de ano, as nuvens se abrem e a câmera vai até o espaço novo.
- **Câmera que ajuda (RM-03/RM-08).** Ao entrar, a câmera mostra o espaço brilhante. Quando ele sai da tela, uma **seta amarela na borda** aponta para ele, e tocar nela leva a câmera até lá; o botão **🎯** faz o mesmo a qualquer momento. Depois de uma aula, a câmera volta ao espaço brilhante se ele estiver fora da tela. Com "reduzir movimento", a câmera pula em vez de voar.
- **Dica de arrastar (RM-02).** Na primeira vez, uma mãozinha desenha um "8" sobre o mapa e o guia diz "Arraste o dedo para ver a escola!"; some no primeiro arrasto e não volta (salvo no aparelho).
- **Vida no cenário (RM-07).** Bichinhos passeiam nas regiões abertas (Maternal: cachorro, gato, pato; Pré I: passarinho, sapo; Pré II: abelha, vaca) e falam o nome ao toque (RT-01). Alunos passeiam em volta dos espaços construídos, na quantidade do Anexo B, e cumprimentam ao toque. Com "reduzir movimento", ficam parados.
- **Decoração** (árvores, flores, pedras) fixa, longe dos terrenos e do caminho, sem toque e fora do leitor de tela.
- **Aceite pendente:** teste com 3 a 5 crianças de 3 a 5 anos (seção 16), observando se arrastar é natural e se elas se perdem.

---

## 8. Fase 3 — Turma, tarefas do professor e ajuda entre alunos [PLANEJADO]

> Esta fase muda a natureza do app. As Fases 1 e 2 são offline, sem login e sem dados; a Fase 3 exige conta, servidor e dados de criança. Por isso é um **"Modo Turma" opcional, desligado por padrão e ativado só pelos pais** (R15). Nada nesta seção deve ser implementado sem plano aprovado, contrato com escolas e revisão jurídica.

### 8.1 Divisão em subfases [PENDENTE confirmação]
- **3A — Turma e tarefas do professor.** O professor passa lição e a criança joga aulas que já conhece. Não há interação entre crianças, o que reduz o risco legal, e o produto serve às escolas.
- **3B — Ajuda entre alunos.** Entra depois, em cima da turma já existente.

### 8.2 Exigências legais que moldam o desenho
- **ECA Digital:** se o app permitir interação entre usuários, o recurso deve vir **bloqueado por padrão até o consentimento dos pais**; as ferramentas de supervisão parental devem vir no nível mais protetivo por padrão e limitar recompensas por tempo de uso e notificações que estendam o uso.
- **Google Play (Families Policy):** os recursos sociais devem ser declarados no questionário de classificação; é preciso oferecer meio para os adultos ativarem, desativarem ou ajustarem esses recursos; exige-se **ação do adulto antes** de a criança trocar informações pessoais; e um lembrete de segurança online antes da troca de conteúdo livre. Apps focados em conversar com desconhecidos são proibidos para crianças.

### 8.3 Identidade, entrada e consentimento
- **RS-01 — Contas só para adultos.** Pais e professores têm conta. **A criança nunca faz login.**
- **RS-02 — Perfil de aluno anônimo.** Apelido de bichinho e avatar, **sem nome real, foto ou data de nascimento**. A série é o único dado escolar.
- **RS-03 — Entrada na turma** por **código de 6 caracteres** e **aprovação do responsável** atrás do portão dos pais.
- **RS-04 — O servidor nunca conhece o nome real.** O professor mantém, fora do app, a relação entre bichinho e aluno.
- **RS-05 — Consentimento.** O Modo Turma vem desligado; a ativação é feita pelos pais atrás do portão, com explicação em linguagem simples do que será compartilhado. **[PENDENTE]** O método de verificação do consentimento do responsável (ex.: confirmação por e-mail) deve ser definido com assessoria jurídica.
- **RS-06 — Controle parental.** Os pais veem o estado da turma, podem **sair dela** e **solicitar a exclusão dos dados** a qualquer momento.

### 8.4 Tarefas do professor (3A)
- **RS-07 — Painel web do professor** (é o painel administrativo previsto desde o início): login por e-mail, criação da turma e geração do código.
- **RS-08 — Catálogo de tarefas.** O professor escolhe lições do catálogo, **filtradas pela série dos alunos**, com até 3 tarefas ativas por vez.
- **RS-09 — Caixa de lição 📬** na escola. Sem prazo punitivo; uma indicação "para esta semana" é apenas informativa, sem penalidade.
- **RS-10 — Recompensa.** Concluir a tarefa dá **+2 ⭐ de bônus**, e a aula **conta para os objetivos do ano**, por ser aula do próprio aluno. **[PENDENTE confirmação]**
- **RS-11 — Padronização de evolução (RF-FASE-05).** Se o aluno ainda não construiu o espaço da tarefa, ela mostra 🔨 "construa primeiro". O professor não consegue passar conteúdo acima da série.
- **RS-12 — O professor vê apenas "feito ou não feito"** por bichinho, sem notas, sem ranking e sem comparação entre crianças.
- **RS-13 — Sem ranking público entre crianças** em nenhuma parte da Fase 3.

### 8.5 Ajuda entre alunos (3B)
- **RS-14 — Visita.** Dentro da turma, a criança toca num colega e **visita a escola dele**, só para ver. Não edita espaços nem gasta as estrelas do colega.
- **RS-15 — Tarefinhas de ajuda.** A criança joga 1 ou 2 aulas dos espaços já construídos do colega.
- **RS-16 — Pontos divididos.** Cada ajuda gera **4 ⭐**: 2 imediatas para quem ajudou e 2 na **caixa de presentes 🎁** do dono, abertas na próxima visita dele. O total é positivo e **ninguém perde nada**. **[PENDENTE confirmação]**
- **RS-17 — Limites.** 3 ajudas por dia por criança e 1 por colega por dia. **[PENDENTE confirmação]**
- **RS-18 — Comunicação só por figurinhas prontas** (conjunto fixo, ex.: 8). **Sem texto livre, foto ou voz.**
- **RS-19 — Ausência não é punida.** A ajuda fica **sempre disponível**. A escola sem visita aparece como "descansando 💤", **sem contador de dias e sem notificação** de "sentimos sua falta" (R14). Nota: a ideia original ligava a ajuda a quem passou mais de um dia sem visitar; a recomendação é **não** vincular, para evitar culpa e pressão.
- **RS-20 — A ajuda não conta para os objetivos do ano do dono**, somente estrelas. **[PENDENTE confirmação]**
- **RS-21 — Validação leve em servidor** (limites diários e "bilhete" de aula), já que as estrelas não têm valor monetário.
- **RS-22 — Moderação.** Professor e responsáveis podem remover um membro da turma e desativar a ajuda.

### 8.6 Infraestrutura, custo e dados
- **Backend mínimo.** A Fase 3 é a **primeira fase com custo recorrente**; as regras R3 e R11 valem para as Fases 1 e 2.
- **Serviço gratuito:** o plano gratuito do Supabase costuma ter cerca de 500 MB de banco e 50 mil usuários ativos por mês, e **pausa o projeto após uma semana sem uso**, o que é um risco em férias escolares. O plano pago (cerca de 25 dólares por mês) não pausa. **Confirmar valores e limites na página de preços.** **[PENDENTE]** Definir como o custo será financiado antes do M10.
- **Offline primeiro.** O app continua jogável sem rede e sincroniza quando houver; falha de rede nunca bloqueia o jogo.
- **Servidor** preferencialmente no Brasil (confirmar a disponibilidade da região), por API HTTP simples e **sem SDKs proibidos** (seção 11.3).
- **Inventário de dados da Fase 3:**

| Dado | Coletado? | Observação |
|---|---|---|
| Identificador da turma e do perfil de aluno | Sim | Pseudônimo, sem nome real |
| Apelido de bichinho e avatar | Sim | Escolhidos entre opções prontas |
| Série | Sim | Sem data de nascimento |
| Contadores de progresso e estado das tarefas | Sim | Só o necessário |
| E-mail do responsável e do professor | Sim | Para conta e registro de consentimento |
| Nome real, foto, localização, voz | **Não** | — |

- **Retenção:** apagar a turma e os dados dos alunos ao fim do ano letivo; exclusão sob pedido do responsável.
- **Data safety, política de privacidade e classificação** deixam de dizer "nenhum dado coletado" quando o Modo Turma existir, e devem descrever os dados acima.
- **Alternativa 100% offline (limitada):** "visita" por QR entre dois aparelhos, só presencial e sem validação; serve para sala de aula.

### 8.7 Conformidade da Fase 3
Contrato com escolas (a escola como controladora e o Rhoney como operador), política de privacidade e termos atualizados, retenção limitada, exclusão de dados e **relatório de impacto** por tratar dados de crianças. **Revisão jurídica obrigatória antes do M10.** Sem CNPJ, o licenciamento para escolas fica mais difícil (nota fiscal).

### 8.8 Pontos em aberto da Fase 3
1. Confirmar a divisão 3A (professor e turma) antes de 3B (ajuda entre alunos). **[PENDENTE]**
2. Critério exato de liberação das fases (RF-FASE-02). **[PENDENTE]**
3. Divisão de pontos e limites diários (RS-16 e RS-17). **[PENDENTE]**
4. Se a ajuda conta para os objetivos do ano (RS-20) e se a tarefa do professor conta (RS-10). **[PENDENTE]**
5. Método de verificação do consentimento do responsável (RS-05). **[PENDENTE]**
6. Contas de professor e contrato com escolas. **[PENDENTE]**
7. Como financiar o custo recorrente do servidor. **[PENDENTE]**
8. Se o Modo Turma entra no lançamento ou em versão posterior. **[PENDENTE]**

---

## 9. Design e identidade

### 9.1 Conceito
Gênio mágico e criativo: a magia (roxo e azul) encontra a alegria de criar (amarelo e coral). Fundo creme acolhedor, formas arredondadas, sombras sólidas curtas ("botões de brinquedo"). Na Fase 2, o cenário usa céu, colinas verdes e uma **placa de madeira** com o nome da escola e a série.

### 9.2 Tokens de cor
| Token | Hex | Uso |
|---|---|---|
| `purple` | `#7C5CFF` | Marca, destaques, botões principais |
| `blue` | `#4DA8FF` | Apoio, etapas abertas, idioma inglês |
| `yellow` | `#FFC93C` | Etapa atual, recompensa, progresso |
| `green` | `#4FCB8D` | Concluído, ação positiva (✓) |
| `coral` | `#FF6B6B` | Energia, alerta suave, reiniciar |
| `bg` | `#FFF8E7` | Fundo (creme, nunca branco puro) |
| `ink` | `#2B2D42` | Texto (azul-noite) |
| Tema escuro (opcional) | `bg #1D1A3A`, `card #2F2A5C`, `ink #F4F1FF` | Alternativo |

Paleta de pintura (6): vermelho `#FF5A5F`, azul `#4DA8FF`, amarelo `#FFC93C`, verde `#4FCB8D`, roxo `#7C5CFF`, laranja `#FF9B3D`.

### 9.3 Tipografia
**Baloo 2** (licença OFL), pesos 500, 700 e 800. **Empacotar a fonte no app** (sem carregar de servidor, por R3). Fallback: fonte arredondada do sistema.

### 9.4 Princípios visuais
Poucas cores fortes por tela; navegação por ícones e personagem; textos curtos, só para os pais; movimento apenas para chamar atenção ou responder a um toque, respeitando "reduzir movimento"; nenhuma imagem com palavras embutidas.

---

## 10. Conteúdo e modelo de dados

O conteúdo é **orientado a dados** (adicionar etapa, item ou espaço sem mudar código de tela).

```jsonc
// content/items.json
{ "dog": { "emoji": "🐶", "image": "items/dog.svg", "gender": { "pt": "m" } } }
// gender: gênero gramatical POR IDIOMA ("m"/"f"); idioma sem gênero (inglês) fica de fora

// content/trail.json  (Fase 1)
[ { "id": "paint_garden", "type": "paint", "art": "garden" },
  { "id": "listen_animals", "type": "listen", "items": ["dog","cat","fish","bird"], "rounds": 3 } ]

// content/school.json  (Fase 2)
{ "spaces": [ { "id": "horta", "grade": 0, "lesson": "count", "levels": 3 } ],
  "costs": { "build": 3, "upgrade": [6, 10] }, "reward": 3, "bonus": 2,
  "missions": { "0": [ { "type": "build", "n": 3 } ] } }

// l10n/pt-BR.json e l10n/en-US.json  (chaves iguais nos dois arquivos)
{ "item.dog": "cachorro",
  "prompt.tap": "{gender, select, f{Toque na {name}!} other{Toque no {name}!}}",
  "praise.1": "Muito bem!" }
```

Regras:
- **Chaves de texto iguais nos dois idiomas**; teste automatizado falha se faltar tradução.
- Áudio gravado em `voice/{locale}/{chave}.ogg`; música em `music/`.
- Artes de pintura em SVG com regiões nomeadas.
- **Artigos e concordância ficam nas traduções**, nunca no código: cada item tem `gender` por idioma, e as frases usam mensagens `select` para escolher o artigo ("no gato", "na bola") e a concordância das cores ("a estrela amarela"). Um idioma sem gênero ignora o parâmetro. As formas geométricas também são itens do conteúdo, com nome e gênero por idioma.
- **Regras de escrita por idioma também ficam nas traduções.** Exemplo: na Biblioteca, a letra inicial sai do nome **no idioma ativo** (🍇 é U de uva em pt e G de grape em en), e cada idioma define quais letras com acento contam como a letra base (em pt, "á" conta como "A"; em espanhol, o "ñ" é uma letra própria). As opções erradas vêm só das iniciais do mesmo idioma.
- Teste automatizado garante que todo item tem nome em todos os idiomas suportados.
- Cada item tem registro de **licença e origem** (`assets/LICENSES.md`).

### 10.1 Catálogo de itens (protótipos)
Animais: cachorro (o), gato (o), peixe (o), passarinho (o), sapo (o), pato (o), vaca (a), leão (o), abelha (a), urso (o). Objetos e natureza: carro (o), bola (a), sol (o), flor (a), lua (a), casa (a), ovo (o). Frutas: maçã (a), banana (a), uva (a), morango (o), laranja (a), melancia (a). Legumes: cenoura (a), brócolis (o), batata (a), alface (a), cebola (a). Formas: círculo, quadrado, triângulo (o), estrela (a), coração (o). Cores: vermelho/a, azul, amarelo/a, verde, roxo/a, laranja.

---

## 11. Arquitetura técnica

> **[PENDENTE]** O plano técnico do Marco M0 deve confirmar ou propor alternativa à stack abaixo.

### 11.1 Stack (ADR-001, proposto)
- **Flutter (Dart)**, uma base de código para **Android** e **Web (PWA)**.
- Sem backend nas Fases 1 e 2. Backend mínimo só na Fase 3, se aprovada.
- Estado: solução simples e testável (ex.: Riverpod ou provider), a propor no plano.
- Persistência: armazenamento local de chave-valor.
- Áudio: pacote multiplataforma para música e efeitos; voz do guia via síntese do sistema, com clipes gravados quando existirem.
- Gráficos: `CustomPainter` e SVG para artes e traçado, e câmera arrastável para o mundo (seção 7).

### 11.2 Candidatos a dependências (sujeitas à regra 0.5)
| Função | Candidato | Verificar |
|---|---|---|
| Estado | `flutter_riverpod` ou `provider` | Licença, sem rede |
| Armazenamento local | `shared_preferences` | Sem rede, sem identificadores |
| Áudio | `just_audio` (+ `audio_session`) | Sem rede em uso local; comportamento na web |
| Síntese de voz | `flutter_tts` | Usa o motor do sistema; confirmar que não envia dados na configuração padrão |
| SVG | `flutter_svg` | Licença |
| Internacionalização | `flutter_localizations` + ARB | Nativo |

### 11.3 Proibido
Firebase (qualquer módulo), Google Analytics, AdMob, Facebook/Meta SDK, Sentry ou Crashlytics com envio de dados, `device_info`/`advertising_id`, `geolocator`, `permission_handler` para microfone, câmera ou localização.

### 11.4 Estrutura de pastas sugerida
```
lib/
  app/        # tema, rotas, inicialização
  core/       # persistência, áudio, voz, ItemFeedback, i18n, utilitários
  features/
    splash/ language/ trail/ school/ world/ celebration/ parents/ break/
    activities/ paint/ trace/ listen/ match/ speak/ free_draw/
                shapes/ count/ letters/ rhythm/ sorting/
  content/    # modelos e leitura do JSON
assets/       # content/ art/ music/ sfx/ voice/{pt-BR,en-US}/ fonts/
docs/         # prototype/ LICENSES.md
test/
```

### 11.5 Web (PWA)
- Build Flutter Web com service worker para uso offline, manifest instalável e ícones.
- Sem cookies de terceiros, sem rastreamento, sem fontes externas.
- Hospedagem gratuita **compatível com uso comercial** (ex.: Cloudflare Pages ou GitHub Pages). **Não usar o plano gratuito da Vercel se houver monetização**, pois é voltado a uso não comercial; confirmar os termos.
- Áudio e fala só após o primeiro toque.

---

## 12. Privacidade e conformidade

> Levantamento técnico para orientar o desenvolvimento. **Não substitui revisão jurídica.** Revisar política de privacidade e termos com profissional antes da publicação.

### 12.1 Inventário de dados (Fases 1 e 2)
| Dado | Coletado? | Onde fica |
|---|---|---|
| Nome, e-mail, idade, foto, localização | **Não** | — |
| Voz / áudio da criança | **Não** | — (microfone nunca acionado) |
| Identificadores do aparelho / publicidade | **Não** | — |
| Série da criança | Sim, **local** | Armazenamento do app, sem data de nascimento |
| Progresso, estrelas, escola, preferências | Sim, **local** | Armazenamento do app, não sai do aparelho |
| Tráfego de rede na área da criança | **Nenhum** | — |

### 12.2 Brasil
- **ECA Digital (Lei 15.211/2025).** Sancionada em 17/09/2025, em vigor desde 17/03/2026 e regulamentada por decretos de 18/03/2026. Alcança apps de provável acesso por menores de 18 anos. Pontos relevantes: melhor interesse da criança, gestão de riscos, informação clara, vedação de publicidade direcionada com dados de menores e de perfilamento, vedação de caixas de recompensa, ferramentas de supervisão parental com limite de tempo, e classificação indicativa. Acompanhar a regulamentação da ANPD e **confirmar o texto vigente**.
- **LGPD (Lei 13.709/2018), art. 14.** Tratamento de dados de crianças no melhor interesse, com consentimento específico de um dos pais quando houver coleta. Estratégia: **não coletar** nas Fases 1 e 2.
- **ECA (Lei 8.069/1990), CDC e Marco Civil da Internet** — aplicáveis de forma geral.
- **Direitos autorais (Lei 9.610/1998)** e **acessibilidade (Lei 13.146/2015)** como boas práticas.

### 12.3 Google Play
- Declarar o público em **Target Audience and Content** ("5 anos ou menos"). O app entra na **Families Policy**.
- Sem localização precisa; sem transmissão de identificadores do aparelho da criança; apenas SDKs e APIs permitidos para serviços infantis.
- Preencher **Data safety** com exatidão e informar URL da **política de privacidade** pública.
- Questionário de **classificação de conteúdo** com respostas verdadeiras, declarando recursos sociais quando existirem (Fase 3).
- Ficha da loja **sem promessas enganosas:** o app apoia o aprendizado, sem garantir que a criança ficará bilíngue.
- Sem anúncios; sem compras acessíveis à criança.

### 12.4 Fora do Brasil (somente se houver expansão)
COPPA (EUA), GDPR e GDPR-K (UE), Children's Code (Reino Unido). Lançamento inicial apenas no Brasil (ADR-006).

### 12.5 Itens de aceite de conformidade
- [ ] Captura de rede mostra zero requisições na área da criança (Fases 1 e 2).
- [ ] Manifest sem permissões sensíveis.
- [ ] Nenhuma dependência proibida (11.3) na árvore de pacotes.
- [ ] Política de privacidade e termos publicados em URL pública, em português simples.
- [ ] Data safety e classificação preenchidos.
- [ ] Toda fonte, imagem, som e música com licença registrada em `LICENSES.md`.
- [ ] Portão dos pais protegendo configurações e links externos.
- [ ] Ferramenta de limite de tempo (pausa) ativa e acessível.
- [ ] Nenhuma mecânica de volta diária, notificação de engajamento ou decaimento (R14).

---

## 13. Publicação na Google Play (conta pessoal)

- **Teste fechado obrigatório** para contas pessoais criadas após 13/11/2023: **no mínimo 12 testers, inscritos por 14 dias contínuos**, antes de pedir acesso à produção. O teste interno não conta. Se a contagem cair abaixo de 12, o prazo reinicia.
- As fontes divergem se a exigência vale por app ou apenas até a conta obter acesso à produção. **Confirmar no Play Console.**
- **Plano:** reunir **15 a 20 testers adultos** (pais, professores, conhecidos) **antes** de publicar a versão de teste; crianças não precisam ser testers. **Não contratar serviços pagos de testers.** Testes de vários apps podem rodar em paralelo e o mesmo grupo pode ser reaproveitado.
- Prazo realista: cerca de 3 semanas entre a versão de teste e a produção.
- Antes de lançar, checar a disponibilidade do nome **Genius Kiddo** na Google Play, no INPI e no Registro.br.
- Usar e-mail de suporte dedicado ao app (contas pessoais podem expor dados de contato).
- Alternativa estrutural (não escolhida): conta de organização, isenta do teste, mas exige CNPJ e verificação da empresa.

---

## 14. Monetização (fase futura, fora do MVP)

- Lançar **gratuito** primeiro, para ganhar avaliações. **[PENDENTE]** confirmar se haverá versão paga no lançamento.
- Depois: **compra única** ("Pacote Completo") e/ou pacotes temáticos via **Google Play Billing**, **atrás do portão dos pais**, com linguagem honesta e sem pressão. A compra é restaurada pela conta Google do responsável (não exige login no app).
- Sem anúncios, sem assinatura agressiva, sem caixas de recompensa, sem contagens regressivas.
- Receita como pessoa física: **consultar um contador** antes de ativar vendas.
- Web: gratuita ou limitada até existir conta dos pais.
- Licenças para escolas e creches ficam difíceis sem CNPJ (nota fiscal); reavaliar se o negócio crescer.

---

## 15. Roadmap e critérios de aceite

> "Fase" é de produto (seção 3). "Marco" é de implementação.

| Marco | Entrega | Critérios de aceite |
|---|---|---|
| **M0 — Plano técnico** | Stack, pacotes (com análise da regra 0.5), estrutura, estimativas | Aprovado pelo Rhoney |
| **M1 — Base** | Projeto Flutter, tema, tokens, fonte local, i18n pt/en, persistência, rotas, splash, escolha de idioma, `ItemFeedback` (RT) | Roda em Android e Web; troca de idioma funciona; nenhuma dependência proibida |
| **M2 — Fase 1** | Trilha de 8 etapas, 5 atividades, rabisco livre, celebração, progressão | RF-01 a RF-06 e 5.2 atendidos; parâmetros do Anexo A; RT validado |
| **M3 — Áudio e voz** | Música, efeitos, `VoiceService` (tons, seleção de voz, fallback para gravação) | 4.3 e 4.4 atendidos; música silenciável; app não toca em segundo plano |
| **M4 — Pais e segurança** | Portão, área dos pais, pausa sugerida, tratamento do botão voltar | 4.7 e 4.8 atendidos; a criança não entra nem sai sem querer |
| **M5 — Fase 2** | Escolha da série, escola, espaços, economia, aulas por espaço, objetivos, passar de ano | Seção 6 atendida; parâmetros do Anexo B; liberação sequencial (RF-FASE) |
| **M6 — Mundo explorável** | Seção 7, após decisão faixa vs mapa livre | RM-01 a RM-08 atendidos; teste com crianças |
| **M7 — Web PWA** | Build web instalável e offline | Funciona em modo avião; sem requisições externas |
| **M8 — Conteúdo e conformidade** | Vozes gravadas, músicas e artes finais, licenças, política de privacidade, ficha da loja, Data safety | Checklist 12.5 completo |
| **M9 — Teste fechado e produção** | Versão em teste fechado com 15+ testers por 14 dias; depois produção no Brasil | Aprovado na Google Play |
| **M10 — Fase 3A (condicional)** | Modo Turma, painel do professor e tarefas | Somente após as decisões da seção 8.8, contrato com escolas, revisão jurídica, financiamento do servidor e plano aprovado |
| **M11 — Fase 3B (condicional)** | Ajuda entre alunos (visita, tarefinhas, caixa de presentes, figurinhas) | Somente após o M10 estável, com checklist de segurança infantil aprovado |

---

## 16. Plano de testes

- **Automatizados:** progressão (libera por participação, estrela só na primeira vez), economia da escola (custos, objetivos, passar de ano), traçado (avanço só para frente), sorteio de rodadas, persistência, paridade de chaves pt/en, seleção de voz, `ItemFeedback` (acerto, erro, exceção da silhueta).
- **Rede:** captura de tráfego em modo avião e com rede para provar zero requisições (Fases 1 e 2).
- **Dispositivos:** aparelho Android de entrada e um intermediário; telas de 320 a 480 dp; tablet.
- **Usabilidade (obrigatória antes do teste fechado):** observar 3 a 5 crianças de 3 a 5 anos com os pais. Medir: concluem a 1ª etapa sozinhas? Entendem o que tocar? Frustração? Tempo de atenção? A voz é agradável? **Construir e melhorar a escola motiva a fazer mais aulas?** Arrastar o mundo é natural?
- **Acessibilidade:** leitor de tela nos controles dos pais; daltonismo na pintura (nomes das cores falados).
- **Pausa e portão:** adulto consegue, criança de 3 anos não.
- **Liberação em ordem (RT-09):** espaço trancado até o anterior estar construído + 1 aula; só a aula da vez abre; objetivo seguinte só depois do anterior resgatado; progresso salvo fora de ordem não volta a trancar.
- **Idiomas:** todo item com nome em todos os idiomas suportados; trocar de idioma traduz o balão do guia na hora; a voz usa a região exata do idioma.
- **Rabisco livre (RT-08):** ✓ apagado com a tela em branco, acende no primeiro traço, apaga ao limpar; tocar apagado gera o som sutil e a fala de incentivo; a celebração não dá estrela.

---

## 17. Decisões (ADR) e pontos em aberto

| ADR | Decisão | Status |
|---|---|---|
| 001 | Flutter para Android e Web | Proposto |
| 002 | Sem backend e sem login nas Fases 1 e 2 | Aprovado |
| 003 | Progresso compartilhado entre idiomas | Aprovado |
| 004 | Sem captura de áudio; "Falar" é repetição guiada | Aprovado |
| 005 | Publicação por conta pessoal Google Play | Aprovado |
| 006 | Lançamento inicial somente no Brasil | Aprovado |
| 007 | Imagens sem texto embutido; texto e áudio separados | Aprovado |
| 008 | Voz: síntese do sistema (tom "Fofa") no MVP; voz gravada na fase de conteúdo | Aprovado |
| 009 | Fase 2 por séries (Maternal, Pré I, Pré II), sem relógio | Aprovado |
| 010 | Regra transversal de áudio nas figuras (RT) para todas as fases | Aprovado |
| 011 | Liberação sequencial de fases (RF-FASE-01) | Aprovado; critério pendente |
| 012 | Mundo explorável por arrasto, em mapa livre (seção 7.1) | Aprovado |
| 013 | Fase 3 como Modo Turma opcional, atrás do consentimento dos pais | Aprovado em conceito |
| 014 | Fase 3 dividida em 3A (turma e tarefas do professor) e 3B (ajuda entre alunos) | Proposto; confirmação pendente |
| 015 | Atividades livres têm botão de conclusão ✓, sem estrela (RT-08) | Aprovado |
| 016 | Liberação em ordem dentro de cada fase: etapa, missão ou aula só abre quando a anterior for concluída (RT-09) | Aprovado |
| 017 | Estrutura pronta para novos idiomas: idioma é dado (traduções e conteúdo), nunca regra fixa no código das telas | Aprovado |

**Pontos em aberto [PENDENTE]:**
1. Quem grava as vozes e em qual inglês (americano é a premissa).
2. Origem das músicas e artes (autoria própria, CC0 ou licenciadas).
3. Disponibilidade do nome Genius Kiddo (Play, INPI, Registro.br).
4. Biblioteca de estado e pacotes de áudio/voz definitivos (decidir no M0).
5. Lançar 100% gratuito ou já com pacote pago.
6. Critério de liberação da Fase 3 (RF-FASE-02; o da Fase 2 já está definido).
7. Todos os pontos da seção 8.8 (Fase 3).
8. Futura conta dos pais para backup e método de login.

---

## 18. Backlog de ideias futuras (não planejadas)

Quebra-cabeças e sequências adicionais; álbum de figurinhas; mais glifos de traçado (outras letras e números); mais artes de pintura; 1º ano e séries seguintes; pacotes temáticos (animais, datas comemorativas); licenças para escolas; backup com conta dos pais; versão iOS; trilhas e vozes gravadas completas.

---

## Anexo A — Parâmetros da Fase 1 (extraídos do protótipo)

| Item | Valor |
|---|---|
| Dica na pintura | Após **7 s** sem toque, uma região não pintada pisca |
| Pintura: conclusão | Todas as regiões pintadas |
| Traçado: área de desenho | Caixa lógica de 300 × 300 |
| Traçado: passo de amostragem | **5** unidades ao longo do caminho |
| Traçado: raio de tolerância | **36** unidades |
| Traçado: janela de avanço | até **12** amostras à frente por movimento |
| Traçado: conclusão | Ao chegar às **3 últimas** amostras |
| Traçado: largura da faixa / do guia / do preenchido | 46 / 10 (pontilhado) / 18 |
| Glifo "1" | `M105 95 L160 52 L160 250` |
| Glifo "O" | `M150 50 A88 100 0 1 1 150 250 A88 100 0 1 1 150 50` |
| Ouvir | 3 rodadas · 4 cartões (2×2) · avança 1,5 s após o acerto |
| Associar | 3 rodadas · 3 opções · avança 1,7 s após o acerto |
| Falar | 3 palavras · botão ✓ de 104 px · avança 1,7 s |
| Rabisco livre | Pincel 24 px, 6 cores, limpar |
| Rabisco livre: botão ✓ | 84 px, verde, canto inferior direito; apagado (opacidade ~0,45, sem pulsar) até o 1º traço e após limpar; celebração com 🎨 sem estrela |
| Portão dos pais / pausa | Segurar **2 s** |
| Pausa sugerida (padrão) | **15 min** (opções 0, 5, 10, 15, 20) |
| Música (protótipo) | Pentatônica de dó (262, 294, 330, 392, 440, 523, 587, 659 Hz), nota a cada ~430 ms, onda triangular, baixo a cada 4 notas, volume baixo |
| Efeitos | `pop` (2 notas senoidais), `good` (arpejo de 3 notas), `win` (arpejo de 5 notas), `oops` (som de erro sutil: 2 notas senoidais graves e descendentes, ≈ 247 Hz → 196 Hz, volume baixo, < 0,35 s) |
| Erro: fala após o som | Nome do que foi tocado após ~0,26 s; pedido repetido após ~1,7 s |
| Celebração | +1 estrela só na 1ª conclusão; ~26 partículas de confete; botão ▶ de 84 px |
| Tons da voz | Suave 1,45/0,95 · Fofa 1,75/0,92 · Super fofa 1,95/0,90 (pitch/velocidade) |
| Vozes preferidas (pt-BR) | Luciana, Google português do Brasil, Francisca, Maria, Fernanda, Vitória, Camila |
| Vozes preferidas (en-US) | Samantha, Kathy, Ava, Allison, Google US English, Aria, Jenny, Zira, Susan |

## Anexo B — Parâmetros da Fase 2 (extraídos do protótipo)

| Item | Valor |
|---|---|
| Estrelas iniciais / Sala | 3 ⭐ / Sala de aula já no nível 1 |
| Aula concluída / objetivo cumprido | +3 ⭐ / +2 ⭐ e 1 medalha |
| Custos | Construir 3 · Nível 2: 6 · Nível 3: 10 |
| População de alunos | `min(14, 2 + soma dos níveis)` |
| Sala (formas) | Maternal: 3 formas de cor fixa (círculo vermelho, quadrado azul, triângulo amarelo), 3 opções · Pré I: 4 formas de cores distintas · Pré II: forma + cor, 4 opções (alvo; mesma forma outra cor; outra forma mesma cor; outra forma e cor) · 3 rodadas |
| Horta (contar) | Maternal 1–3 (opções até 4) · Pré I 1–5 (até 6) · Pré II 3–9 (até 10; 4 opções) · 3 rodadas · sem repetir o número anterior |
| Ateliê | Maternal: flor (6 regiões) · Pré I: casinha (6) · Pré II: jardim (7) |
| Biblioteca | 3 rodadas · 3 opções (Pré I) ou 4 (Pré II) · letra inicial no idioma ativo |
| Pátio | 4 botões (vermelho ●, azul ▲, amarelo ■, verde ★; notas 262, 330, 392, 523 Hz) · sequências [2, 3] (Pré I) e [3, 4] (Pré II) · intervalo de 750 ms · erro repete a sequência |
| Refeitório | 5 itens (3 frutas, 2 legumes) · 2 cestas |
| Escolha da série | Tela dos pais na 1ª entrada na escola, atrás do portão · muda depois na área dos pais, reiniciando objetivos e aulas do ano, sem apagar o construído |
| Ordem dos espaços (RT-09) | Sala → Horta → Ateliê → Biblioteca → Pátio → Refeitório · o próximo abre com o anterior construído + 1 aula |
| Aula da vez (RT-09) | Espaço construído sem aula primeiro; depois rodízio na ordem dos espaços |
| Objetivos (RT-09) | Em ordem: o próximo só depois do anterior resgatado |
| Sugestão | Prioriza espaço novo da série já liberado, depois construção possível, depois melhoria possível, senão a aula da vez |

## Anexo C — Catálogo de frases do guia (pt-BR / en-US)

| Chave | pt-BR | en-US |
|---|---|---|
| `welcome.first` | Oi! Eu sou o Kiddo! Toque na estrela brilhante! | Hi! I am Kiddo! Tap the glowing star! |
| `welcome.back` | Oi! Que bom te ver! Vamos cuidar da nossa escola? | Hi! So good to see you! Shall we take care of our school? |
| `home.hint` | Toque na estrela brilhante! | Tap the glowing star! |
| `locked` | Ainda não! Vamos fazer a estrela brilhante primeiro! | Not yet! Let us do the glowing star first! |
| `grade.locked` | Esse espaço chega no {série}! Vamos passar de ano! | This space arrives in {grade}! Let us move up a grade! |
| `school.lockedPrev` | Ainda não! Primeiro: {espaço}. | Not yet! First: {space}. |
| `school.nextLesson` | A próxima aula é: {espaço}! | The next lesson is: {space}! |
| `paint.intro` | Escolha uma cor e toque no desenho! | Pick a color and tap the picture! |
| `paint.done` | Que lindo! Você pintou tudo! | So pretty! You painted it all! |
| `trace.intro` | Siga a trilha e desenhe {glifo}! | Follow the path and draw {glyph}! |
| `listen.prompt` | Toque n{art} {nome}! | Tap the {name}! |
| `match.intro` | Quem está escondido na sombra? | Who is hiding in the shadow? |
| `speak.prompt` | Diga: {nome}! Agora é com você! | Say: {name}! Now it is your turn! |
| `count.intro` | Toque nas plantinhas e conte! Quantas são? | Tap the plants and count! How many are there? |
| `letters.prompt` | {Nome}! Com qual letra começa? | {Name}! Which letter does it start with? |
| `rhythm.watch` / `rhythm.turn` | Olhe e escute! / Sua vez! | Watch and listen! / Your turn! |
| `sort.prompt` | Onde vai {art} {nome}? Frutas ou legumes? | Where does the {name} go? Fruits or veggies? |
| `free.intro` | Desenhe do seu jeito! | Draw your own way! |
| `free.first` | Desenhe um pouquinho primeiro! | Draw a little first! |
| `free.done` | Que desenho lindo! | What a lovely drawing! |
| `school.built` | Que lindo! Nossa escola cresceu! | So pretty! Our school grew! |
| `school.upgraded` | Uau! Ficou ainda melhor! | Wow! It got even better! |
| `need.stars` | Faça uma aula para ganhar estrelas! | Do a lesson to earn stars! |
| `goal.reached` | Você cumpriu um objetivo! Toque no troféu! | You reached a goal! Tap the trophy! |
| `medal` | Medalha conquistada! Parabéns! | Medal earned! Congratulations! |
| `promoted` | Parabéns! Agora você está no {série}! Chegaram espaços novos! | Congratulations! You are now in {grade}! New spaces arrived! |
| `graduated` | Formatura! Você completou a escolinha! Em breve: 1º ano! | Graduation! You finished the school! Coming soon: 1st grade! |
| `break` | Hora de descansar os olhinhos! Vamos beber água? | Time to rest your eyes! Shall we drink some water? |
| `praise.*` | Muito bem! · Isso mesmo! · Uau, que demais! · Parabéns! | Great job! · Yes! That is right! · Wow, well done! · Awesome! |
| `retry.*` | Tente de novo! · Quase! Vamos de novo! · Olha com calma e tente outra vez! | Try again! · Almost! Once more! · Look closely and try again! |

## Anexo D — Referências dos protótipos

| Protótipo | Arquivo sugerido no repositório | Observação |
|---|---|---|
| Fase 1 — Trilha | `docs/prototype/genius-kiddo-prototipo.html` | Já com a regra de áudio (RT), a voz "Fofa" e o botão ✓ do rabisco livre. **Substituir o arquivo antigo pelo atualizado** |
| Fase 2 — Escolinha | `docs/prototype/genius-kiddo-fase2-escolinha.html` | Grade linear; mundo arrastável ainda não implementado (seção 7) |

Os protótipos foram publicados como páginas privadas do Rhoney. Salvar os arquivos HTML no repositório antes de iniciar.

## Anexo E — Glossário

- **Etapa / nó:** uma atividade na trilha da Fase 1.
- **Espaço:** ambiente construível da escola (Fase 2).
- **Aula:** a atividade jogada num espaço.
- **Portão dos pais:** controle que exige segurar o botão por 2 segundos.
- **Guia:** personagem gênio que fala as instruções.
- **Caminho imantado:** traçado com tolerância larga que "puxa" o dedo para o caminho.
- **Fallback de voz:** uso da síntese do sistema quando não há clipe gravado.
- **RT:** regras transversais, válidas para todas as fases.
- **Modo Turma:** conjunto de recursos sociais e de professor da Fase 3, opcional e desligado por padrão.
