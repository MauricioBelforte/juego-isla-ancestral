# 10 - Clasificacion de dependencias de los modulos bloqueados (M01)

**Modulo:** M01 - Fundamentos-Del-Proyecto
**Iteracion:** 10
**Fecha de medicion:** 2026-10-24
**Herramienta:** `scripts/auditar_indice_m01.py --dependencias` (flag nuevo de esta iteracion)
**Suite:** `scripts/test_auditar_indice_m01.py` - 62 checks / 0 fallos / EXIT 0 (x3)

## 1. Que se pidio y que se midio

El director (mensaje 379, punto 5) dio GO a *clasificar los `bloqueado_ambos` por tipo de
dependencia (asset / hardware / cuenta-externa-fundador / decision-del-proyecto), entrega por
bloques*.

**Premisa medida antes de aceptarla:** el mensaje hablaba de **107** modulos. Medido hoy sobre
disco: **111**. La diferencia no es un error de conteo, es el efecto de los flips que el
director aplico despues del 378 (M69/M98/M117 al indice, mas las filas del GLOBAL).

| Medida | Valor | Como se midio |
|---|---|---|
| items del indice maestro | **152** = 32 `[x]` / 120 `[ ]` / 0 `[?]` | conteo por prefijo `^\s*- \[([x? ])\]` |
| items `[ ]` clasificados | 120 | `--pendientes` |
| `bloqueado_ambos` | **111** | checklist propia abierta Y fila GLOBAL no OK |
| `bloqueado_global` | 9 | checklist cerrada, la palanca es la FILA (M04, M35, M94, M118, M125, M141, M142, M149, M152) |
| items abiertos leidos en esos 111 modulos | **2571** | suma de `[ ]` + `[?]` de cada `05-Checklist.md` |

> **Drift medido (no tocado):** la fila 01 de `CHECKLIST-GLOBAL.md` dice `29/152` y el disco dice
> `32/152`. Los 3 de diferencia son exactamente los flips M69/M98/M117 que el director aplico al
> indice sin actualizar la celda *Progreso* de la fila. El GLOBAL no es mio (regla dura): se
> reporta.

## 2. Metodo

Se clasifica el **enunciado** del item, no la anotacion de auditoria: la anotacion es historia y
menciona de todo (un item de audio puede citar `M43`, `Log 2068` y un `KnownIssue` sin que
ninguna de esas cosas sea su dependencia). El corte es el primer separador (`|`, `--`, `::`,
` - **`).

Precedencia: el **primer** tipo que matchea gana, en este orden:

1. `cuenta_externa_fundador` - cuenta/servicio que solo el fundador puede crear
2. `hardware` - exige medir en un dispositivo real
3. `asset` - exige un archivo de arte/audio/3D que no esta en el repo
4. `decision_proyecto` - espera una decision explicita
5. `otro_modulo` - depende de otro modulo (`M##`, descartando la auto-referencia)
6. `trabajo_propio` - el enunciado declara que falta implementar
7. `sin_dependencia_declarada` - residual: el enunciado no declara ninguna dependencia

**Guarda de ceguera (exit 3):** si no se leyo ningun item, o si la cantidad de modulos
clasificados no coincide con los `bloqueado_ambos` esperados, el detector se declara CIEGO.
No se usa un piso absoluto de items: la relacion (clasificados == esperados) si es falsable en
un arbol sintetico.

## 3. Resultado global

| Tipo | Items | % de 2571 |
|---|---|---|
| `cuenta_externa_fundador` | 5 | 0.2% |
| `hardware` | 37 | 1.4% |
| `asset` | 168 | 6.5% |
| `decision_proyecto` | 4 | 0.2% |
| `otro_modulo` | 803 | 31.3% |
| `trabajo_propio` | 74 | 2.9% |
| `sin_dependencia_declarada` | 1478 | 57.5% |

**Modulos sin ninguna dependencia externa: 52.** Modulos con al menos una: 59.

