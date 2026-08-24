**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# Referencia Cruzada Maestra — Todos los Módulos

> **Propósito:** Al trabajar en cualquier módulo, consultar rápidamente qué otros módulos necesita y qué otros módulos lo usan.
>
> **Cómo usar:** Buscá el módulo en la tabla, identificá las dependencias y abrí solo esos archivos.

---

## CORE (Fundamentos, Engine, Arquitectura)

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 001 | Fundamentos del Proyecto | — | M002, M003, M004, M006, M078, M133, M145, M152 |
| 002 | Visión y Concepto | M001 | — |
| 003 | Documentación del Proyecto | M001 | — |
| 004 | Game Engine | M001 | M005, M007, M057, M096, M103, M109, M110, M111, M115, M154 |
| 005 | Lenguaje y Programación | M004 | — |
| 006 | Control de Versiones | M001 | — |
| 007 | Arquitectura General | M004 | M008, M011, M029, M036, M049, M059 |

## MUNDO (Voxel, Terreno, Generación)

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 008 | Mundo Voxel | M007 | M009, M010, M017, M035, M050, M051, M061, M063, M137 |
| 009 | Terreno y Geografía | M008 | — |
| 010 | Generación del Mundo | M008 | — |

## JUGADOR (Personaje, Cámara, Herramientas, Inventario)

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 011 | Personaje del Jugador | M007 | M012, M013, M014, M019, M048, M053, M070, M137, M155, M156 |
| 012 | Cámara | M011 | — |
| 013 | Herramientas | M011 | M024, M035, M070, M158 |
| 014 | Inventario | M011 | M015, M016, M017, M053, M059, M137, M155, M159 |
| 015 | Recursos | M014 | M016, M038 |
| 016 | Crafting | M014, M015 | M038, M159 |

## CONSTRUCCIÓN Y HOGAR

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 017 | Construcción | M008, M014 | M018, M033, M160 |
| 018 | Casas | M017 | M159, M160 |

## NPCS Y RELACIONES

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 019 | NPC y Vecinos | M011, M025 | M020, M021, M048, M064, M138, M157, M161, M162 |
| 020 | Sistema de Amistad | M019 | M038, M093, M162 |
| 021 | Diálogos | M019 | M022, M087, M162 |
| 161 | Diseño Visual de NPCs | M019, M045, M046, M155, M159 | M162 |
| 162 | Diálogos Contextuales de NPCs | M019, M020, M021, M022, M029, M160, M161 | — |

## HISTORIA Y NARRATIVA

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 022 | Historia Principal | M021, M028 | M023, M028, M066, M071, M075, M147, M157, M162 |
| 023 | Historias Secundarias | M022 | — |
| 147 | World Building | M022 | M148, M149 |
| 148 | Lore Ambiental | M024, M147 | — |
| 149 | Nombres y Nomenclatura | M147 | M150 |
| 150 | Diseño Sonoro Narrativo | M149 | — |

## TEMPLOS Y PUZZLES

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 024 | Templos y Puzzles | M013 | M025, M026, M051, M148, M157 |
| 025 | Ruinas | M024 | M019, M026 |
| 026 | Templo Subterráneo | M024, M025 | M066, M138 |

## ISLAS Y VIAJES

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 027 | Islas del Mundo | M028, M029 | M028, M158, M160 |
| 028 | Viajes | M022, M027 | M022, M027, M067, M068, M069, M158 |
| 067 | Vehículos | M028 | M068 |
| 068 | Transporte y Navegación | M028, M067 | — |
| 069 | Fast Travel | M028 | M157 |
| 157 | Medios de Transporte | M019, M022, M024, M069 | — |

## TIEMPO Y CLIMA

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 029 | Tiempo y Calendario | M007 | M027, M030, M031, M032, M033, M074, M162 |
| 030 | Reloj en Tiempo Real | M029 | M074 |
| 031 | Ciclo Día/Noche | M029 | M032, M036 |
| 032 | Clima | M029, M031 | M034 |

## ACTIVIDADES (Agricultura, Pesca, Minería)

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 033 | Agricultura | M017, M029 | — |
| 034 | Pesca | M032 | — |
| 035 | Minería | M008, M013 | — |
| 036 | Fauna | M007, M031 | M037, M065, M073 |
| 037 | Museos y Colecciones | M036 | — |

## ECONOMÍA Y TIENDAS

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 038 | Economía | M015, M016, M020 | M039, M040, M071, M093, M095, M158 |
| 039 | Tiendas | M038 | M160 |
| 040 | Infraestructura | M038 | — |

## AUDIO (Música, SFX, Ambiente)

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 041 | Música | — | M042, M043, M084 |
| 042 | Sonido Ambiental | M041 | — |
| 043 | Efectos de Sonido | M041 | M044 |
| 044 | ASMR y Feedback | M043 | — |

