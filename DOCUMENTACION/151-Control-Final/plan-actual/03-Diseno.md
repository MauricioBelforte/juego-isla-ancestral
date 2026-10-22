**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 151: Control Final

## 1. Arquitectura general
El Control Final es un **proceso de auditoría**, no un sistema de runtime. Se organiza como:

```
[Evidencias] ──▶ [Semaforizador (26 puntos)] ──▶ [Acta de Control Final] ──▶ M144
   ├─ Encuestas (≥10, diversión 1-5)                  ├─ ✔ (requiere evidencia)
   ├─ Sesiones observadas (3/frente)                  ├─ ⚠ (plan de acción)
   ├─ Telemetría 72 h (M143/M104/M105)                └─ ✖ (bloqueante)
   ├─ Profiling (M61-M63, dudas)
   └─ Docs admin (contratos, licencias, PI)
```

## 2. Mapa de los 26 puntos → evidencia requerida
| # | Punto | Evidencia principal |
|---|-------|---------------------|
| 1 | Identidad propia | Propuesta de juego (M147) + benchmark vs 3 pares |
| 2 | Bucle principal divertido | Encuestas diversión ≥ 4/5 + 3 sesiones observadas |
| 3 | Construir divertido | Encuesta + sesión de construcción 30 min |
| 4 | Explorar divertido | Encuesta + mapa de descubrimientos (M28/M50) |
| 5 | Puzzles divertidos | Encuesta + tasa de rendición < 15% (M93) |
| 6 | NPC interesante | Encuesta + guión revisado (M21/M23) |
| 7 | Economía funciona | Simulación M93: sin quiebras en 40 h; precio/día sano |
| 8 | Progresión funciona | Matriz de sellos/habilidades verificada (M71) |
| 9 | Mundo vivo | Rutinas/eventos sin huecos en 7 días de simulación (M25/M74) |
| 10 | Estaciones con propósito | Efectos estacionales en cultivos/eventos (M33) |
| 11 | Clima con propósito | Clima altera gameplay (lluvia/helada) (M32) |
| 12 | Música refuerza zonas | Playlist por zona auditable (M41) + test auditivo |
| 13 | Audio refuerza acciones | Matriz de SFX por interacción (M42/M44) |
| 14 | Gráficos coherentes | Guía de estilo (M06/M49) + screenshots por zona |
| 15 | Voxels eficientes | Presupuesto técnico (M08/M11/M61): draw calls, memoria |
| 16 | Guardado confiable | 30 ciclos + 0 reportes de save (M59/M60/M66) |
| 17 | Rendimiento aceptable | Telemetría 72 h: fps p99, crash < 0.5% (M61-M63) |
| 18 | Accesibilidad contemplada | Checklist M58 100% verificado |
| 19 | Localización contemplada | Checklist M87 100% verificado |
| 20 | Contratos documentados | Índice de contratos (ubicación + estado) |
| 21 | Licencias documentadas | Índice de licencias de assets/herramientas |
| 22 | PI documentada | Registros de marca/nombre/logo archivados |
| 23 | Página de tienda preparada | Store publicada y verificada (M149) |
| 24 | Soporte preparado | Canales activos + SLA operativo (M152) |
| 25 | Actualización preparada | Pipeline hotfix/patcheo probado (M142/M143) |
| 26 | Plan post-lanzamiento | Hoja de ruta M144 aprobada |

## 3. Flujo de evaluación
```
Por cada punto:
1. Evidencia recolectada (S2) → vinculada en el acta
2. Criterio objetivo (definido en S1) → ✔ / ⚠ / ✖
3. ⚠/✖ → plan de acción con dueño y fecha (S3)
4. Acta firmada (producción + QA) e indexada (S4/S5)
```

## 4. Plantilla del acta (semaforizador)
```json
{
  "acta": "CONTROL-FINAL-1.0",
  "fecha": "YYYY-MM-DD",
  "juego": "Isla Ancestral",
  "puntos": [
    {"id": 1, "nombre": "Identidad propia", "estado": "✔",
     "evidencia": "docs/identidad-benchmark.md",
     "planAccion": null},
    {"id": 7, "nombre": "Economía funciona", "estado": "⚠",
     "evidencia": "simulacion-m93.pdf",
     "planAccion": {"dueño": "QA", "fecha": "2026-09-15", "desc": "Ajuste de precio de temporada"}}
  ],
  "firmas": ["produccion", "qa"]
}
```

