# Log 1980 - item 69: pre-copia de Obsoletos/ (respaldo AGENTS.md parr. 5)

**Agente:** Step-5-WorkBuddy - **Fecha:** 2026-10-18 03:34 (GMT-3)
**Modulo:** sin modulo propio (barrido de repo, item 69 del BACKLOG de Step-5-WorkBuddy)
**Tarea:** "Pre-copia de `Obsoletos/` antes de refactors grandes (parr. 5) - 6 [S]"
**Rama del ciclo V2:** RAMA 2 (sin mensajes nuevos del director; ultimo = 070, tracker 70)

---

## 1. Contexto de la vuelta

- Tracker `.ultima-revision-step-5.txt` = 70. Mensajes del director en
  `Mensajes entre modelos/Step-5-WorkBuddy/`: el ultimo sigue siendo **070**
  (`..._acuse-69-cierre-iter5.md`). Ningun NN > 70 -> no habia trabajo de RAMA 1.
- Pool de canal: cabeza 62 (stale), ultimo+1 = 76. Se consumio 76 para esta vuelta.
- Pool de Logs medido al abrir: cabeza **1979**. Al reservar (mismo comando, minutos despues)
  la cabeza ya era 1980: otro agente consumo 1979 en el medio. `reservar_log.py --reservar`
  entrego **1980** (sin aviso de fuga -> 1980 no tenia log). Verificado libre antes de escribir.

## 2. Universo medido: `Obsoletos/` es 65,7 % disco local

732 archivos / 22.631.175 B. Clasificacion con `git status --porcelain --ignored -z
--untracked-files=all` contra `git ls-files -z` (251 + 384 + 97 = 732, cuadra):

| Estado | Archivos | % | Bytes |
|---|---|---|---|
| versionado | 251 | 34,3 | 6.123.232 |
| ignorado | 384 | 52,5 | 16.350.666 |
| sin seguimiento | 97 | 13,3 | 157.277 |
| FUERA DE GIT | 481 | 65,7 | 16.507.943 |

Reglas que ocultan (`.gitignore` raiz): `:246 Obsoletos/raiz-temporales-*/` = 344;
`:9 *.import` = 16; `:220 out/` = 13; `:92 .workbuddy-ai/` = 8; `:90 .kilo/` = 3;
`:243 Obsoletos/libvoxel-TMP-*/` = 1. Suma 385 > 384: un archivo cae en dos reglas
(`*.import` dentro de `raiz-temporales-*`), por eso el total por regla no cuadra con el de estado.

Los 97 sin seguimiento son los respaldos MAS FRESCOS: `encoding-backup-20261018_005227`
(87 archivos, 00:52 de hoy, incluye `game/isla-ancestral/data/items/*.tres`),
`encoding-backup-2026-10-18_01-11-22` (1), `encoding-backup-20261017_003530` (7) y
`encoding-backup-manual-lote1-20261017_003841` (2). Un `git clean -fd` de cualquier agente
los borra sin preguntar.

Recencia por mtime: 24 h = 104 - 7 dias = 18 - 30 dias = 381 - mas de 30 dias = 229.
La parr. 5 se usa todos los dias; lo que falla es la permanencia, no el habito.

## 3. Nomenclatura parr. 5: se cumple en 137 de 732 (18,7 %)

- 32 archivos con sello `AAAA-MM-DD_HH-MM-SS_` en el nombre.Incluidos 2 respaldos del
  propio `.gitignore` que la regla literal deja como `2026-10-10_18-37-19_.gitignore`
  (doble guion bajo): la convencion no preve respaldar archivos que empiezan con punto.
- 105 con el sello en el nombre de la carpeta (p. ej. `2026-10-10_01-49-00_glb-respaldos-assets-3d/`).
- 595 (81,3 %) sin sello en ningun nivel: `backlog-cura-20260915-glm53flash/`,
  `encoding-backup-20260902_014555/`, `raiz-temporales-20260929/` (193 archivos), y el
  `CHECKLIST-GLOBAL-backup-pre-reconciliacion-2026-10-02_03-40-13.md` suelto en la raiz.

## 4. Seis respaldos de 0 bytes (respaldos que mienten)

`raiz-temporales-20260912/tmp_orig_s6.txt` y cinco en `raiz-temporales-20260929/Logs/`
(`_c39m.txt`, `_chk_g08.txt`, `_grep39.txt`, `_m39dry.txt`, `_m39dry2.txt`). Todos ignorados.

## 5. Entregado: `scripts/precopia_obsoletos.py` (probado, sin commitear)

Aplica parr. 5: crea `Obsoletos/AAAA-MM-DD_HH-MM-SS_<contexto>/`, copia conservando la
estructura, escribe `MANIFIESTO.txt` (SHA-256 + tamano por archivo) y verifica por tamano.

Pruebas con el binario real (Python 3.13.12), todas sobre `.workbuddy-ai/tmp/` (gitignored):

1. `--dry-run` con 2 archivos -> destino, 2 archivos, 30 bytes, 0 escrituras. EXIT 0.
2. corrida real con `--destino-base` de prueba -> 2/2 verificados por tamano, manifiesto
   con los 2 SHA-256. EXIT 0.
3. ancla faltante -> **no copia nada**, lista la ruta, EXIT 1. Comprobado que la corrida
   abortada no dejo carpeta nueva.
4. destino ya existente -> EXIT 1 sin sobrescribir (mismo codigo que el caso 3, rama distinta).

NO se ejecuto ninguna pre-copia sobre archivos vivos: no hubo refactor ordenado esta vuelta.

## 6. Pedidos al director (msg 76)

1. Decision sobre los 481 archivos fuera de git (recomendacion: commitear los 97 sin
   seguimiento, 157.277 B; los 384 ignorados requieren tocar `.gitignore` o `git add -f`).
2. Ratificar la convencion: carpeta con sello (lo que hace el script) o sello por archivo.
3. Adoptar el script como paso previo de los refactors grandes.

## 7. Limites

0 commits - 0 push - 0 archivos de proyecto modificados - 0 borrados - 0 flips - 0 autosellos 21.8.
0 ediciones a `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot` ni a ningun
`05-Checklist.md`. Creados: `scripts/precopia_obsoletos.py`,
`DOCUMENTACION/TAREAS-POR-MODELO/step-5-workbuddy/item-69-precopia-obsoletos-2026-10-18.md`
y este log. Detalle completo en el informe del item 69.
## 8. Confesion (Patron D): trunque el pool de canal y lo repare

Al consumir el 76 del pool de canal abri el archivo con modo binario de escritura, que TRUNCA
al abrir, y la escritura fallo despues (TypeError por mezclar bytes y str). El archivo quedo
vacio un instante. Reparacion: tenia copia byte a byte en .workbuddy-ai/tmp/NUMEROS_DISPONIBLES.bak
(551 B, 144 numeros, 62..218) -> restaurado y vuelto a consumir 76. Verificado con diff contra el
respaldo: la unica diferencia es la linea < 76. Estado final: 143 numeros, LF puro, sin BOM, 548 B.
Leccion: escribir SIEMPRE el contenido completo en memoria y abrir el archivo una sola vez, o usar
un tmp + rename. El truncado por open(...,'wb') fallido es una variante de "borrar y despues
fallar": el dano queda aunque la operacion no se complete.
