# Log 852: Saneamiento transversal de codificación (2ª campaña)

**Fecha:** 2026-09-12
**Hora:** 14:01
**Modelo:** Hy3 / WorkBuddy
**Plataforma:** WorkBuddy (WorkBuddy AI)

## 0. Contexto y por qué esta tarea

El usuario pidió explícitamente pasar de las casas (M18-BIS, traspasado a MiMo)
a **"actividades de cruzamiento de todo el proyecto"**. La codificación es el
candidato obvio: afecta a todo el repo, no pertenece a ningún módulo y encaja
en las fortalezas §15 (cadenas de pasos con verificación numérica, diagnóstico
transversal, depuración de tooling).

Ya existía una campaña previa: **Log 507** (hy3, Kilo Code, 2026-09-02) que
corrigió 27 archivos. Esta es la segunda campaña, y su valor principal no es
"volver a pasar el script" sino **encontrar por qué la primera no alcanzó**.

## 1. Hallazgo de partida

`CHECKLIST-GLOBAL.md` — declarado en AGENTS.md como *"la única fuente de verdad
sobre el estado global de cada módulo"* — estaba corrupto con **815 marcas** de
mojibake: `â€” Orquestador`, `Ãºltimo`, `ðŸŸ¢`. No era un problema de
visualización: buscar `último` en el archivo no devolvía nada.

Escaneo completo: **78 archivos SUCIO**, 15 IRREVERSIBLE, 30 EXCLUIDO.

## 2. Por qué el Log 507 no alcanzó (causa raíz)

Cuatro defectos en `scripts/fix_encoding.py`, ninguno visible sin leer el
código con atención:

| # | Defecto | Consecuencia |
|---|---------|--------------|
| D-1 | `EXCLUDE_DIRS` podaba por **nombre de directorio** en cualquier profundidad, e incluía `"scripts"` | Excluía también `game/isla-ancestral/scripts/`, o sea **el código del juego**. Los `.gd` nunca se reparaban. |
| D-2 | `_fix_line` decidía los tramos con `ch.encode("cp1252")`, que **rechaza los caracteres de control C1** (`U+0080`–`U+009F`) | Un token mojibake que contiene `U+009D` se partía por la mitad y quedaba irrevertible. |
| D-3 | Último recurso del decodificador: `encode("latin-1","replace")` | **Creador de los U+FFFD** que el propio Log 507 declara "irrecuperables". El remedio era la enfermedad. |
| D-4 | Solo 2 pasadas de decodificación | El mojibake **triple** no llegaba a resolverse. |

D-3 es el más grave y explica la "Limitación importante (honestidad)" del Log
507: los 8 archivos con U+FFFD no eran daño ajeno, los produjo ese fallback.

## 3. El guard que evitó el desastre

Se agregó a `main()` un control previo a escribir: si el resultado **gana**
caracteres U+FFFD respecto del original, se aborta ese archivo.

Resultado en la primera ejecución real:

```
[SKIP] CHECKLIST-GLOBAL.md -> ganaria 24 U+FFFD, se aborta
```

Sin ese guard, el archivo más importante del proyecto habría quedado
destruido de forma irreversible.

El guard dio un falso positivo que también valió la pena diagnosticar: esos 24
U+FFFD **ya existían**, pero camuflados como `ï¿½` (la secuencia de 3 chars que
resulta de mojibakear U+FFFD). Verificación: `CHECKLIST-GLOBAL.md` contenía
**25** secuencias `ï¿½` y **0** U+FFFD literales. No era daño nuevo, era daño
previo que la reparación deja a la vista. El guard se corrigió para descontar
los camuflados en vez de abortar.

## 4. Correcciones aplicadas al tooling

`scripts/fix_encoding.py`:
- `EXCLUDE_DIRS_ROOT` nuevo: la exclusión de `scripts/` aplica **solo en la
  raíz** (D-1).
- `_sloppy_bytes()`: tercer intento de decodificación que acepta los 5 bytes
  que cp1252 no define (`0x81 0x8D 0x8F 0x90 0x9D`) (D-2).