## 5. Reuniones del proceso
| Sesión | Asistentes | Salida |
|--------|------------|--------|
| Kickoff (S1) | Producción + QA + diseño | Criterios de los 26 puntos |
| Relevamiento (S2) | QA + soporte | Evidencias recolectadas |
| Evaluación (S3) | Producción + diseño + QA | Semáforo preliminar |
| Cierre (S4) | Producción + QA + legal | Acta firmada + ⚠ con dueños |

## 6. Qué NO se hace en Control Final
- No se implementa ni corrige nada en el juego (solo documenta y planifica).
- No se reabren decisiones cerradas (canon M147) salvo riesgo de calidad P0.
- No se agregan ítems nuevos al checklist del plan maestro (es auditoría).

## Criterios de verificación — BATERIA 1 (S51 — G-5.3-Flash-Agente, 2026-10-23)

Formato comun de cada criterio: QUE se mide / COMO se mide / UMBRAL de
aprobacion. Los UMBRALES precisan datos del playtesting real (se refina en
la fase); aqui quedan operacionalizados para que cualquier agente pueda
ejecutarlos.

**L35 metrica de sesion larga (retencion >= 60%):** QUE: jugadores que
llegan a la HORA de juego sin abandonar. COMO: marcador de tiempo en
telemetria opt-in (M105 esbozo) o conteo manual del observador (minuto de
abandono). UMBRAL: retencion >= 60% a los 60 min sobre el panel de 5+
testers (M59/M138 protocolo).

**L36 anti-fatiga 40 h (M93):** QUE: que 40 h acumuladas de juego NO
produzcan quiebre de la experiencia (burnout de mecánica/bucle). COMO:
sesiones largas registradas por el tester veterano con diario simple
(sensacion 1-10 por bloque de 8 h + notas de repeticion). UMBRAL: sin
bloqueo de sensacion < 5 sostenido y bucle percibido como variado (M93).

**L37 registro de bucle principal:** QUE: definicion escrita del bucle
repetible base (cual es el loop de 15-30 min del juego completo). COMO:
1 pagina en el 03: ciclo -> recompensa -> meta -> nuevo ciclo, con el
ritmo nominal (dias del calendario M29). UMBRAL: el acta deja la lista
cerrada de pasos y NO cambia sin revision de alcance (L154 del M138).

**L45 no-friccion de construccion (M17):** QUE: piezas se colocan sin bugs.
COMO: script de humo: colocar 20 piezas consecutivas (rotando tipo/rotacion)
en 3 superficies distintas + undo/rehacer; conteo de fallos. UMBRAL: 0
fallos de colocacion (pieza que no aparece, fantasma sin colision, agua
dentro de la pared) en 60 eventos.

**L52 recompensas de exploracion (coleccionables):** QUE: coleccionables
visibles y recogibles sin frustracion. COMO: conteo por zona + tiempo por
hallazgo con el participante tester; la senal de pickup (M52/M43) suena en
el 100% de los casos. UMBRAL: 0 coleccionables irrepetibles y 0 sin
feedback visual/sonoro al recogerlos.

**L61 accesibilidad de puzzles (M24/M26):** QUE: puzzles jugables sin
depender del color exclusivamente. COMO: checklist por puzzle - las señales
color/posicion/forma redundan (el puzzle se puede resolver en escala de
grises) + dificultad ajustable M58 (perfil). UMBRAL: 100% de puzzles con
al menos dos codigos sensoriales.

**L93 NPC no-robot (M21):** QUE: dialogos que no repitan EXACTAMENTE la
misma linea en la misma sesion. COMO: qa headless del manager M21: 10
conversaciones seguidas con el mismo NPC cuentan lineas repetidas
consecutivas; variantes por personalidad M11/M47. UMBRAL: 0 repeticion
consecutiva exacta; <= 2 repeticiones alternadas toleradas con variante.

**L76 tiendas/AO precios rotos (M93):** QUE: los precios de tienda en AO
son coherentes con la economia M93. COMO: validate_balance (M93) sobre
prices.json/shops.json + compra-venta de humo en partidos de prueba
(ganancia total >= 0, ninguna transaccion negativa). UMBRAL: 0 precios
fuera de rango 5-15% del desbloqueo y 0 transacciones con AO negativo.



## Criterios de verificación — BATERIA 2 (Reflection-Beam-1.0, 2026-10-22)

