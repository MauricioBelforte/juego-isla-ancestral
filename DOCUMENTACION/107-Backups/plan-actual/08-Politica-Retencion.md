# 08 — Política de Retención (M107)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09

## Base: `data/backup/backup_policy.json`

```json
{
  "retencion": {
    "max_copias": 5,
    "dias_maximos": 30,
    "comprimir": true
  },
  "verificacion": {
    "checksum_habilitado": true,
    "integrity_check_al_restaurar": true
  }
}
```

## Retención por categoría (`backup_categories.json`)

| Categoría | Frecuencia | Retención (días) | Nota |
|---|---|---|---|
| `repositorio` | continuo | 365 | GitHub como copia primaria |
| `assets` | continuo | 90 | Git LFS + semanal externo |
| `documentacion` | continuo | 180 | Git + cloud |
| `builds` | post-release | 90 | GitHub Releases + mensual |
| `saves` | semanal | 30 | Carpeta local + cloud |
| `musica` | semanal | 365 | Git LFS + externo |
| `fuente` | continuo | 365 | GitHub todos los branches |

## Reglas de limpieza

- **Máximas 5 copias** por categoría antes de descartar la más antigua (`_limpiar_excedentes_cat` en `backup_manager.gd`).
- **Máximo 30 días** de antigüedad por copia (`dias_maximos` en `backup_policy.json`).
- El script `backup_local.ps1` mantiene los últimos 10 diarios en `D:\Backups\juego-isla-ancestral\`.
- `backup.yml` limpia en Google Drive con `rclone delete --min-age 30d`.

## Excepciones

- **Assets originales** (DAW, fuentes propias): retención permanente (no se descartan).
- **Builds de release**: se conservan en GitHub Releases de forma permanente.
- **Documentación**: retención extendida (180 días mínimos).

## Revisión trimestral

- Verificar que las copias existan y sean legibles.
- Ajustar `max_copias` o `dias_maximos` si el uso de disco lo requiere.
- Documentar cualquier cambio en este archivo.
