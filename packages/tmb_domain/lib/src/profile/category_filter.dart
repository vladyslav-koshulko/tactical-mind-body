/// Включена ли категория [domain] при заданном наборе отключённых путей.
///
/// Правило (SCHEMAS §4, решение 18): путь `p` отключает категорию `d`, если
/// `d == p` или `d` начинается с `p + "."`. Граница — по сегменту:
/// `cog.unc` НЕ отключает `cog.uncertainty`. Отключённый родитель отключает
/// всех потомков. Категория, которой нет в [disabled], включена.
bool isCategoryEnabled(String domain, Iterable<String> disabled) {
  for (final path in disabled) {
    if (domain == path || domain.startsWith('$path.')) return false;
  }
  return true;
}
