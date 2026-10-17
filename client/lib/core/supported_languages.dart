/// Seção 4.5: "pt-BR e en-US, um idioma por vez" — hoje só esses dois, mas
/// a lista fica centralizada aqui de propósito. Adicionar um 3º idioma no
/// futuro é: (1) um ARB novo em lib/l10n/ (vira Locale suportado
/// automaticamente via AppLocalizations.supportedLocales, gerado do
/// l10n.yaml), (2) uma linha nova aqui. Nenhuma tela precisa mudar — a
/// pílula de idioma (core/language_pill.dart) e a escolha inicial
/// (features/language/language_screen.dart) já leem esta lista.
class SupportedLanguage {
  const SupportedLanguage({
    required this.code,
    required this.greeting,
    required this.nativeName,
    required this.ttsLocale,
  });

  /// Código do idioma, igual ao `@@locale` do ARB (`pt`, `en`...).
  final String code;

  /// Saudação curta mostrada no lugar de nome de idioma/bandeira (seção
  /// 4.5: "sem bandeiras, evita associar idioma a país") — "Oi!", "Hi!".
  final String greeting;

  /// Nome do idioma na própria língua, rótulo pequeno nos cartões.
  final String nativeName;

  /// Locale da voz do sistema (`flutter_tts`) pra este idioma.
  final String ttsLocale;
}

const List<SupportedLanguage> supportedLanguages = [
  SupportedLanguage(
    code: 'pt',
    greeting: 'Oi!',
    nativeName: 'Português',
    ttsLocale: 'pt-BR',
  ),
  SupportedLanguage(
    code: 'en',
    greeting: 'Hi!',
    nativeName: 'English',
    ttsLocale: 'en-US',
  ),
];

/// Idioma pelo código; desconhecido cai no primeiro da lista.
SupportedLanguage languageFor(String? code) => supportedLanguages.firstWhere(
  (l) => l.code == code,
  orElse: () => supportedLanguages.first,
);
