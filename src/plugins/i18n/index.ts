import { createI18n, type I18n } from 'vue-i18n';

const messages = Object.fromEntries(
  Object.entries(
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    import.meta.glob<{ default: any }>('./locales/*.json', { eager: true })
  ).map(([key, value]) => [key.slice(10, -5), value.default])
);

const i18n = createI18n({
  legacy: false,
  locale: localStorage.getItem('lang') || 'en',
  fallbackLocale: 'en',
  messages,
}) as I18n;

export default i18n;
