# Log 2049 - M119 - Standby: afinado de los 7 [ ] restantes + barrido de Totales por conteo (anti-drift)

- **Modelo:** Step-5-WorkBuddy
- **Plataforma:** WorkBuddy AI
- **Fecha:** 2026-10-20 06:05 (GMT-3)
- **Rama:** RAMA 1 (msg 122 del director, acusado con msg 123) + RAMA 2 (tanda de standby)
- **Tarea:** (a) afinar los 7 `[ ]` restantes de M119-Actualizaciones; (b) barrido estilo agnes por conteo: Totales vs marcas (anti-drift) + punto ciego de `[ ]` sin nota
- **Modulo:** M119-Actualizaciones (module propio de la tanda) + barrido de solo-lectura sobre los 167 checklists

## 1. Afinado de los 7 [ ] de M119 (0 flips, 0 inflacion)

Estado de partida: los 7 `[ ]` = items de implementacion revertidos por BUG-070
Familia A (P-41, Log 1157): marcas `[x]` sobre codigo ausente. Disciplina: se
quedan `[ ]`; se afina la cita, no la marca.

Evidencia medida HOY en disco (no heredada):

| Medida | Valor |
|---|---|
| `class_name GameVersion` / `UpdateChecker` / `UpdateDownloader` / `SaveMigrator` / `RollbackManager` en `game/` | 0 referencias cada uno |
| `game/isla-ancestral/scripts/updates/update_manager.gd` | 93 lineas / 10 funciones (`_ready`, `_cargar_versions`, `_registrar_servicio`, `comparar_versiones`, `_parsear`, `hay_actualizacion`, `version_remota`, `set_canal`, `politica`, `_guardar_version`) |
| Funciones de descarga / rollback en UpdateManager | 0 (no existen `download`, `rollback`, `restore`) |

Correcciones aplicadas a `119-Actualizaciones/plan-actual/05-Checklist.md`
(18263 -> 18906 bytes; 173 CRLF / 21 LF sueltos preservados por linea; sin BOM;
conteo final medido por prefijo: 111 [x] / 0 [?] / 7 [ ] = 118, igual que antes):

1. **L48 y L87 tenian notas OBSOLETAS** decian "no existe seccion propia en
   `03-Diseno.md`", pero mi propia tanda del Log 2023 SI agrego las secciones
   `UpdateDownloader` y `RollbackManager`. Notas corregidas citando
   `03-Diseno.md` L195-237 (T-022) y L239-280 (T-049 a T-056).
2. **L24/L25/L27/L35/L61**: citas de diseno re-verificadas HOY con numeros de
   linea frescos + DoD explicito para cerrar cada item.

2 divergencias diseno<->checklist encontradas y alineadas HOY en
`03-Diseno.md` (9621 -> 10180 bytes, LF puro conservado, sin BOM):

- El item pide `is_same_major_minor()` y el diseno sec.2 solo definia
  `to_string()` / `is_newer_than()` -> helper agregado en L70-73.
- El item pide `UpdateChecker.check_latest()` y el diseno solo tenia
  `check_steam()` / `check_gog()` / `check_manual()` -> fachada
  `check_latest()` agregada en L164-169 (despacha por canal de versions.json;
  NO crea un segundo sistema de versionado).

Cero marcas aplicadas. Los 7 items siguen `[ ]` honestos: el codigo no existe
(BUG-070 Familia A) y flippearlos seria re-inflar la metrica.

## 2. Barrido de Totales por conteo (anti-drift + punto ciego)

Script de solo-lectura: `scripts-prueba-temp/sweep_totales_step5.py`
(medicion por prefijo de linea sobre cada `05-Checklist.md`; universo 167
checklists). Trampa recorrida: el parser por "primera linea que matchea" y el
parser por "ultima linea" FABRICAN falsos (ver seccion 4).

Universo medido HOY: **24014 items** = 19511 [x] / 1131 [?] / 3372 [ ].

### 2.1 Drift real verificado linea por linea: 7 modulos

