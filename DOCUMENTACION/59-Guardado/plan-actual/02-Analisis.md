**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 59: Guardado

## 1. Análisis del Dominio

El dominio del guardado de Aurora se descompone en siete subsistemas:

### 1.1 Trigger de guardado
- **Dominio:** guardado automático (por hitos: fin de día M29, evento M74, misión completada M22/M23, cierre de juego) y manual (pausa M53). Intervalo configurable de auto-save.
- **Clave:** el guardado NO se ejecuta en el frame: se encola y escribe en background thread (hilo separado), la UI solo muestra feedback sutil (M44). Nunca "Se guardó" congelando el juego.

### 1.2 Slots y perfiles
- **Dominio:** 3+ slots locales (archivos `slot_N.save`) + slot de configuración separado (M90/M91). Selección en el menú principal y en pausa.
- **Clave:** cada slot es un "perfil" con su propio save; sin cruzamiento (ids de perfil en el archivo, validados en carga).

### 1.3 Escritura atómica (protección anti-corrupción)
- **Dominio:** escribir a `slot_N.tmp` → fsync → renombrar a `slot_N.save`; ante cualquier fallo, el archivo anterior queda intacto.
- **Clave:** regla dura del módulo: NUNCA escribir sobre el save actual; el `.tmp` se limpia en el próximo arranque si quedó huérfano.

### 1.4 Checksum y validación
- **Dominio:** cada save lleva checksum (SHA-256 del payload) + estructura validada en carga (campos esperados, tipos, rangos).
- **Clave:** si la validación falla → aviso claro y oferta de recuperar el backup automático (M107) o el slot anterior.

### 1.5 Versionado y migración
- **Dominio:** `schema_version` en cada save (M60). Al cargar, si la versión es menor → migración automática (M60) con backup previo a la migración.
- **Clave:** la migración es "solo hacia delante": nunca degradar un save.

### 1.6 Backups (M107)
- **Dominio:** rotación local: al guardar, el save anterior se rota a `slot_N.bak` (conservando 1-2 rotaciones); los backups manuales se guardan con fecha.
- **Clave:** el backup es del sistema M107 (3-2-1 externo); aquí la rotación local inmediata para recuperación rápida.

### 1.7 Contenido del save (snapshot de sistemas)
- **Dominio:** un snapshot compacto por sistema: mundo (M09/M10/M54), inventario (M14), construcciones (M17/M18), NPC (M19), misiones (M22/M23), relaciones (M20), economía (M38/M39), tiempo (M29/M31), eventos (M74), colecciones (M37), diario (M55), fotos (M56 — solo índice, los archivos viven en `user://photos/`).
- **Clave:** el save referencia fotos por id (no embebe bytes); los archivos de fotos se validan aparte (M56).

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Guardado en el frame (escritura síncrona) | **Descartado** | Congela el juego; background thread obligatorio |
| Escribir sobre el save actual | **Descartado** | Corrupción en apagado; escritura atómica (.tmp+rename) |
| Sin checksum | **Descartado** | Detección de corrupción exige checksum + validación |
| Migración destructiva sin backup | **Descartado** | Backup previo a migración siempre |
| Fotos embebidas en el save | **Descartado** | Save gigante; fotos por referencia (M56) |
| Un solo slot | **Descartado** | Múltiples perfiles requeridos (23 items del plan) |
| Backups solo externos (M107) | **Descartado** | Rotación local inmediata + 3-2-1 externo |

## 3. Decisiones del Módulo

1. **Guardado en background thread** con encolado de peticiones y feedback sutil (M44).
2. **Escritura atómica** (`.tmp` + rename) — regla dura anti-corrupción.
3. **Checksum + validación de estructura** en cada carga.
4. **Versionado + migración solo-hacia-delante** (M60) con backup previo.
5. **Rotación local de backups** (`slot_N.bak`) + backups manuales fechados; el 3-2-1 externo es M107.
6. **Snapshot por sistema** con fotos por referencia (M56) y configuración aparte (M90/M91).

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Corrupción por apagado | Media | Alto | Escritura atómica + checksum + backup |
| Congelamiento en guardado | Media | Alto | Background thread + feedback sutil |
| Migración que rompe datos | Media | Alto | Backup previo + migración solo-hacia-delante (M60) |
| Cruzamiento entre perfiles | Baja | Alto | Id de perfil + validación en carga |
| Falta de espacio en disco | Media | Medio | Aviso claro; conservar el save anterior |
| Save enorme por fotos/diario | Media | Medio | Referencias de fotos; snapshot compacto |
| Configuración mezclada con progreso | Baja | Medio | Slot de configuración separado (M90/M91) |