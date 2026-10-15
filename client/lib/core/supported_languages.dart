/// Seção 4.5: "pt-BR e en-US, um idioma por vez" — hoje só esses dois, mas
/// a lista fica centralizada aqui de propósito. Adicionar um 3º idioma no
/// futuro é: (1) um ARB novo em lib/l10n/ (vira Locale suportado
/// automaticamente via AppLocalizations.supportedLocales, gerado do
/// l10n.yaml), (2) uma linha nova aqui. Nenhuma tela precisa mudar — a
/// pílula de idioma (core/language_pill.dart) e a escolha inicial
/// (features/language/language_screen.dart) já leem esta lista.
class SupportedLanguage {
  const SupportedLanguage({required this.code, required this.greeting, required this.nativeName});

  /// Código do idioma, igual ao `@@locale` do ARB (`pt`, `en`...).
  final String code;

  /// Saudação curta mostrada no lugar de nome de idioma/bandeira (seção
  /// 4.5: "sem bandeiras, evita associar idioma a país") — "Oi!", "Hi!".
  final String greeting;

  /// Nome do idioma na própria língua, rótulo pequeno nos cartões.
  final String nativeName;
}

const List<SupportedLanguage> supportedLanguages = [
  SupportedLanguage(code: 'pt', greeting: 'Oi!', nativeName: 'Português'),
  SupportedLanguage(code: 'en', greeting: 'Hi!', nativeName: 'English'),
];