| Modulo | Totales vigente | Medido HOY | diff |
|---|---|---|---|
| 11-Personaje-Del-Jugador | 75 [x] / 0 [ ] / 48 [?] (L173) | 78 / 0 / 45 | 6 |
| 49-Iluminacion | 105 / 0 / 38 (L306/L310) | 110 / 0 / 33 | 10 |
| 50-Vegetacion | 129 / 10 / 3 (L276) | 131 / 8 / 3 | 4 |
| 86-IA-Generativa | 128 / 0 / 1 (L189) | 128 / 0 / 0 | 1 |
| 125-Terminos-De-Servicio | 104 / 0 / 1 (L177) | 105 / 0 / 0 | 1 |
| 126-Marketing-Legal | 100 / 0 / 1 (L24) | 101 / 0 / 0 | 1 |
| 90-Configuracion-Grafica | 245 / 0 / 4 (L341) | 249 / 0 / 0 | 8 |

Sincronizados HOY los 2 que son consecuencia de MIS tandas (Log 2040):

- **M90** `05-Checklist.md` L341: 245/0/4 -> **249/0/0** (55915 -> 56115 bytes;
  CRLF preservado 355/355).
- **M11** `05-Checklist.md` L173: 75/0/48 -> **78/0/45** (34324 -> 34505 bytes;
  LF puro preservado 335/335).

Los otros 5 (M49, M50, M86, M125, M126) son ajenos: NO tocados, reportados al
director con el conteo medido para ruteo.

### 2.2 Sin Totales vigente: 1 modulo

- **151-Control-Final**: su unica linea `**Totales:**` (L373) esta tachada con
  `~~` (deprecada). Medido HOY: 94 [x] / 6 [?] / 67 [ ] = 167. Necesita linea
  nueva; reportado al director.

### 2.3 Punto ciego: [ ] sin nota de deuda/dueno/estado

**2992 items `[ ]` en 62 modulos** no llevan ninguna nota de deuda, dueno ni
estado (top: 01-Fundamentos 123/126, 138-Vertical-Slice 117/120,
137-Prototipo 114/124, 75-Postgame 111/113, 67-Vehiculos 110/112). No es
corrupcion: son modulos de spec sin auditar. Queda como inventario para
tandas futuras; NO es deuda oculta, es deuda explicitamente sin auditar.

## 3. Estado de la cola

- Mensajes del director: 122 procesado (acuse msg 123). Tracker -> 122.
- Pool de canal: consumido 123, reexpandido a 124..223 (100 verificados).
- Pool de logs: cabeza medida 2048 justo antes de reservar; otro agente tomo el
  2048 en el intervalo -> reservado **2049** (pool ahora 2050..3000).
- BACKLOG-MASTER: 7 `[ ]` de M119 afinados (siguen `[ ]`); REPOBLACION V3
  items 40-46 NO existen con esa numeracion: el director citaba "items 40-46"
  y en el backlog son los items 31-37 (discrepancia reportada en msg 123).

## 4. Trampas measures esta vuelta (para el skill)

1. **Parser por formato fabrica falsos en los dos sentidos**: el regex de
   "primera linea con Totales + digitos" dio 4 FALSOS positivas (M31, M109,
   M59, M32, M113, M83: matcheaba notas historicas incrustadas DENTRO de la
   linea de Totales vigente, p.ej. "Conteo real = 120 [x] / 3 [?] / 15 [ ]"
   dentro de la nota de L227 de M109). Un "ultima linea" heuristico dio 18
   "drifts" de los cuales 11 eran falsos. La verificacion honesta exigio leer
   las lineas de cada candidato.
2. **`str.splitlines()` NO es equivalente a `bytes.splitlines()`** para
   splice por bytes: `str.splitlines()` parte tambien en \x0b \x0c \x85
   U+2028... El `05-Checklist` de M90 tiene esos caracteres: la linea de
   Totales es la 352 por str pero la **341** por bytes. Buscar por CONTENIDO,
   nunca por indice, al editar por bytes.
3. **EOL mixto dentro de un archivo**: M119 tiene 173 CRLF + 21 LF sueltos;
   el splice preserva el terminador de cada linea (medido, no normalizado).
4. Nota de deuda dentro de la linea de Totales se cuenta dos veces si el
   regex no ancla: mismo patron que Log 1963, ahora en el universo Totales.

## 5. Pendientes para el director

- Ruteo de los 5 drifts ajenos (M49 110/0/33, M50 131/8/3, M86 128/0/0,
  M125 105/0/0, M126 101/0/0) y de la linea nueva de Totales de M151
  (medido 94/6/67).
- Los 7 `[ ]` de M119 siguen abiertos por diseno (BUG-070 Familia A):
  cerrarlos exige implementacion (duenos M59/M96/M118/M107).
- Commits de la tanda previos siguen pendientes de autorizacion.
