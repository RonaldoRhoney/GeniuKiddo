# Guia: subir o Genius Kiddo no Google Play (teste interno)

Na ordem em que as telas aparecem no Play Console (play.google.com/console). Textos e imagens prontos em `docs/loja/`. Os nomes dos menus podem mudar um pouco; quando não achar, procure pelo nome do item no painel inicial do app.

---

## Passo 0 — Antes de começar (5 min)

1. Entre no Play Console com a conta de desenvolvedor.
2. Na **tela inicial**, confira se aparece algum aviso de **verificação de desenvolvedor**. Se aparecer, resolva primeiro (no Brasil é obrigatório desde 30/09/2026).
3. Faça a **cópia de segurança da chave**: copie `client/android/keystore/genius-kiddo-release.jks` e `client/android/key.properties` para o Google Drive (pasta privada) ou um pendrive.

## Passo 1 — Criar o app (2 min)

**Tela inicial → Criar app**

| Campo | Resposta |
|---|---|
| Nome do app | `Genius Kiddo` |
| Idioma padrão | Português (Brasil) – pt-BR |
| App ou jogo | **App** |
| Gratuito ou pago | **Gratuito** (não dá para mudar para pago depois) |
| Declarações | marque as duas (Políticas do programa para desenvolvedores e Leis de exportação dos EUA) |

Clique em **Criar app**.

## Passo 2 — Conteúdo do app (15 a 20 min)

No **Painel** do app, abra a lista **"Configurar o app"** e faça cada item:

1. **Política de privacidade** → cole `https://ronaldorhoney.github.io/GeniuKiddo/` → Salvar.
2. **Acesso ao app** → **"Todas as funcionalidades estão disponíveis sem restrições de acesso"**. Se pedir instruções: *"Não há login. A área dos pais abre segurando o botão '🔒 Pais' (canto superior direito) por 2 segundos."*
3. **Anúncios** → **"Não, meu app não contém anúncios"**.
4. **Classificação do conteúdo** → Iniciar questionário:
   - E-mail: rhoneyinc@gmail.com · Categoria: **Referência, notícias ou educação**.
   - Responda **Não** para tudo: violência, medo, sexualidade, linguagem imprópria, drogas, álcool, tabaco, apostas, interação entre usuários, compartilhamento de conteúdo, compartilhamento de localização, compras digitais, navegador de internet.
   - Salvar → Calcular classificação → Enviar. Esperado: **Livre**.
5. **Público-alvo e conteúdo** → faixa etária: marque **só "5 anos ou menos"**.
   - Isso coloca o app na **Política de Famílias**. Confirme que o app não tem anúncios e não coleta dados (é verdade).
   - "O app pode atrair crianças sem querer?" não se aplica, porque ele é para crianças.
6. **Apps de notícias** → Não. **Apps governamentais** → Não. **Recursos financeiros** → nenhum. **Saúde** → nenhum (o app não é de saúde).
7. **Segurança dos dados** → **"Seu app coleta ou compartilha algum dos tipos de dados de usuário obrigatórios?" → Não.** Avance até o resumo ("Nenhum dado coletado", "Nenhum dado compartilhado") → Enviar.

## Passo 3 — Página da loja (10 min)

**Crescimento → Presença na loja → Página principal da loja** (ou **Detalhes do app** no painel):

1. Nome, descrição curta e completa: copie de `docs/loja/FICHA_DA_LOJA.md`.
2. **Ícone:** `docs/loja/icone-512.png`.
3. **Imagem de destaque:** `docs/loja/destaque-1024x500.png`.
4. **Capturas de tela do telefone:** os arquivos `docs/loja/captura-*.png` (de 2 a 8).
5. **Configurações da loja:** categoria **Educação**, e-mail **rhoneyinc@gmail.com**.
6. Salvar.

## Passo 4 — Enviar o AAB no teste interno (10 min)

**Testar e lançar → Testes → Teste interno**

1. Aba **Testadores** → **Criar lista de e-mails** → nome "Família" → adicione o seu e-mail (o da conta Google do celular) e de quem você quiser → Salvar.
2. **Criar nova versão.**
3. Se aparecer **Assinatura de apps do Google Play** → **Continuar / Aceitar** (o Google guarda a chave final; a sua é só a de envio).
4. **Enviar** o arquivo `client/build/app/outputs/bundle/release/app-release.aab`.
5. **Nome da versão:** `1.0.0 (1)` · **Notas da versão** (pt-BR): *"Primeira versão de teste: trilha de atividades, Escolinha com mapa, controle dos pais."*
6. **Avançar → Salvar e publicar** (ou **Revisar versão → Iniciar lançamento para teste interno**).

## Passo 5 — Instalar no celular

1. Na aba **Testadores**, copie o **link de participação**.
2. Abra o link no celular, toque em **Aceitar** e depois em **Baixar no Google Play**.
3. Antes de instalar, desinstale a versão de teste que eu instalei pelo cabo (`adb`). Ela tem outra assinatura, e o Android não deixa uma versão substituir a outra.
4. O primeiro teste interno às vezes leva de alguns minutos a algumas horas para aparecer na loja.

---

## Depois do teste interno

- **Números (Parte B do painel):** com o app no Play, a gente configura a conta de serviço para o painel ler instalações e travamentos.
- **Antes do teste fechado:** teste de usabilidade com 3 a 5 crianças (especificação, seção 16) e uma lista de 12 ou mais testers adultos por 14 dias contínuos.
- **Cada versão nova** precisa de número maior em `client/pubspec.yaml` (`version: 1.0.1+2`, `1.0.2+3`…).