Formato comun: QUE se mide / COMO se mide / UMBRAL de aprobacion. Operacionalizados
para que cualquier agente pueda ejecutarlos; umbrales se refinan con playtesting real.

**L43 legibilidad del grid y catalogo (M17/M65):** QUE: grid de construccion legible
y catalogo de piezas sin ambiguedad. COMO: screenshot + sesion observada 30 min con 3
testers; contar confusiones (pieza equivocada, rotacion mal leida). UMBRAL: 0
confusiones bloqueantes y >=4/5 en encuesta de legibilidad.

**L44 recompensa visual por construccion:** QUE: feedback visual claro al colocar,
editar y borrar pieza. COMO: sesion observada + captura de los 3 estados con señal
(particula/sonido). UMBRAL: 100% de las 3 acciones con feedback visible en <=200 ms.

**L51 curiosidades por zona (hit de vista):** QUE: zonas con puntos de interes
descubribles. COMO: mapa de descubrimientos por isla (M28/M50) + walk-through con
tester; contar hit de vista. UMBRAL: >=3 curiosidades por zona y 0 zonas vacias.

**L53 desplazamiento comodo (viajes/camara):** QUE: viajes entre islas y camara no
marean ni frustran. COMO: sesion observada 30 min + registro de mareo/fatiga.
UMBRAL: 0 reportes de mareo y tiempo de viaje <= presupuesto.

**L59 pistas en todos los templos (M24/M26):** QUE: cada templo/puzzle tiene pistas
accesibles. COMO: checklist por templo (M24/M26) verificando pista visible + pista
en diario. UMBRAL: 100% de templos con >=1 pista y 0 puzzles sin pista.

**L60 dificultad progresiva sin picos:** QUE: curva de dificultad de puzzles sin
saltos bruscos. COMO: ordenar puzzles por dificultad (M93) + revision de saltos
entre niveles. UMBRAL: delta dificultad <= 1 nivel entre puzzles consecutivos.

**L68 cadenas de amistad memorables (M20):** QUE: cadenas de amistad de NPC dejan
huella. COMO: revision del guion por acto (M21/M23) + encuesta NPC >=4/5 en hitos.
UMBRAL: >=1 hito memorable por NPC principal y 0 cadenas sin cierre.

**L69 voz/guino audiovisual en hitos:** QUE: hitos de amistad tienen señal
audiovisual. COMO: checklist por hito (M44) verificando SFX + animacion. UMBRAL:
100% de hitos con >=1 señal audiovisual.

**L75 sin exploits conocidos abiertos:** QUE: no hay exploits de economia/gameplay
abiertos al lanzamiento. COMO: revision de M93 (simulacion 40 h) + lista de
exploits conocidos cerrados. UMBRAL: 0 exploits de severidad >= media abiertos.

**L77 recompensas proporcionales al esfuerzo:** QUE: recompensas escalan con el
esfuerzo del jugador. COMO: revision de curva precio/dia (M93) + comparativa
esfuerzo/recompensa por actividad. UMBRAL: correlacion positiva y 0 outliers
(recompensa >> esfuerzo).

**L84 artefactos 6+1 sin dominancia excesiva (M13):** QUE: los 6+1 artefactos no
tienen uno dominante. COMO: revision de M13 (matriz de poder) + simulacion de
combate con cada artefacto. UMBRAL: ningun artefacto >2x el segundo en DPS/utilidad.

**L85 retroalimentacion de progreso en UI (M53):** QUE: la UI muestra progreso de
forma clara. COMO: revision de M53 (barras/iconos) + sesion observada. UMBRAL:
100% de sistemas con progreso visible y 0 sin feedback.

**L91 reacciones del mundo (clima/ciclo):** QUE: el mundo reacciona al clima/ciclo
(fauna, flora, NPC). COMO: checklist por zona (M32/M36) + sesion observada. UMBRAL:
>=1 reaccion visible por zona.

**L92 vida silvestre (fauna M36):** QUE: fauna presente y coherente por bioma.
COMO: revision de M36 (bestiario) + walk-through por bioma. UMBRAL: >=1 especie
por bioma y 0 biomas vacios.

## Criterios de verificacion — BATERIA 2 (S52 — G-5.3-Flash-Agente, 2026-10-23)