- Los caracteres `< 0x100` (incluidos C1) entran en el tramo (D-2).
- Eliminado el fallback con `errors="replace"` (D-3).
- Bucle de hasta 6 pasadas mientras cada una siga limpiando (D-4).
- Guard anti-U+FFFD con descuento de camuflados.
- `main()` ya no escribe si `classify` devuelve `None` (bug latente: pasaba
  `None` a `f.write()`).

`scripts/diagnosticar_mojibake.py` (nuevo): verificador **estricto**. Su patrón
exige que el carácter sospechoso vaya seguido de su byte de continuación, a
diferencia del detector laxo de `fix_encoding.py`, que salta con la sola
presencia de `â` y por eso marcaba como corruptos archivos de localización en
portugués (`strings_pt.json`) que están perfectos. Separar *reparar* de
*verificar* es deliberado: si una sola herramienta hace ambas cosas, un falso
positivo de detección se convierte en una escritura destructiva silenciosa.

## 5. Resultados numéricos

| Métrica | Antes | Después |
|---|---|---|
| Archivos SUCIO | 78 | **18** |
| Marcas en `CHECKLIST-GLOBAL.md` | 815 | 0 |
| `.gd` de `eventos/` e `ia_npc/` con mojibake | 8 | 0 |
| `.gd` de `ia_npc/states/` con mojibake | 8 | 0 |

Recuperación verificada, sin adivinar caracteres: el token triple
`ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â\x9d` (idéntico en 8 archivos) decodifica por niveles
`→ Ã¢â‚¬â€\x9d → â€” → —`, es decir **guió emdash**:

```
## M64: Sleep State — va a dormir, duerme, despierta
print("[Sleep] Llegó a casa")
print("[Sleep] Despertó, energía restaurada")
```

Respaldos byte-a-byte de todo lo modificado en
`Obsoletos/encoding-backup-<timestamp>/`.

**Control de fines de línea:** se verificó que no se introdujeron CRLF.
`event_manager.gd` tiene 583 CRLF ahora y **583 en el respaldo previo a la
escritura**: ya estaban en el working tree (HEAD los tiene normalizados a LF
por `.gitattributes`). La reparación preserva los saltos originales.

## 6. Lo que NO se pudo arreglar (honestidad §21.4)

- **15 archivos IRREVERSIBLE** con U+FFFD real: los bytes originales se
  perdieron en conversiones previas de otros agentes. Solo se recuperan
  re-escribiendo los fragmentos a mano.
- `scripts/verify_final.py`, `scripts/fix_coordinacion.py`,
  `scripts/fix_emoji3.py`: **no se tocaron a propósito**. Contienen literales
  mojibake intencionales en sus tablas de búsqueda/reemplazo (p. ej.
  `('\u00c3\u00af', 'Ã¯')`). "Repararlos" rompería su lógica.
- `AGENTS.md`: idem, su sección de codificación documenta el síntoma con
  ejemplos. Excluido explícitamente en ambas herramientas.
- `Logs/`: excluido por política del Log 507 (registro histórico).
- **La fuga continúa.** Aparecieron archivos nuevos ya corruptos durante esta
  misma sesión (`DOCUMENTACION/CONTEXTO-PROXIMO-AGENTE/0{5,6}-...-2026-09-12.md`).
  El problema es de origen: cada agente escribe con la codificación de su
  plataforma. Ningún saneamiento periódico lo resuelve de raíz.

## 7. Archivos modificados / creados

- Modificado: `scripts/fix_encoding.py` (7 correcciones, ver §4)
- Creado: `scripts/diagnosticar_mojibake.py` (verificador estricto)
- Reparados: 78 → 18 archivos (documentación, backlogs por modelo y `.gd`)
- Respaldos: `Obsoletos/encoding-backup-<timestamp>/`

## 8. Próximo paso sugerido

Siguiente tarea transversal candidata, en orden de valor:
1. Anotar los 17 scripts huérfanos de la raíz (sin documentar).
2. Auditar referencias cruzadas rotas entre `DOCUMENTACION/` y `Logs/`.
3. Limpiar los 11 `~libvoxel*.TMP` (82 MB) en `addons/zylann.voxel/bin/`.

---
**Firma:** Hy3 / WorkBuddy · 2026-09-12 14:01
