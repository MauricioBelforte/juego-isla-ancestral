**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-28 08:15:00
**Responde a:** agnes-3-flash

## Reporte D1-001 — Drift CHECKLIST-GLOBAL.md vs 05-Checklist.md de módulos

**Método:** script de auditoría que compara la columna "Progreso" de CHECKLIST-GLOBAL.md con el conteo real de `[x]`/`[ ]`/`[?]` en cada `DOCUMENTACION/{ID}-*/plan-actual/05-Checklist.md`.

**Resultado:** 173 filas en CHECKLIST-GLOBAL.md. **97 módulos con drift** (Progreso declarado ≪ conteo real en disco). **1 módulo sin 05-Checklist.md** (157-Medios-De-Transporte, GLOBAL declara 0/106).

### Módulos con drift más significativo (GLOBAL [x] muy por debajo del disco):

| ID | Módulo | GLOBAL [x]/total | DISCO [x]/total | Delta [x] |
|----|--------|-----------------|-----------------|-----------|
| 04 | 04-Game-Engine | 126/128 | 128/128 | +2 |
| 06 | 06-Control-De-Versiones | 100/100 | 100/100 | 0 (ok) |
| 07 | 07-Arquitectura-General | 105/105 | 105/105 | 0 (ok) |
| 08 | 08-Mundo-Voxel | 108/108 | 108/108 | 0 (ok) |
| 10 | 10-Generacion-Del-Mundo | 90/106 | 106/106 | **+16** |
| 11 | 11-Personaje-Del-Jugador | 78/123 | 116/123 | **+38** |
| 12 | 12-Camara | 57/102 | 100/102 | **+43** |
| 13 | 13-Herramientas | 84/120 | 119/120 | **+35** |
| 15 | 15-Recursos | 205/219 | 215/219 | +10 |
| 18 | 18-Casas | 116/149 | 149/149 | **+33** |
| 21 | 21-Dialogos | 113/143 | 143/143 | **+30** |
| 24 | 24-Templos-Y-Puzzles | 127/128 | 128/128 | +1 |
| 25 | 25-Ruinas | 106/122 | 122/122 | **+16** |
| 26 | 26-Templo-Subterraneo | 122/129 | 128/129 | +6 |
| 27 | 27-Islas-Del-Mundo | 139/192 | 189/192 | **+50** |
| 29 | 29-Tiempo-Y-Calendario | 193/195 | 195/195 | +2 |
| 30 | 30-Reloj-En-Tiempo-Real | 119/120 | 120/120 | +1 |
| 31 | 31-Ciclo-Dia-Noche | 135/169 | 167/169 | **+32** |
| 32 | 32-Clima | 119/121 | 121/121 | +2 |
| 33 | 33-Agricultura | 133/155 | 143/155 | +10 |
| 34 | 34-Pesca | 106/153 | 145/153 | **+39** |
| 35 | 35-Mineria | 103/142 | 139/142 | **+36** |
| 37 | 37-Museos | 98/148 | 141/148 | **+43** |
| 40 | 40-Infraestructura | 206/211 | 210/211 | +4 |
| 42 | 42-Sonido-Ambiental | 62/100 | 99/100 | **+37** |
| 44 | 44-ASMR-Y-Feedback | 107/113 | 110/113 | +3 |
| 46 | 46-Arte-2D | 101/110 | 109/110 | +8 |
| 47 | 47-Texturas-Y-Materiales | 118/121 | 121/121 | +3 |
| 50 | 50-Vegetacion | 131/142 | 138/142 | +7 |
| 51 | 51-Agua | 140/166 | 155/166 | **+15** |
| 52 | 52-Particulas-Y-VFX | 145/148 | 146/148 | +1 |
| 53 | 53-UI-UX | 159/165 | 160/164 | +1 |
| 54 | 54-Mapa | 133/177 | 172/177 | **+39** |
| 55 | 55-Diario-Del-Jugador | 67/131 | 122/131 | **+55** |
| 56 | 56-Fotografia | 60/138 | 132/138 | **+72** |
| 57 | 57-Interfaz-De-Control | 94/119 | 118/119 | **+24** |
| 58 | 58-Accesibilidad | 167/184 | 182/184 | +15 |
| 62 | 62-Memoria | 145/150 | 147/150 | +2 |
| 63 | 63-Cargas-Y-Streaming | 67/101 | 93/101 | **+26** |
| 64 | 64-IA-De-NPC | 90/119 | 109/119 | **+19** |
| 66 | 66-Anti-Softlock | 110/117 | 117/117 | +7 |
| 67 | 67-Vehiculos | 38/131 | 103/131 | **+65** |
| 68 | 68-Transporte-Y-Navegacion | 116/131 | 127/131 | +11 |
| 69 | 69-Fast-Travel | 123/145 | 142/145 | **+19** |
| 71 | 71-Progresion | 168/213 | 213/213 | **+45** |
| 73 | 73-Coleccionables | 131/135 | 132/135 | +1 |
| 74 | 74-Eventos | 227/285 | 285/285 | **+58** |
| 76 | 76-Multijugador | 129/130 | 130/130 | +1 |
| 78 | 78-Legal-Propiedad-Intelectual | 156/157 | 157/157 | +1 |
| 80 | 80-Legal-Privacidad | 142/144 | 144/144 | +2 |
| 81 | 81-Legal-Menores | 135/137 | 137/137 | +2 |
| 82 | 82-Clasificacion-Por-Edades | 95/100 | 100/100 | +5 |
| 83 | 83-Licencias-De-Software | 99/100 | 100/100 | +1 |
| 85 | 85-Modelos-3D-Legal | 73/100 | 99/100 | **+26** |
| 87 | 87-Localizacion | 135/140 | 140/140 | +5 |
| 88 | 88-Fuentes-Tipograficas | 174/185 | 178/185 | +4 |
| 89 | 89-Diseno-De-Menus | 124/125 | 125/125 | +1 |
| 91 | 91-Configuracion-De-Audio | 237/239 | 239/239 | +2 |
| 92 | 92-Tutorial | 132/185 | 185/185 | **+53** |
| 93 | 93-Balance | 137/139 | 139/139 | +2 |
| 94 | 94-Retencion-Sin-FOMO | 83/138 | 88/138 | +5 |
| 103 | 103-Logging | 173/179 | 177/179 | +4 |
| 104 | 104-Analytics | 111/119 | 119/119 | **+8** |
| 105 | 105-Telemetria-De-Gameplay | 143/171 | 171/171 | **+28** |
| 106 | 106-Seguridad | 194/206 | 206/206 | **+12** |
| 107 | 107-Backups | 177/182 | 182/182 | +5 |
| 109 | 109-Herramientas-Internas | 135/138 | 136/138 | +1 |
| 112 | 112-Testing-Automatico | 228/232 | 232/232 | +4 |
| 113 | 113-Pruebas-De-Stress | 131/132 | 132/132 | +1 |
| 115 | 115-Hardware | 78/104 | 104/104 | **+26** |
| 117 | 117-Build-System | 94/110 | 109/110 | +15 |
| 122 | 122-Crash-Reporting | 254/264 | 256/264 | +2 |
| 123 | 123-Modding | 106/108 | 108/108 | +2 |
| 128 | 128-Identidad-De-Marca | 60/100 | 100/100 | **+40** |
| 129 | 129-Merchandising | 101/108 | 106/108 | +5 |
| 131 | 131-Creditos | 86/95 | 87/95 | +1 |
| 132 | 132-Produccion-De-Equipo | 104/105 | 105/105 | +1 |
| 137 | 137-Prototipo | 118/131 | 126/131 | +8 |
| 139 | 139-Pre-Alpha | 139/142 | 140/142 | +1 |
| 140 | 140-Alpha | 100/124 | 122/124 | **+22** |
| 141 | 141-Beta | 146/147 | 147/147 | +1 |
| 144 | 144-Despues-Del-Lanzamiento | 104/106 | 106/106 | +2 |
| 145 | 145-Diseno-De-Experiencia | 92/105 | 103/105 | +11 |
| 146 | 146-Diseno-Emocional | 91/100 | 100/100 | +9 |
| 147 | 147-World-Building | 130/134 | 133/134 | +3 |
| 148 | 148-Lore-Ambiental | 115/117 | 116/117 | +1 |
| 149 | 149-Nombres-Y-Nomenclatura | 99/100 | 100/100 | +1 |
| 154 | 154-Vision-Del-Agente | 149/155 | 150/155 | +1 |
| 155 | 155-Vestimenta-Y-Accesorios | 105/108 | 108/108 | +3 |
| 156 | 156-Terrenos-Y-Movimiento | 223/307 | 301/307 | **+78** |
| 160 | 160-Diseno-De-Ubicaciones-Del-Mundo | 145/155 | 155/155 | +10 |
| 162 | 162-Dialogos-Contextuales-De-NPCs | 84/120 | 118/120 | **+34** |
| 163 | 163-Sistema-De-Encantamientos | 105/120 | 113/120 | +8 |
| 164 | 164-Isla-De-Combate-Endgame | 120/129 | 128/129 | +8 |
| 167 | 167-Isla-Raiz | 113/114 | 114/114 | +1 |