**L43 legibilidad del grid y catalogo (M17/M65):** QUE: el grid de
construccion y su catalogo se leen sin ambiguedad. COMO: captura a 1080p
con vista estandar + rejilla; observador contrala consumo de iconos y
etiquetas a 1 m de pantalla (prueba de sala). UMBRAL: 0 etiquetas ilegibles
y 0 iconos ambiguos en la tanda.

**L44 recompensa visual por construccion (M17):** QUE: terminar una
construccion da feedback visual claro. COMO: humo de colocacion final +
efecto de completado (M52); tester reporta si "se nota el terminado".
UMBRAL: 100% de builds con feedback visual y >= 80% de testers que lo
perciben como recompensa.

**L51 curiosidades por zona (hit de vista):** QUE: cada zona tiene al menos
1 punto de vista/curiosidad que invite a explorar. COMO: caminata del
tester seguida por observador; tabula hitos de vista espontaneos.
UMBRAL: >= 1 hito por zona (5 zonas minimo) en la caminata de 30 min.

**L53 desplazamiento comodo (viajes/camara):** QUE: moverse por la isla no
marea ni frustra. COMO: recorridos de 10 min (viaje rapido vs caminar);
escala de mareo 1-5 por tester (auto-reporte). UMBRAL: mareo <= 2/5 en
>= 80% de testers y 0 perdidas de camara/queda en paredes.

**L59 pistas en todos los templos (M24/M26):** QUE: cada templo tiene pista
de solucion accesible. COMO: checklist por templo => pista visual/auditiva
presente ANTES del bloqueo (el jugador nunca queda sin camino); prueba con
tester que NO leyo la solucion. UMBRAL: 100% de templos con pista previa al
bloqueo y 0 softlocks (M66).

**L60 dificultad progresiva sin picos:** QUE: la curva de dificultad no da
saltos bruscos. COMO: tabla de contenido vs horas (cada sistema aporta su
NFR) + telemetria de muertes/fallos por hora. UMBRAL: 0 saltos donde el
tasa de fallo doble sin aviso del sistema; picos marcados con archivo.

**L68 cadenas de amistad memorables (M20):** QUE: las recompensas de
amistad se recuerdan despues. COMO: encuesta post-sesion (que escena de
amistad recordas?); cuenta de cadenas completadas por tester. UMBRAL: >= 80%
de testers recuerdan >= 1 momento de amistad espontaneamente.

**L69 voz/guino audiovisual en hitos (M44):** QUE: los hitos tienen pieza
audiovisual propia (stinger, gesto, sello). COMO: checklist de hito ->
asset audiovisual ligado; audit en vivo. UMBRAL: 100% de hitos del catalogo
con stinger/telefono/gesto registrados.

**L75 sin exploits conocidos:** QUE: los exploits documentados estan
cerrados. COMO: lista de exploits conocidos del 05/Bugs -> reproducir uno a
uno en build final. UMBRAL: 0 exploits reproducibles en la build final
(los no-reproducibles quedan documentados con causa).

**L77 recompensas proporcionales al esfuerzo:** QUE: el esfuerzo-recompensa
es proporcional. COMO: tabla esfuerzo (tiempo/pasos) vs recompensa AO/valor
(M93) por feature; muestra de 20 features. UMBRAL: 0 features con
recompensa > 2x o < 0.5x de su promedio esperado (desviacion > 2x = feature
a rebalancear).

## Criterios de verificacion — BATERIA 3 (S53 — G-5.3-Flash-Agente, 2026-10-23)

**L99 decorado estacional por isla (M50):** QUE: cada isla refleja la
estacion (foliage/props). COMO: captura por isla y estacion vs tabla de
estaciones del M50; checklist visual con 3 puntos de referencia por isla.
UMBRAL: 100% de islas con cambio estacional visible (0 islas iguales entre
verano e invierno).

**L100 impacto economico estacional (precios):** QUE: los precios reaccionan
a la estacion/evento (M74). COMO: snapshot de 10 precios en 2 estaciones
distintas + validar en M93 (banda 5-15%); el delta estacional documentado.
UMBRAL: >= 3 precios con ajuste estacional justificado y 0 fuera de banda.

**L101 audio estacional (M43):** QUE: el ambiente sonoro cambia con la
estacion. COMO: par de capturas de audio de la misma zona en 2 estaciones
(espectro o A/B de oido por 2 oyentes). UMBRAL: >= 1 capa audible distinta
por estacion (pajaros/crickets/viento) en todas las zonas con estaciones.

