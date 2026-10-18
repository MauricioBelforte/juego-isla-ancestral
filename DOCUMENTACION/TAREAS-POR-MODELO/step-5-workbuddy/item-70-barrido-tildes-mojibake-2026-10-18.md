# Informe item 70 - Barrido de tildes/mojibake en archivos nuevos del dia (28 diagnostico)

**Agente:** Step-5-WorkBuddy · **Fecha:** 2026-10-18 05:06 (GMT-3) · **Log:** 1987 · **Mensaje:** 77
**RAMA 2** (sin mensajes nuevos del director; tracker 70, ultimo = 070).

## 1. Universo y metodo
- 232 archivos de texto creados/modificados hoy (mtime >= 2026-10-18 00:00) en:
  DOCUMENTACION/, Logs/, Mensajes entre modelos/, scripts/, scripts-prueba-temp/,
  scripts-reutilizables/, Obsoletos/, PAPELERA/, out/, .workbuddy-ai/,
  game/isla-ancestral/scripts, legal/ (extensiones .md .gd .py .txt .json .tres).
- Barrido propio por bytes: BOM, U+FFFD, marcadores clasicos de mojibake, triplet del BOM
  leido como cp1252, bytes de control, NUL, EOL. Mas los gates del repo.
- 0 archivos vacios; 232/232 decodifican como UTF-8 estricto (0 invalidos).

## 2. Mojibake real: 0
Los 4 archivos con hallazgos del barrido propio, explicados uno por uno:

| Archivo | Tamano | Hallazgo | Veredicto |
|---|---|---|---|
| TAREAS-POR-MODELO/agnes-3-flash/BACKLOG-MASTER.md | 92.439 B | 1 marca del patron emoji-roto | CITA del patron (doc explica como detectarlo). Ajeno, NO tocado |
| TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md | 292.449 B | marcas o-roto + emoji-roto | CITA del patron (bloque de advertencia). Ajeno, NO tocado |
| .workbuddy-ai/memory/automations/1d934e73.../memory.md | 235.478 B | 2 bytes 0x08 (offsets 220631/220635) | Documentacion DELIBERADA de la trampa 0x08/hud. Ajeno, NO tocado. Efecto: grep lo trata como binario |
| .workbuddy-ai/tmp/barrido_2026_10_18.py (propio) | 4.001 B | marcadores como literales | Falso positivo propio |

## 3. Gates del repo medidos hoy (verdes, sin heredar)
- scripts/diagnosticar_mojibake.py: EXIT 0. SUCIO 0 / IRREVERSIBLE 0 / EXCLUIDO 365.
- --selftest: 28/28 OK -> el detector no esta ciego; el veredicto LIMPIO es creible.
- scripts/verificar_bom.py: EXIT 0 (0 archivos con EF BB BF).
- Ayer 2026-10-17 19:47 ambos estaban ROJOS por ajenos (13 SUCIO en canales historicos +
  1 tracker con BOM). Medidos hoy en verde: otro agente los limpio en el medio.

## 4. Hallazgo principal: 17 logs violan ASCII PURO + CRLF
- Convencion AGENTS.md: Logs = ASCII PURO (por bytes) + CRLF + sin BOM.
- 17 de los 23 logs de hoy tienen 221 bytes no-ASCII en total. Autor medido por cabecera
  **Modelo:** = DeepSeek-V4.1-Flash (serie Tanda-NN). Caracteres:
  U+2014 (guion largo) x dominante, U+00A7 (seccion), U+00ED (i tilde), U+00FC
  (u dieresis), U+00AB/U+00BB (comillas latinas), U+2705 (emoji check). Los 17 en LF puro.
- Numeros afectados: 1965, 1967, 1969, 1970, 1971, 1973, 1974, 1975, 1976, 1977, 1978,
  1979, 1981, 1982, 1983, 1984, 1985.
- No son mojibake (UTF-8 valido) pero violan la convencion. 3 verificados con git ls-files:
  TRACKEADOS -> la violacion ya quedo commiteada. Ajenos: NO tocados, reportados.
- Detalle de bytes por log:

| Log | No-ASCII | EOL |
|---|---|---|
| 1965 | 6 | LF puro |
| 1967 | 6 | LF puro |
| 1969 | 9 | LF puro |
| 1970 | 14 | LF puro |
| 1971 | 9 | LF puro |
| 1973 | 6 | LF puro |
| 1974 | 12 | LF puro |
| 1975 | 12 | LF puro |
| 1976 | 9 | LF puro |
| 1977 | 6 | LF puro |
| 1978 | 27 | LF puro |
| 1979 | 10 | LF puro |
| 1981 | 32 | LF puro |
| 1982 | 14 | LF puro |
| 1983 | 19 | LF puro |
| 1984 | 14 | LF puro |
| 1985 | 16 | LF puro |

## 5. Por que nadie lo vio
scripts/diagnosticar_mojibake.py linea 105: EXCLUIDOS_DIR incluye './Logs'. El gate
anti-mojibake nunca escanea Logs/ y, aunque lo hiciera, busca mojibake, no 'ASCII puro'.
Convencion manual sin gate automatico = familia 'el guard que no guarda'.
Pedido al director (msg 77): trasladar la convencion a DeepSeek-V4.1-Flash y evaluar un
gate de ASCII para Logs/.

## 6. Casa propia verificada
- Log 1968 y Log 1980 (mios, de hoy): ASCII PURO + CRLF + sin BOM.
- Mensajes de canal 73-76 (mios): UTF-8 sin BOM + LF puro + FFFD 0.
- Log 1987 (esta vuelta): 4.996 B, 76 CRLF, 0 LF sueltos, 0 bytes no-ASCII, sin BOM.

## 7. Limites
0 commits / 0 push / 0 archivos ajenos modificados / 0 ediciones a CHECKLIST-GLOBAL.md,
quality.yml, AGENTS.md ni project.godot. Script de barrido en .workbuddy-ai/tmp/ (gitignored).