## ARTE (3D, 2D, Texturas, Animación)

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 045 | Arte 3D | — | M046, M047, M048, M049, M050, M052, M085, M108, M130, M159, ... |
| 046 | Arte 2D | M045 | M130, M161 |
| 047 | Texturas y Materiales | M045 | — |
| 048 | Animación | M011, M019, M045 | — |
| 049 | Iluminación | M007, M045 | M061 |
| 050 | Vegetación | M008, M045 | — |
| 051 | Agua | M008, M024 | — |
| 052 | Partículas y VFX | M045 | — |

## UI/UX Y ACCESIBILIDAD

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 053 | UI/UX | M011, M014 | M054, M055, M056, M058, M087, M088, M089, M090, M091, M092 |
| 054 | Mapa | M053 | — |
| 055 | Diario del Jugador | M053 | M083 |
| 056 | Fotografía | M053 | — |
| 057 | Interfaz de Control | M004 | M058 |
| 058 | Accesibilidad | M053, M057 | — |
| 088 | Fuentes Tipográficas | M053 | — |
| 089 | Diseño de Menús | M053 | — |
| 090 | Configuración Gráfica | M053 | — |
| 091 | Configuración de Audio | M053 | — |

## PERSISTENCIA Y RENDIMIENTO

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 059 | Guardado | M007, M014 | M060, M107, M119, M137 |
| 060 | Datos y Serialización | M059 | — |
| 061 | Rendimiento | M008, M049 | M062, M063, M064, M115 |
| 062 | Memoria | M061 | — |
| 063 | Cargas y Streaming | M008, M061 | — |

## IA

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 064 | IA de NPC | M019, M061 | M065 |
| 065 | Animales IA | M036, M064 | — |

## SISTEMAS DE JUEGO

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 066 | Anti-Softlock | M022, M026 | — |
| 070 | Interacciones | M011, M013 | M092 |
| 071 | Progresión | M022, M038 | M072, M073 |
| 072 | Sistema de Logros | M071 | — |
| 073 | Coleccionables | M036, M071 | — |
| 074 | Eventos | M029, M030 | — |
| 075 | Postgame | M022 | — |
| 092 | Tutorial | M053, M070 | — |
| 093 | Balance | M020, M038 | M094 |
| 094 | Retención sin FOMO | M093 | — |

## MULTIJUGADOR Y RED

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 076 | Multijugador | — | M077 |
| 077 | Online y Red | M076 | M106 |
| 106 | Seguridad | M077 | — |

## LEGAL

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 078 | Legal — Propiedad Intelectual | M001 | M079, M080, M082, M084, M085, M086, M125, M126, M127, M128 |
| 079 | Legal — Contratos | M078 | — |
| 080 | Legal — Privacidad | M078 | M081 |
| 081 | Legal — Menores | M080 | — |
| 082 | Clasificación por Edades | M078 | — |
| 083 | Licencias de Software | M055, M117 | — |
| 084 | Música y Audio — Legal | M041, M078 | — |
| 085 | Modelos 3D — Legal | M045, M078 | — |
| 086 | IA Generativa | M078 | — |
| 125 | Términos de Servicio | M078 | — |
| 126 | Marketing Legal | M078 | — |
| 127 | Copyright del Juego | M078 | — |

## LOCALIZACIÓN E IDENTIDAD

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 087 | Localización | M021, M053 | — |
| 128 | Identidad de Marca | M078 | M130 |
| 130 | Artbook | M045, M046, M128, M129, M131 | — |

## MONETIZACIÓN Y PLATAFORMAS

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 095 | Monetización | M038 | M120 |
| 096 | Plataformas | M004 | M097 |
| 097 | Steam / Store Page | M096 | M098, M099, M143 |
| 098 | Trailer | M097 | — |
| 099 | Marketing | M097 | M100 |
| 100 | Community Management | M099 | — |
| 120 | DLC y Expansiones | M095, M142 | — |
| 121 | Soporte Post-Lanzamiento | M142 | — |
| 129 | Merchandising | M142 | M130 |

## CALIDAD Y TESTING

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 101 | QA General | M110 | M102, M114 |
| 102 | Bug Tracking | M101 | — |
| 103 | Logging | M004 | M104, M122, M154 |
| 104 | Analytics | M103 | M105 |
| 105 | Telemetría de Gameplay | M104 | — |
| 107 | Backups | M059 | — |
| 110 | Debug Menu | M004 | M101 |
| 111 | Código de Calidad | M004 | M112 |
| 112 | Testing Automático | M111 | M113 |
| 113 | Pruebas de Stress | M112 | — |
| 114 | Playtest | M101, M137 | — |
| 122 | Crash Reporting | M103 | — |

## HARDWARE Y BUILD

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 115 | Hardware | M004, M061 | — |
| 116 | Instalador | — | M117 |
| 117 | Build System | M116 | M083, M118, M119, M123 |
| 118 | CI/CD | M117 | — |
| 119 | Actualizaciones | M059, M117 | — |
| 123 | Modding | M117 | M124 |
| 124 | Contenido Generado por Usuarios | M123 | — |