**L107 clima cambiante por isla (M50):** QUE: el clima cambia por isla y
avanza en ciclos (M32). COMO: observacion de 30 min por isla con registro de
transiciones (soleado nublado lluvia); determinismo por semilla M29
documentado. UMBRAL: >= 2 estados de clima por isla y transiciones sin
pop de particulas.

**L108 visual de clima coherente por zona:** QUE: el clima se ve igual de
coherente en cada zona (el sol de la playa no llueve con sol en el prado).
COMO: captura simultanea de 2 zonas en el mismo tick del calendario.
UMBRAL: 0 incoherencias de clima visible entre zonas contiguas.

**L109 aviso climatico en diario (M55):** QUE: el diario anticipa el clima
(M55) con la hora/estacion correcta. COMO: comparar la prediccion del
diario contra el clima real del dia siguiente (semilla M29). UMBRAL: 100% de predicciones correctas (el determinismo lo garantiza).

**L114 musica por acto (M41):** QUE: la musica acompana el acto/avance de la
historia. COMO: auriculares A/B en momentos de acto + verificacion del
reproductor (cue por acto). UMBRAL: cada acto tiene su tema y la transicion
de acto cambia la musica sin reinicio brusco.

**L116 transiciones sin cortes de audio:** QUE: la musica no corta seco en
transiciones (viaje/menus/clima). COMO: recorridos que fuerzan las 6
transiciones; decibelmetros o oido con atencion al corte. UMBRAL: 0 cortes
secos >= 100 ms (siempre crossfade >= 100 ms o nota de diseno).

**L117 ducking con dialogos (M41):** QUE: la musica baja su volumen cuando
habla un NPC (ducking) y vuelve al cerrar. COMO: conversacion con musica
activa; medidor de ganancia del bus musica. UMBRAL: duck >= -6 dB durante
dialogo y retorno <= 1 s tras cerrarlo.

**L122 SFX de hitos (brindis, sellos):** QUE: los hitos tienen su SFX de
celebracion. COMO: tabla hito->SFX (del M43) reproducida una por una.
UMBRAL: 100% de hitos con SFX asignado y 0 volumen > -3 dB de pico.

**L124 volumen balanceado en las 6 zonas:** QUE: SFX/ambiente/USO del jugador
se escuchan equilibrados en todas las zonas. COMO: pase de volumen por zona
(VU en el mezclador M41, zona por zona) con el mismo fixture de acciones.
UMBRAL: 0 zona con SFX > 6 dB sobre el resto o bajo -20 dB.

**L125 voces en hitos (M44):** QUE: los hitos mayores tienen voz/grito
locutado (M44). COMO: tabla hito mayor -> clip de voz; reproduccion en
contexto. UMBRAL: 100% de hitos mayores con voz asignada y 0 clipes que
pisen el dialogo (ducking aplicado).

## Criterios de verificacion — BATERIA 4 (S54 — G-5.3-Flash-Agente, 2026-10-23)

**L140 streaming de chunks sin picos (M63):** QUE: el streaming no genera
hitches al cruzar chunks. COMO: recorridp de 5 min cruzando 10 bordes de
chunk con frame-time monitorizado (qa headless o captura); pico = frame >
100 ms. UMBRAL: 0 frames > 100 ms atribuibles a streaming (los frames pesados
de GPU cuentan aparte en TC13/REPORTE-FPS).

**L141 LOD/culling activo en todas las islas (M50):** QUE: la LOD y culling
estan activos en TODAS las islas (no solo la raiz). COMO: visitar cada isla
y verificar que los objetos lejanos desaparecen/migram a LOD (monitor Godot:
draw calls bajan). UMBRAL: 100% de islas con culling operando (los draw
calls bajan al alejarse >= 30%).

**L155 tiempos de carga en presupuesto (M63):** QUE: la carga de la isla
(viaje rapido/arranque) cabe en presupuesto. COMO: cronometrar 20 cargas
(10 primeras + 10 con save pesado). UMBRAL: p95 <= 8 s (pantalla de carga
siempre presente regla AGENTS 8; 0 cargas congeladas).

**L149 anti-softlock con items clave (M66):** QUE: perder un item clave no
softloquea. COMO: guardar TODO elitu de la mision, tirarlo/regalarlo, y
tratar de terminar la mision; el sistema debe ofrecer re-obtencion (tienda,
respawn, NPC repite tarea). UMBRAL: 100% de items de mision con via de
re-obtencion y 0 estados sin salida.