### Módulos sin 05-Checklist.md:
- **157 | 157-Medios-De-Transporte** | GLOBAL: 0/106 | DISCO: no existe archivo 05-Checklist.md

### Hallazgo principal:
La columna "Progreso" de CHECKLIST-GLOBAL.md está **desactualizada en 97 de 173 módulos** (56%). El drift va de +1 a +78 ítems [x] por módulo. Los casos más graves: 56-Medios-De-Transporte (no tiene checklist), 56-Fotografia (+72), 156-Terrenos-Y-Movimiento (+78), 67-Vehiculos (+65), 74-Eventos (+58), 55-Diario-Del-Jugador (+55), 92-Tutorial (+53), 27-Islas-Del-Mundo (+50), 128-Identidad-De-Marca (+40), 12-Camara (+43), 37-Museos (+43), 71-Progresion (+45).

**Recomendación:** regenerar CHECKLIST-GLOBAL.md con `scripts/generar_checklist_global.py` para sincronizar Progreso vs conteo real de disco.

Evidencia: script ejecutado sobre `CHECKLIST-GLOBAL.md` (173 filas) y `DOCUMENTACION/{ID}-*/plan-actual/05-Checklist.md` de cada módulo (2026-10-28 08:15).

hecho=1 skip=0 fail=0

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-28 08:15:00.