## 4. Precision medida por familia (lo que hace utilizable el numero)

Un conteo por palabra clave no es un veredicto: hay que medir cuanto de lo que marca es real.
Se muestreo deterministicamente (un item cada N, sin elegir) y se leyo cada item.

| Familia | Items | Muestra | Reales | Precision | Lectura |
|---|---|---|---|---|---|
| `cuenta_externa_fundador` | 5 | 5 (todos) | 5 | **100 %** | veredicto firme |
| `hardware` | 37 | 13 (1 de cada 3) | 9 | **69 %** | util como filtro, no como veredicto |
| `asset` | 168 | 34 (1 de cada 5) | 19 | **56 %** | **cota superior**, requiere triage |
| `decision_proyecto` | 4 | 4 (todos) | 4 | **100 %** | veredicto firme |

### 4.1 Dos defectos de patron que se corrigieron en esta iteracion

**(a) `hardware` cazaba implementacion y targets de diseno.** El patron original incluia `FPS`,
`rendimiento` y `frame budget` como tokens sueltos. Medido: **16 de 56 items (28,6 %)** eran
implementacion (`FPS overlay cada 0.5s`, `Implementar metricas de rendimiento`) o targets de
diseno (`Definir objetivo 30 fps minimo / 60 deseado`), que no necesitan ningun dispositivo.
Regla nueva: `hardware` exige **token duro de dispositivo** (`Steam Deck`, `GPU`, `VRAM`,
`hardware`, `dispositivo`, `tactil`, `haptics`, `android`) **o** token de performance **mas un
verbo de medicion** (`validar`/`medir`/`verificar`/`probar`/`testear`/`benchmark`/`profiler`) en
el mismo enunciado. Efecto: 56 -> 37 items.

**(b) `asset` cazaba vocabulario tecnico.** `mesh`, `malla`, `material`, `particula` y `vfx`
entraban como asset, pero `Pool de meshes reutilizado`, `materiales regionales habilitan
variantes` y `particulas de satisfaccion al extraer` son **implementacion en GDScript/escena**,
no un archivo de arte que falte. Se sacaron. Efecto: 206 -> 168 items.

**(c) Ceguera a plurales.** `\bdispositivo\b` no matcheaba *dispositivos*; `\bmesh\b` no
matcheaba *meshes*. Medido sobre el residual: **5 items** con un token de familia en plural que
el patron no cubria. Corregido con `s?` en los tokens correspondientes.

**(d) El residual se llamaba `sin_senal` y se leia como "el detector no vio nada".** El 56 %
en ese cajon hacia pensar en un detector ciego. No lo es: medido, el residual es trabajo de
implementacion real (`Saltar, nadar y escalar del jugador`, `P3: chunks cercanos`). Se renombro
a `sin_dependencia_declarada`, que es lo que efectivamente mide: el enunciado no declara
dependencia externa.

### 4.2 Por que `asset` no llega a veredicto

El vocabulario del proyecto solapa los dos casos. `Audio de recogida (campana suave)` necesita
un archivo; `Sin loops de audio solapados al transicionar` es codigo. `Cubrir los 11 estados de
la FSM con animaciones` necesita animaciones; `Prohibir que la capa de animacion decida
comportamiento` es una regla de diseno. Un matcher de palabras no distingue *necesita el
archivo* de *usa el concepto*, y no hay verbo que los separe de forma confiable.

Consecuencia practica: **168 es una cota superior**. Con la precision medida (~56 %), el orden
de magnitud de bloqueos reales por asset es **~94**, y los otros ~74 son trabajo de
implementacion. La lista completa sale con `--json` para que se pueda triagear item por item.

## 5. Hallazgo principal

De **2571** items abiertos en 111 modulos, los que dependen de algo **fuera del repositorio**
son, como orden de magnitud:

- **5** de una cuenta externa del fundador (100 % de precision, listados abajo);
- **~26** de hardware real (37 marcados, 69 % de precision);
- **~94** de un asset que hay que producir o conseguir (168 marcados, 56 %);
- **4** de una decision explicita.

Es decir: **alrededor del 5 % de la deuda abierta espera a un tercero**. El otro ~95 % es
implementacion, trabajo entre modulos o decision tecnica que el proyecto puede resolver por si
mismo. Y **52 de los 111 modulos no tienen ni un solo item en ninguna familia externa**: su
bloqueo es su propia checklist, no un proveedor.

## 6. BLOQUE 0 - los 5 items que si necesitan al fundador

| Modulo | Item |
|---|---|
| M01 | Verificar ausencia de marca registrada conflictiva [M] → espera decision (flag doc-in: decision legal pendiente) |
| M106 | Definir creación de proyecto en Google Cloud Console [S] |
| M106 | Definir habilitación de Google Drive API [S] |
| M106 | Definir creación de credenciales OAuth [S] |
| M106 | Definir obtención de token de acceso OAuth [S] |

Los 4 de M106 son la configuracion de Google Cloud/OAuth del backup en Drive (M107 ya tiene el
procedimiento escrito en `03-Diseno.md` seccion 5.1 desde el Log 2157). El de M01 es la
verificacion de marca registrada, que ademas arrastra una `flag doc-in` de decision.

### Los 4 items de `decision_proyecto`