**L162 remapeo/subtitulos/modos de color (M57/M58):** QUE: los ajustes de
accesibilidad funcionan end-to-end. COMO: cambiar cada ajuste en el menu y
verificar el efecto EN JUEGO (tecla remapeada hace la accion; subtitulos
aparecen; filtro daltonismo cambia la paleta). UMBRAL: 100% de ajustes con
efecto visible inmediato (sin reinicio).

**L163 reduce motion / flashing (M58):** QUE: el perfil reduce-motion
elimina flashes y Shake. COMO: activar perfil y reproducir los 5 momentos
con flash/shake canonico (impacto, fast travel, rayo, logro, muerte).
UMBRAL: 0 flashes > 3 Hz y 0 screen-shake con el perfil activo.

**L164 tamano de texto 150% (M58):** QUE: la UI a texto 150% sigue legible
y no se corta. COMO: menuset/etc. capturas con escala 150% aplicada
(ui_access_scale + fuente); revisar 6 pantallas canonicas. UMBRAL: 0 textos
cortados y 0 solapados en las pantallas canonicas.

**L170 6 idiomas sin claves rotas (M21/M55):** QUE: los 6 idiomas no tienen
claves faltantes. COMO: script de escaneo de claves usadas vs traducidas
por locale; log de claves rotas por idioma. UMBRAL: 0 claves rotas y 0
lineas mezclando idiomas en la misma pantalla.

**L171 subtitulos y textos UI por idioma (M55):** QUE: subtitulos y UI
siguen el idioma elegido (no mezclado). COMO: cambiar idioma y recorrer
dialogo+lados UI; captura each subsystema. UMBRAL: 100% de textos en el
idioma elegido en la sesion completa.

**L172 fechas/formatos por idioma (M29/M55):** QUE: las fechas y formatos
_numericos_ del juego siguen el locale. COMO: jugar 2 dias en 2 idiomas y
verificar fecha de diario/reloj/precio formateados. UMBRAL: 100% de
formatos coherentes por locale (0 formatos mezclados).

**L187 licencias de audio/musica (M41-M44):** QUE: TODOS los audios tienen
licencia documentada. COMO: auditar el inventario audio (M41 directorio) vs
registro de licencias (CC0/propio); sin registro = pendiente. UMBRAL: 100%
de archivos con licencia registrada y 0 con claims conocidos.

**L188 licencias de plugins (M60/engine):** QUE: los plugins/gd_extensions
del proyecto tienen licencia verificada. COMO: auditar directorio addons y
componentes externos vs LICENSE. UMBRAL: 100% de plugins con licencia
identificada y compatible con uso comercial.

## Criterios de verificacion — BATERIA 5 (S54b — G-5.3-Flash-Agente, 2026-10-23)

**L132 contraste de UI coherente (M58):** QUE: el texto de la UI cumple
contraste minimo en todas las escenas. COMO: captura de las 6 pantallas
canonicas + verificaciones de contraste (texto vs fondo) 4.5:1 minimo
(wcag AA basico). UMBRAL: 100% de pantallas con contraste >= 4.5:1 en el
texto principal.

**L148 migracion de versiones sin perdida:** QUE: pasar de version n-1 a n
del save MIGRA sin perder datos. COMO: qa headless: save v1 sintetico ->
migracion -> comparar campos core (inventario/reloj/posicion) uno a uno.
UMBRAL: 0 campos perdidos y 0 crashes en 3 pares de versiones (v1->v2,
v2->v3 mock, rollback).

**L157 performance en hardware minimo/recomendado:** QUE: el juego corre en
2 perfiles (minimo: integrada 4 GB; recomendado: dedicada). COMO:
REPORTE-FPS.md con las 2 configuraciones (TC13 extendido); benchmark por
escena canonica. UMBRAL: >= 30 fps promedio en minimo y >= 60 fps en
recomendado, sin streaming-pico > 100 ms.

**L180 vigencia de contratos clave [legal/negocio]:** QUE: los contratos de
distribucion/licencias estan vigentes al lanzamiento. COMO: checklist con
fecha de vencimiento del contrato y 90 dias de aviso previo. DEPENDE: lista
de contratos reales del editor (decision del fundador) — el criterio
tecnico queda listo.

