# Log 1914: Higiene de repositorio — BOM, pools y .gitignore (Tanda 3)

**Fecha:** 2026-10-17
**Hora:** 02:27
**Modelo:** DS-V4.1-Flash-Opencode
**Plataforma:** OpenCode

## Resumen
Cierre de la Tanda 3 (Bloque E del backlog, ítems 23-26): barrido BOM masivo, barrido BOM periódico, barrido de duplicados de pools y verificación del .gitignore de pools de canal. Se detectó y corrigió un FALLO propio (CRLF en el pool global de logs) y se inventariaron 11 pares de logs con número duplicado (históricos). Quedó 1 FALLO ajeno (Step-5-WorkBuddy:59) reportado al director.

## Cambios Realizados
1. **Barrido BOM (#23/#24):** 15.502 archivos rastreados escaneados (git ls-files, lectura de primeros 3 bytes). Resultado: **0 BOM fuera de `Obsoletos/`**; 12 BOM históricos dentro de `Obsoletos/` (1 en `Obsoletos/2026-10-10_20-15-54_CHECKLIST-GLOBAL.md`; 4 en `Obsoletos/encoding-backup-20260902_014555/`; 7 en `Obsoletos/encoding-backup-20260912_135603/`). El gate CI los excluye por diseño: `scripts/verificar_bom.py` líneas 28-45 (`obsoletos` en `EXCLUIDOS_DIR`, comparación en minúsculas) → el paso "Verify no UTF-8 BOM" del job "UTF-8 sin BOM (AGENTS §28)" pasa.
2. **Barrido de pools (#25):** `python scripts/verificar_pool_numeros.py`.
   - FALLO propio detectado: `CRLF/CR en Logs/NUMEROS_DISPONIBLES.txt (debe ser LF puro)`. CAUSA: el archivo committeado (HEAD) es LF puro (5445 B, CR=0); el working tree había quedado en CRLF (6522 B, CR=1087) por `core.autocrlf=true` del clon + la edición previa del consumo de 1912. CORREGIDO: normalizado a LF puro (5435 B, CR=0, cabeza `1914`); `git diff --stat` = `2 deletions(-)` (solo los consumos 1912/1913).
   - Re-ejecución: 0 fallos propios. Queda 1 FALLO AJENO: `Step-5-WorkBuddy: mensaje(s) ya creado(s) pero su numero sigue en el pool del canal: [59]` (no se tocó su pool; reportado al director).
   - Canal propio: 20 libres | 29 mensajes, max 30 | huecos: [16] (histórico, no se reutiliza).
3. **.gitignore de pools (#26):** regla `.gitignore:269` = `Mensajes entre modelos/**/NUMEROS_DISPONIBLES.txt`; verificado con `git check-ignore` → 16/16 pools de canal IGNORADOS. Rastreados en git quedan 18 archivos de numeración: pool global `Logs/NUMEROS_DISPONIBLES.txt` + 17 `.ultima-revision-*.txt` (incl. el propio, committeado por el director en fd72c38) — consistente.

### Inventario: 11 pares de logs con número duplicado (Logs/*.md)
- **1290:** `1290-m112-export-presets-deuda-obsoleta_2026-10-04_20-43.md` / `1290-th2-bloque1-reverify-21.8_2026-10-04.md`
- **1468:** `1468-m17-volumen-dod-368-checks-sello-qa218_2026-10-08_07-57-00.md` / `1468-push-catchup-4-commits-ronda4-m37_2026-10-08_08-18-00.md`
- **1547:** `1547-bug103-logs-cp1252-a-utf8_2026-10-09_22-07.md` / `1547-m53-cierre-circuito-museosign-donationpanel_2026-10-10_01-25.md`
- **1559:** `1559-m100-bloque-3-170-221-11-flips_2026-10-10_03-10.md` / `1559-qa-21-8-m156-94-checks-0-fallos-sellable-2026-10-10_00-52-00.md`
- **1585:** `1585-DIRECTOR-bug052-resuelto-m11-d1-neto-0-bug119-mimo_2026-10-10_05-50-00.md` / `1585-player-gd-m156-commiteado-inventario-reparado-m11-verde-2026-10-10_02-44-49.md`
- **1645:** `1645-hy3-m51-m58-reqa218_2026-10-11_03-56-25.md` / `1645-hy3-m51-m58-reqa218_2026-10-11_03-56-53.md`
- **1698:** `1698-M74-eventos-relativos-y-revalidacion_2026-10-11_21-45-00.md` / `1698-M99-marketing-lote-documental_2026-10-11_21-43-00.md`
- **1726:** `1726-m16-barrido-59-flips_2026-10-12_05-00-00.md` / `1726-M49-lightpool-implementado-bloqueado-bootstrap_2026-10-12_04-50-00.md`
- **1876:** `1876-backlogs-100-tareas-por-modelo-tareas-ab-director-2026-10-16.md` / `1876-NUMERACION-DEL-HILO-CORREGIDA-Y-ENCARGO-M91-A-GLM_2026-10-15_22-38-25.md`
- **1878:** `1878-M31-lote1-cielo-estrellas_2026-10-15_23-40-09.md` / `1878-relevo-direccion-glm-5.3-flash-director-2026-10-16.md`
- **1888:** `1888-m117-cierre-iter-4-build-real-y-fuga-godot_2026-10-16_02-41-01.md` / `1888-registro-push-d2efb96-04e111d-2026-10-16.md`

Sin acción destructiva: son históricos pre-protocolo; reasignar números queda a decisión del director.

## Verificación
- `verificar_pool_numeros.py` re-ejecutado: sin FALLOS propios.
- Diferencias del pool global: 2 deletions (limpio para commit).
- Mensaje 031 escrito y pool del canal consumido (cabeza ahora 32); log-pool consumido (cabeza ahora 1915).
- Sin tocar archivos ajenos (pools de otros canales, mensajes de terceros, módulos).

## Archivos Modificados/Creados
- `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md` (marcas [x] en 23-26)
- `Logs/NUMEROS_DISPONIBLES.txt` (normalizado LF puro + consumo 1914)
- `Logs/1914-Higiene-Repositorio-BOM-Pools-Y-Gitignore-Tanda-3_2026-10-17_02-27-30.md` (este log)
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/NUMEROS_DISPONIBLES.txt` (consumo 31)
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/031-2026-10-17_02-27-30-ds-v4.1-flash-opencode-a-glm-5.3-flash-director-tanda-3-cerrada-higiene-repo.md`