| Modulo | Item |
|---|---|
| M01 | Verificar disponibilidad del nombre en Steam (colisiones de título) [S] → espera decision (flag doc-in: decision de identidad pendiente) espera decision (flag d |
| M01 | Verificar dominio/comunidad que use el nombre (colisión de identidad) [S] → espera decision (flag doc-in: decision de identidad pendiente) → pendiente M02 |
| M01 | Anotar la decisión gratis-vs-DLC como pendiente de negocio (no técnica) [S] |
| M01 | Verificar que los módulos dependientes identificados en Requerimientos son correctos → espera decision (flag doc-in: pendiente de validacion de alcance) [S] |

## 7. Los 52 modulos sin ninguna dependencia externa

M109, M93, M70, M41, M17, M22, M39, M20, M104, M123, M116, M24, M136, M105, M150, M121, M145, M103, M59, M65, M102, M43, M81, M86, M111, M13, M146, M02, M108, M137, M138, M46, M51, M122, M143, M147, M28, M79, M80, M90, M92, M112, M131, M140, M148, M23, M64, M75, M77, M82, M88, M95

Estos son los candidatos a cerrar **sin esperar a nadie**: no tienen items marcados como
cuenta externa, hardware, asset ni decision. Ojo con la cota: la precision de `asset` es 56 %, y
eso hace que la lista sea **mas** confiable en este sentido (un falso positivo de asset solo
puede sacar un modulo de esta lista, no meterlo).

## 8. Detalle por bloques (20 modulos cada uno)

Orden: primero los que tienen mas items externos, despues por cantidad de abiertos.
`Cta` = cuenta externa, `Hdw` = hardware, `Asst` = asset, `Dec` = decision, `Mod` = otro modulo.
La columna *Dominante* es el tipo con mas items del modulo (empate: el de mayor precedencia).

### BLOQUE 1 (modulos 1-20 de 111)
| ID | Carpeta | Abiertos | Cta | Hdw | Asst | Dec | Mod | Dominante |
|---|---|---|---|---|---|---|---|---|
| M47 | 48-Animacion | 80 | 0 | 1 | 13 | 0 | 31 | sin_dependencia_declarada |
| M66 | 67-Vehiculos | 93 | 0 | 0 | 12 | 0 | 35 | sin_dependencia_declarada |
| M53 | 54-Mapa | 44 | 0 | 1 | 11 | 0 | 22 | otro_modulo |
| M127 | 128-Identidad-De-Marca | 40 | 0 | 0 | 9 | 0 | 3 | sin_dependencia_declarada |
| M60 | 61-Rendimiento | 30 | 0 | 9 | 0 | 0 | 9 | sin_dependencia_declarada |
| M130 | 131-Creditos | 9 | 0 | 0 | 9 | 0 | 0 | asset |
| M10 | 11-Personaje-Del-Jugador | 45 | 0 | 0 | 8 | 0 | 6 | trabajo_propio |
| M50 | 51-Agua | 26 | 0 | 1 | 7 | 0 | 17 | otro_modulo |
| M33 | 34-Pesca | 49 | 0 | 0 | 7 | 0 | 8 | sin_dependencia_declarada |
| M114 | 115-Hardware | 26 | 0 | 7 | 0 | 0 | 18 | otro_modulo |
| M32 | 33-Agricultura | 43 | 0 | 0 | 6 | 0 | 8 | sin_dependencia_declarada |
| M52 | 53-UI-UX | 20 | 0 | 2 | 4 | 0 | 7 | otro_modulo |
| M54 | 55-Diario-Del-Jugador | 64 | 0 | 0 | 5 | 0 | 26 | sin_dependencia_declarada |
| M30 | 31-Ciclo-Dia-Noche | 44 | 0 | 0 | 5 | 0 | 26 | otro_modulo |
| M62 | 63-Cargas-Y-Streaming | 34 | 0 | 0 | 5 | 0 | 9 | sin_dependencia_declarada |
| M126 | 127-Copyright-Del-Juego | 24 | 0 | 0 | 5 | 0 | 6 | sin_dependencia_declarada |
| M01 | 02-Vision-Y-Concepto | 7 | 1 | 0 | 0 | 4 | 0 | decision_proyecto |
| M73 | 74-Eventos | 58 | 0 | 2 | 2 | 0 | 27 | otro_modulo |
| M36 | 37-Museos-Y-Colecciones | 50 | 0 | 0 | 4 | 0 | 3 | sin_dependencia_declarada |
| M34 | 35-Mineria | 39 | 0 | 0 | 4 | 0 | 14 | sin_dependencia_declarada |

### BLOQUE 2 (modulos 21-40 de 111)
| ID | Carpeta | Abiertos | Cta | Hdw | Asst | Dec | Mod | Dominante |
|---|---|---|---|---|---|---|---|---|
| M56 | 57-Interfaz-De-Control | 25 | 0 | 2 | 2 | 0 | 6 | sin_dependencia_declarada |
| M106 | 107-Backups | 5 | 4 | 0 | 0 | 0 | 0 | cuenta_externa_fundador |
| M19 | 20-Sistema-De-Amistad | 68 | 0 | 0 | 3 | 0 | 11 | sin_dependencia_declarada |
| M26 | 27-Islas-Del-Mundo | 56 | 0 | 0 | 3 | 0 | 36 | otro_modulo |
| M40 | 41-Musica | 50 | 0 | 0 | 3 | 0 | 2 | sin_dependencia_declarada |
| M11 | 12-Camara | 45 | 0 | 0 | 3 | 0 | 10 | sin_dependencia_declarada |
| M12 | 13-Herramientas | 36 | 0 | 1 | 2 | 0 | 30 | otro_modulo |
| M09 | 10-Generacion-Del-Mundo | 16 | 0 | 0 | 3 | 0 | 0 | sin_dependencia_declarada |
| M44 | 45-Arte-3D | 14 | 0 | 0 | 3 | 0 | 1 | sin_dependencia_declarada |
| M74 | 75-Postgame | 101 | 0 | 0 | 2 | 0 | 59 | otro_modulo |
| M55 | 56-Fotografia | 78 | 0 | 0 | 2 | 0 | 23 | sin_dependencia_declarada |
| M16 | 17-Construccion | 49 | 0 | 0 | 2 | 0 | 21 | sin_dependencia_declarada |
| M48 | 49-Iluminacion | 33 | 0 | 2 | 0 | 0 | 11 | sin_dependencia_declarada |
| M63 | 64-IA-De-NPC | 29 | 0 | 1 | 1 | 0 | 8 | sin_dependencia_declarada |
| M84 | 85-Modelos-3D-Legal | 27 | 0 | 0 | 2 | 0 | 2 | trabajo_propio |
| M15 | 16-Crafting | 16 | 0 | 0 | 2 | 0 | 6 | sin_dependencia_declarada |
| M144 | 145-Diseno-De-Experiencia | 13 | 0 | 0 | 2 | 0 | 7 | otro_modulo |
| M45 | 46-Arte-2D | 9 | 0 | 0 | 2 | 0 | 3 | sin_dependencia_declarada |
| M128 | 129-Merchandising | 7 | 0 | 0 | 2 | 0 | 0 | sin_dependencia_declarada |
| M03 | 04-Game-Engine | 2 | 0 | 2 | 0 | 0 | 0 | hardware |

### BLOQUE 3 (modulos 41-60 de 111)
| ID | Carpeta | Abiertos | Cta | Hdw | Asst | Dec | Mod | Dominante |
|---|---|---|---|---|---|---|---|---|
| M71 | 72-Sistema-De-Logros | 92 | 0 | 1 | 0 | 0 | 14 | sin_dependencia_declarada |
| M27 | 28-Viajes | 77 | 0 | 0 | 1 | 0 | 18 | sin_dependencia_declarada |
| M72 | 73-Coleccionables | 72 | 0 | 0 | 1 | 0 | 39 | otro_modulo |
| M91 | 92-Tutorial | 53 | 0 | 0 | 1 | 0 | 10 | sin_dependencia_declarada |
| M67 | 68-Transporte-Y-Navegacion | 28 | 0 | 0 | 1 | 0 | 17 | otro_modulo |
| M139 | 140-Alpha | 24 | 0 | 0 | 1 | 0 | 13 | otro_modulo |
| M68 | 69-Fast-Travel | 22 | 0 | 0 | 1 | 0 | 6 | sin_dependencia_declarada |
| M76 | 77-Online-Y-Red | 22 | 0 | 1 | 0 | 0 | 1 | sin_dependencia_declarada |
| M57 | 58-Accesibilidad | 17 | 0 | 0 | 1 | 0 | 6 | sin_dependencia_declarada |
| M58 | 59-Guardado | 15 | 0 | 0 | 1 | 0 | 5 | sin_dependencia_declarada |
| M14 | 15-Recursos | 14 | 0 | 0 | 1 | 0 | 8 | otro_modulo |
| M49 | 50-Vegetacion | 11 | 0 | 1 | 0 | 0 | 1 | sin_dependencia_declarada |
| M87 | 88-Fuentes-Tipograficas | 11 | 0 | 1 | 0 | 0 | 2 | sin_dependencia_declarada |
| M08 | 09-Terreno-Y-Geografia | 9 | 0 | 0 | 1 | 0 | 5 | otro_modulo |
| M25 | 26-Templo-Subterraneo | 7 | 0 | 0 | 1 | 0 | 3 | otro_modulo |
| M61 | 62-Memoria | 5 | 0 | 0 | 1 | 0 | 1 | sin_dependencia_declarada |
| M107 | 108-Pipeline-De-Assets | 3 | 0 | 1 | 0 | 0 | 1 | hardware |
| M31 | 32-Clima | 2 | 0 | 1 | 0 | 0 | 0 | hardware |
| M29 | 30-Reloj-En-Tiempo-Real | 1 | 0 | 0 | 1 | 0 | 0 | asset |
| M109 | 110-Debug-Menu | 75 | 0 | 0 | 0 | 0 | 2 | sin_dependencia_declarada |

### BLOQUE 4 (modulos 61-80 de 111)
| ID | Carpeta | Abiertos | Cta | Hdw | Asst | Dec | Mod | Dominante |
|---|---|---|---|---|---|---|---|---|
| M93 | 94-Retencion-Sin-FOMO | 55 | 0 | 0 | 0 | 0 | 12 | sin_dependencia_declarada |
| M70 | 71-Progresion | 45 | 0 | 0 | 0 | 0 | 18 | sin_dependencia_declarada |
| M41 | 42-Sonido-Ambiental | 38 | 0 | 0 | 0 | 0 | 1 | sin_dependencia_declarada |
| M17 | 18-Casas | 33 | 0 | 0 | 0 | 0 | 4 | sin_dependencia_declarada |
| M22 | 23-Historias-Secundarias | 32 | 0 | 0 | 0 | 0 | 8 | sin_dependencia_declarada |
| M39 | 40-Infraestructura | 31 | 0 | 0 | 0 | 0 | 7 | sin_dependencia_declarada |
| M20 | 21-Dialogos | 30 | 0 | 0 | 0 | 0 | 7 | sin_dependencia_declarada |
| M104 | 105-Telemetria-De-Gameplay | 28 | 0 | 0 | 0 | 0 | 4 | sin_dependencia_declarada |
| M123 | 124-Contenido-Generado-Por-Usuarios | 25 | 0 | 0 | 0 | 0 | 6 | sin_dependencia_declarada |
| M116 | 117-Build-System | 16 | 0 | 0 | 0 | 0 | 14 | otro_modulo |
| M24 | 25-Ruinas | 16 | 0 | 0 | 0 | 0 | 3 | trabajo_propio |
| M136 | 137-Prototipo | 13 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M105 | 106-Seguridad | 12 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M150 | 151-Control-Final | 12 | 0 | 0 | 0 | 0 | 3 | sin_dependencia_declarada |
| M121 | 122-Crash-Reporting | 10 | 0 | 0 | 0 | 0 | 3 | sin_dependencia_declarada |
| M145 | 146-Diseno-Emocional | 9 | 0 | 0 | 0 | 0 | 9 | otro_modulo |
| M103 | 104-Analytics | 8 | 0 | 0 | 0 | 0 | 3 | sin_dependencia_declarada |
| M59 | 60-Datos-Y-Serializacion | 7 | 0 | 0 | 0 | 0 | 6 | otro_modulo |
| M65 | 66-Anti-Softlock | 7 | 0 | 0 | 0 | 0 | 5 | otro_modulo |
| M102 | 103-Logging | 6 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |

### BLOQUE 5 (modulos 81-100 de 111)
| ID | Carpeta | Abiertos | Cta | Hdw | Asst | Dec | Mod | Dominante |
|---|---|---|---|---|---|---|---|---|
| M43 | 44-ASMR-Y-Feedback | 6 | 0 | 0 | 0 | 0 | 6 | otro_modulo |
| M81 | 82-Clasificacion-Por-Edades | 5 | 0 | 0 | 0 | 0 | 1 | sin_dependencia_declarada |
| M86 | 87-Localizacion | 5 | 0 | 0 | 0 | 0 | 4 | otro_modulo |
| M111 | 112-Testing-Automatico | 4 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M13 | 14-Inventario | 4 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M146 | 147-World-Building | 4 | 0 | 0 | 0 | 0 | 1 | sin_dependencia_declarada |
| M02 | 03-Documentacion-Del-Proyecto | 3 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M108 | 109-Herramientas-Internas | 3 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M137 | 138-Vertical-Slice | 3 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M138 | 139-Pre-Alpha | 3 | 0 | 0 | 0 | 0 | 3 | otro_modulo |
| M46 | 47-Texturas-Y-Materiales | 3 | 0 | 0 | 0 | 0 | 2 | otro_modulo |
| M51 | 52-Particulas-Y-VFX | 3 | 0 | 0 | 0 | 0 | 1 | sin_dependencia_declarada |
| M122 | 123-Modding | 2 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M143 | 144-Despues-Del-Lanzamiento | 2 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M147 | 148-Lore-Ambiental | 2 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M28 | 29-Tiempo-Y-Calendario | 2 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M79 | 80-Legal-Privacidad | 2 | 0 | 0 | 0 | 0 | 2 | otro_modulo |
| M80 | 81-Legal-Menores | 2 | 0 | 0 | 0 | 0 | 1 | otro_modulo |
| M90 | 91-Configuracion-De-Audio | 2 | 0 | 0 | 0 | 0 | 0 | trabajo_propio |
| M92 | 93-Balance | 2 | 0 | 0 | 0 | 0 | 1 | otro_modulo |

### BLOQUE 6 (modulos 101-111 de 111)
| ID | Carpeta | Abiertos | Cta | Hdw | Asst | Dec | Mod | Dominante |
|---|---|---|---|---|---|---|---|---|
| M112 | 113-Pruebas-De-Stress | 1 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M131 | 132-Produccion-De-Equipo | 1 | 0 | 0 | 0 | 0 | 0 | trabajo_propio |
| M140 | 141-Beta | 1 | 0 | 0 | 0 | 0 | 1 | otro_modulo |
| M148 | 149-Nombres-Y-Nomenclatura | 1 | 0 | 0 | 0 | 0 | 1 | otro_modulo |
| M23 | 24-Templos-Y-Puzzles | 1 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M64 | 65-Animales-IA | 1 | 0 | 0 | 0 | 0 | 1 | otro_modulo |
| M75 | 76-Multijugador | 1 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M77 | 78-Legal-Propiedad-Intelectual | 1 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M82 | 83-Licencias-De-Software | 1 | 0 | 0 | 0 | 0 | 0 | sin_dependencia_declarada |
| M88 | 89-Diseno-De-Menus | 1 | 0 | 0 | 0 | 0 | 1 | otro_modulo |
| M95 | 96-Plataformas | 1 | 0 | 0 | 0 | 0 | 1 | otro_modulo |

## 9. Limitaciones declaradas

1. **`asset` es cota superior** (56 % de precision). No usar el numero como veredicto por
   modulo sin leer los items.
2. **`hardware` es filtro, no veredicto** (69 %). Siguen dentro casos medibles headless
   (`Medir rendimiento de pathfinding con 60 NPCs` es CPU) y casos de documentacion
   (`Documentar requisitos recomendados de GPU` matchea por el token duro, no por medir).
3. **`sin_dependencia_declarada` no prueba que no haya dependencia**: prueba que el enunciado no
   la declara. Un item vago cae ahi. Medido: solo 5 items del residual tenian un token de
   familia en plural que el patron no cubria, asi que el residual no es un agujero grande.
4. **La clasificacion es del enunciado, no del fondo.** Un item puede estar mal enunciado y
   clasificar bien o al reves.

## 10. Como reproducirlo

```bash
python scripts/auditar_indice_m01.py --dependencias            # resumen + modulos externos
python scripts/auditar_indice_m01.py --dependencias --bloque 3 # bloque 3 de 20
python scripts/auditar_indice_m01.py --dependencias --json     # todo, item por item
python scripts/test_auditar_indice_m01.py                      # 62 checks
```

`--json` devuelve `dependencias.detalle[i].items[j]` con `tipo`, `familias` (todas las que
matchearon) y `evidencia` (el texto exacto que disparo el match), para auditar item por item.

## 11. Historia de iteraciones

- iter. 8 (Log 2160): diagnostico del indice, 6 candidatos nuevos.
- iter. 9 (Log 2162): `--pendientes`, clasificacion por condicion de bloqueo (123 items).
- iter. 10 (este doc): `--dependencias`, clasificacion por TIPO de dependencia (2571 items de
  111 modulos), con precision medida por familia y dos correcciones de patron.

