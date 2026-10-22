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