**L181 copia de respaldo de contratos [S]:** QUE: los contratos firmados
tienen copia de respaldo fuera del repo. COMO: bucket/config local cifrar
(el fundador decide el lugar); checklist entra como item del cierre.
UMBALNCE: 100% de contratos con copia verificada (checksum).

**L195 nombre disponible en plataformas [S] — FLAG FUNDADOR:** la
verificacion tecnica (API de stores) se puede hacer, pero la DECISION de
nombre final del juego es del fundador. Flag sin flip.

**L196 politica de uso de la marca [S] — FLAG FUNDADOR:** redactar la
politica de marca para comunidad (fan-art/videos monetizados/mods) es
decision editorial del fundador. Flag con esbozo para su revision.

**L202 capturas finales cargadas [S]:** QUE: las capturas de la pagina de
tienda estan cargadas y actualizadas con el build final. COMO: checklist
de mkt: 6 capturas (mundo/player/construccion/foto/misiones/credits) del
build final vs version previa. UMBRAL: 6/6 con build final y 0 capturas
antiguas con arte descontinuado.

**L203 requisitos correctos [S]:** QUE: la pagina lista requisitos MIN/REC
que matchean el REPORTE-FPS (L157). COMO: diff requisitos publicados vs
medicion L157. UMBRAL: 0 discrepancias entre lo publicado y lo medido.

**L204 enlaces de soporte en la pagina [S]:** QUE: los enlaces de soporte
(discord/email/FAQ/canales) funcionan. COMO: curl/click en cada link al
lanzar. UMBRAL: 100% de enlaces responden 200 y apuntan al contenido
correcto.

**L211 FAQ con bugs reales (M143):** QUE: la FAQ documenta los bugs/
limitaciones conocidos del lanzamiento. COMO: FAQ aggiornada con la lista
final del 11-BUGS.md (los conocidos-no-bloqueantes). UMBRAL: 100% de bugs
conocidos users-facing listados con workaround.

**L212 triaje de soporte en produccion [S]:** QUE: hay proceso definido
para los tickets del launch window. COMO: 1 pagina de flujo (canal ->
replico -> clasifico [bug/pregunta/crash] -> escalado a 11-BUGS/M143).
UMBRAL: flujo documentado y probado con 3 tickets mock.

**L217 actualizacion in-place sin perdida de saves [M]:** QUE: actualizar
el juego NO borra los saves. COMO: instalar version N-1, jugar (crear
saves), actualizar a N, verificar los saves sobreviven (conteo + campos
core). UMBRAL: 100% de saves intactos y 0 resets de perfil M58.

**L218 notas de parche listas (plantilla) [S]:** QUE: existe plantilla de
notas de parche rellenable. COMO: plantilla .md en docs/vslice/ con
secciones corregido/cambio-conocido/saltando-version. UMBRAL: plantilla
versionada y 1 ejemplo relleno con datos reales del slice.

**L219 rollback disponible si falla un parche [M]:** QUE: hay rollback
tecnico si el parche rompe. COMO: guardar el build anterior + script de
re-instalacion; probar rollback en maquina de prueba. UMBRAL: rollback
funcional documentado (1 prueba) + decide el fundador si hay rollback
automatico (infra).

**L224 cola de hotfix 2.0.x documentada (M143) [S]:** QUE: el canal de
hotfix tiene criterio de entrada/salida. COMO: el flujo de M143 define que
califica (crash/softlock/economico) y que no (cosmetico) — documentado en
el 03 del hotfix pipeline. UMBRAL: criterio documentado + 1 ejemplo real
por clasificacion.

**L236 log de cierre del modulo en Logs/[S]:** QUE: el hito tiene su log de
cierre en Logs/ (mismo protocolo sec 6). UMBRAL: log creado con numeracion
del pool y firmas multiples (ya definido en M138 S38 L211/212 — mismo
protocolo).

## Decisiones pendientes del FUNDADOR (flag sin flip — L195/L196/L225/L226/L227)

- L195 nombre final del juego en stores (verificacion tecnica lista).
- L196 politica de uso de marca para comunidad (esbozo pendiente de
  revision editorial).
- L225 lista de mejoras de comunidad priorizada — 5-FUTURAS-MEJORAS es el
  anotador del USUARIO: solo directivas del usuario, no propuestas de
  agentes.
- L226 dueño por funcion del post-lanzamiento ( staffing).
- L227 fecha de revision del plan (M144) — la agenda la fija el fundador.