## PRODUCCIÓN Y GESTIÓN

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 131 | Créditos | M142 | M130 |
| 132 | Producción del Equipo | M134 | — |
| 133 | Gestión del Proyecto | M001 | M134, M135, M136 |
| 134 | Presupuesto | M133 | M132 |
| 135 | Riesgos del Proyecto | M133 | M136 |
| 136 | Roadmap | M133, M135 | — |

## HITOS DE LANZAMIENTO

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 137 | Prototipo | M008, M011, M014, M059 | M114, M138 |
| 138 | Vertical Slice | M019, M026, M137 | M139 |
| 139 | Pre-Alpha | M138 | M140 |
| 140 | Alpha | M139 | M141 |
| 141 | Beta | M140 | M142 |
| 142 | Release Candidate | M141 | M120, M121, M129, M131, M143 |
| 143 | Lanzamiento | M097, M142 | M144, M151 |
| 144 | Después del Lanzamiento | M143 | — |

## DISEÑO EXPERIENCIA

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 145 | Diseño de Experiencia | M001 | M146 |
| 146 | Diseño Emocional | M145 | — |
| 151 | Control Final | M143 | M153 |
| 152 | Principios Innegociables | M001 | — |
| 153 | Objetivo Final del Proyecto | M151 | — |
| 154 | Visión del Agente | M004, M103 | — |

## MÓDULOS AVANZADOS (155-162)

| ID | Módulo | Depende de | Usado por |
|----|--------|------------|-----------|
| 155 | Vestimenta y Accesorios | M011, M014, M156 | M156, M161 |
| 156 | Terrenos y Movimiento Diferenciado | M011, M155 | M155 |
| 158 | Herramientas y Desbloqueo de Zonas | M013, M027, M028, M038 | — |
| 159 | Catálogo de Objetos | M014, M016, M018, M045 | M160, M161 |
| 160 | Diseño de Ubicaciones del Mundo | M017, M018, M027, M039, M159 | M162 |

---

## Top 20 Módulos Más Referenciados

> Estos módulos son los que más veces aparecen como dependencia. Conocerlos bien acelera todo el desarrollo.

| Pos | ID | Módulo | Veces referenciado |
|-----|----|--------|--------------------|
| 1 | 045 | Arte 3D | 11 |
| 2 | 004 | Game Engine | 10 |
| 3 | 011 | Personaje del Jugador | 10 |
| 4 | 053 | UI/UX | 10 |
| 5 | 078 | Legal — Propiedad Intelectual | 10 |
| 6 | 008 | Mundo Voxel | 9 |
| 7 | 001 | Fundamentos del Proyecto | 8 |
| 8 | 014 | Inventario | 8 |
| 9 | 019 | NPC y Vecinos | 8 |
| 10 | 022 | Historia Principal | 8 |
| 11 | 029 | Tiempo y Calendario | 7 |
| 12 | 007 | Arquitectura General | 6 |
| 13 | 028 | Viajes | 6 |
| 14 | 038 | Economía | 6 |
| 15 | 024 | Templos y Puzzles | 5 |
| 16 | 142 | Release Candidate | 5 |
| 17 | 013 | Herramientas | 4 |
| 18 | 059 | Guardado | 4 |
| 19 | 061 | Rendimiento | 4 |
| 20 | 117 | Build System | 4 |

---

## Flujo de Trabajo: Qué leer antes de codificar

| Estoy trabajando en... | Lee primero... | Luego... |
|------------------------|----------------|----------|
| Cualquier cosa nueva | M001 (Fundamentos), M152 (Principios) | M004 (Engine), M007 (Arquitectura) |
| Un sistema de gameplay | M011 (Personaje), M014 (Inventario) | El módulo específico + sus dependencias |
| NPCs o diálogos | M019 (NPCs), M021 (Diálogos) | M161 (Visual NPCs), M162 (Diálogos Contextuales) |
| Historia o narrativa | M022 (Historia), M147 (World Building) | M023 (Secundarias), M148 (Lore) |
| Economía o tiendas | M038 (Economía), M039 (Tiendas) | M093 (Balance), M158 (Herramientas) |
| Arte o assets | M045 (Arte 3D), M108 (Pipeline) | M046-052 (subdominios de arte) |
| UI o menús | M053 (UI/UX), M089 (Menús) | M058 (Accesibilidad), M087 (Localización) |
| Rendimiento | M061 (Rendimiento), M062 (Memoria) | M063 (Streaming), M115 (Hardware) |
| IA de NPCs | M064 (IA NPC), M019 (NPCs) | M065 (Animales), M061 (Rendimiento) |
| Build y deploy | M117 (Build), M118 (CI/CD) | M116 (Instalador), M083 (Licencias) |
| World building | M147 (WB), M149 (Nombres) | M148 (Lore), M022 (Historia) |
| Módulos nuevos 155-162 | M155-M162 específicos | M11, M14, M19, M21, M22 como base |
