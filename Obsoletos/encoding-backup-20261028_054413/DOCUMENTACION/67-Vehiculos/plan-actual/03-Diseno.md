**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 67: VehÃ­culos

## 1. Arquitectura

```
Assets/_Project/Vehicles/
â”œâ”€â”€ data/
â”‚   â”œâ”€â”€ vehicle_preset.gd           (modelo: tipo, fÃ­sica, capacidades, mejoras)
â”‚   â””â”€â”€ vehicles_catalog.tres       (catÃ¡logo: barco, dirigible, submarino, locomotora-plantilla)
â”œâ”€â”€ service/
â”‚   â”œâ”€â”€ vehicle_manager.gd          (autoload: estado, vehÃ­culo activo, entrada/salida, dock)
â”‚   â”œâ”€â”€ vehicle_controller.gd       (fÃ­sica acotada: velocidad/giro/frenado/altitud)
â”‚   â”œâ”€â”€ vehicle_streaming.gd        (chunk_target del vehÃ­culo, LOD por altitud, M10/M61)
â”‚   â”œâ”€â”€ vehicle_cargo.gd            (baÃºl M14, mejoras, personalizaciÃ³n, persistencia M59)
â”‚   â””â”€â”€ vehicle_dock.gd             (docking con magnetismo suave, M28)
â”œâ”€â”€ ui/
â”‚   â”œâ”€â”€ vehicle_hud.gd              (HUD del vehÃ­culo en M53: velocidad, direcciÃ³n, baÃºl)
â”‚   â””â”€â”€ vehicle_customize.gd        (pantalla de pintura/banderas/nombre)
â””â”€â”€ validators/
    â””â”€â”€ validate_vehicles.gd        (validaciÃ³n: fÃ­sica, streaming, colisiones, presupuestos)
```

`VehicleManager` (autoload) orquesta: al entrar (M70), activa `vehicle_controller` (fÃ­sica) + `vehicle_streaming` (chunk_target) + HUD (M53); `vehicle_dock` maneja el atraque (M28); `vehicle_cargo` el baÃºl (M14) y las mejoras (persistencia M59); los sonidos (M43) y animaciones (M48) se activan con el vehÃ­culo y se detienen al salir. Los VFX (M52) se emiten por eventos (estela, vapor).

## 2. Diagramas de Flujo (texto)

### 2.1 Entrada al vehÃ­culo (docking)

```
jugador cerca del vehÃ­culo + interacciÃ³n (M70)
  â†’ VehicleManager.enter(vehicle):
    â†’ 1) validar estado (docked y en superficie para barco)
    â†’ 2) activar controller con preset del vehÃ­culo
    â†’ 3) vehicle_streaming: chunk_target = vehÃ­culo (M10/M61)
    â†’ 4) activar HUD (M53) y cÃ¡mara 3Âª persona (M57)
    â†’ 5) activar sonidos (M43) y animaciones (M48)
    â†’ 6) log VEH-ENTER
```

### 2.2 ConducciÃ³n (barco como ejemplo)

```
input del jugador (WASD/gamepad, M57)
  â†’ vehicle_controller._process(delta):
    â†’ 1) aceleraciÃ³n/giro/frenado segÃºn preset (velocidad mÃ¡x por tipo)
    â†’ 2) el barco lee la superficie del agua (M51) para flotaciÃ³n visual
    â†’ 3) colisiones con islas/rocas (M50) sin atravesar
    â†’ 4) streaming: chunks alrededor del vehÃ­culo priorizados
    â†’ 5) sonidos con LOD (M43); animaciones de timÃ³n/olas (M48)
    â†’ 6) log VEH-MOVE (solo debug)
```

### 2.3 Docking y salida

```
jugador cerca de un muelle (M28)
  â†’ vehicle_dock:
    â†’ 1) magnetismo suave: ajustar posiciÃ³n/rotaciÃ³n al muelle
    â†’ 2) si el Ã¡ngulo es invÃ¡lido â†’ desactivar y permitir reintento
    â†’ 3) al atracar: log VEH-DOCK; al salir (interacciÃ³n M70):
    â†’ 4) detener sonidos/animaciones, restaurar cÃ¡mara del jugador
    â†’ 5) log VEH-EXIT
```

## 3. Tablas de MÃ©tricas (tÃ©cnico)

### 3.1 Presets de vehÃ­culos

| VehÃ­culo | Medio | Velocidad mÃ¡x | Giro | Altitud mÃ¡x | BaÃºl (M14) | Mejoras | Combustible |
|---|---|---|---|---|---|---|---|
| Barco | agua (M51) | 12 m/s (crucero 6) | suave | â€” | 12 slots | velocidad, giro, faroles, baÃºl 20 | NO |
| Dirigible | aire | 15 m/s | medio | 60 m | 8 slots | velocidad, altitud 90, faroles | NO |
| Submarino | subagua | 8 m/s | medio | âˆ’40 m | 10 slots | velocidad, luces (M49), baÃºl 16 | NO |
| Locomotora | riel (M68) | 20 m/s | fijo | â€” | 16 slots | velocidad, vagÃ³n | NO |

### 3.2 Streaming (regla dura M10/M61)

| Caso | Comportamiento |
|---|---|
| VehÃ­culo en movimiento | chunk_target = vehÃ­culo (carga alrededor del vehÃ­culo primero) |
| Dirigible a > 30 m de altura | LOD de chunks: terreno a menor resoluciÃ³n; no romper generaciÃ³n |
| Barco en aguas lejanas | Cargar islas cercanas (M27) antes que el terreno lejano |
| Submarino sumergido | Terreno bajo el agua con LOD; sin cargar el cielo innecesariamente |

### 3.3 Rendimiento (contra M61/M43/M49/M52)

- Presupuesto por vehÃ­culo: â‰¤ 30 draw calls (pooling M62).
- Luces de faroles: del pool de M49 (mÃ¡x 2 por vehÃ­culo).
- VFX: solo por eventos (M52): estela del barco, vapor del dirigible.
- Audio: LOD (M43) â€” atenuar > 40 m, silenciar > 80 m.

## 4. Integraciones Clave

| MÃ³dulo | IntegraciÃ³n |
|---|---|
| M28 | Viajes entre islas, dock de muelles |
| M68 | Transporte y navegaciÃ³n asistida (locomotora si aplica) |
| M51 | Superficie del agua para flotaciÃ³n; buceo del submarino |
| M10/M61 | chunk_target y LOD de chunks por altitud |
| M57 | Controles de teclado/gamepad y cÃ¡mara |
| M70 | InteracciÃ³n de entrada/salida |
| M14 | BaÃºl integrado (almacenamiento) |
| M59 | Persistencia de mejoras y personalizaciÃ³n |
| M46/M87 | Pintura, banderas, nombre, localizaciÃ³n |
| M43 | Sonidos con LOD |
| M48 | Animaciones de timÃ³n/olas/hÃ©lices/pasajeros |
| M49 | Faroles en pool y visibilidad nocturna del submarino |
| M52 | VFX por eventos (estela, vapor) |
| M50 | Colisiones con vegetaciÃ³n |
| M45 | Materiales de pintura |
| M108/M118 | ImportaciÃ³n y validaciÃ³n en CI |

## Protocolo de gating hidraulico y colisiones (S61 â€” G-5.3-Flash-Agente, 2026-10-23; apilado CRON F, definiciones en papel)

**Aguas poco profundas (L45) â€” umbral de aviso y escape:**
- El vehiculo acuatico sondea profundidad bajo la quilla (raycast a la
  malla M50, cada 6 frames â€” mismo ciclo del throttle RF4 de M70).
- UMBRAL de AVISO: profundidad < 2.0 m (60% del draft): toast M53
  "Aguas poco profundas" + SFX de roce M43 cada 3 s (anti-spam).
- MECANICA de ESCAPE: a < 1.2 m el motor baja el empuje al 40% (evita
  encallar con velocidad); al encallar (profundidad < 0.8 m y velocidad
  ~0 el vehiculo queda en reposo): reversa automatica a 25% durante 2 s
  y luego control devuelto al jugador. 0 softlocks por encallamiento
  (el nudge de M70 P6 aplica tambien).

**Colisiones con islas/rocas/vegetacion (L44/L90) â€” tipos de respuesta:**
- CAPAS fisicas: isla/roca = collision_layer terreno ( sÃ³lido);
  vegetacion alta = area segura (no colisiona con el casco, auto-normal
  del L53); vegetacion baja = colision suave.
- RESPUESTA por tipo/velocidad: (a) roca/isla: rebote elastico 0.4 +
  dano estructural proporcional (v > 8 m/s => dano x 2, v > 12 => dano x 3
  y detencion total); (b) vegetacion baja: rozamiento (reduce 20%
  velocidad, sin rebote, sfx de rama M43); (c) otro vehiculo: rebote
  simetrico 0.5 semillas por velocidad relativa.
- MARGEN por velocidad: el casco tiene CollisionShape inflado 0.3 m
  (margen); a > 10 m/s el margen sube a 0.5 m (el contacto detecta antes
  para que la respuesta no atraviese en el mismo tick â€” tunneling
  prevention con continuous collision en el casco del vehiculo).
- UMBRAL: 0 atravesamientos de isla/roca en 100 colisiones de test
  (script deagnostico con semilla M29 por caso); 0 tunneling a > 10 m/s.

## Protocolo de gating hidraulico y colisiones (S61 â€” G-5.3-Flash-Agente, 2026-10-23; apilado CRON F, definiciones en papel)

**Aguas poco profundas (L45) â€” umbral de aviso y escape:**
- El vehiculo acuatico sondea profundidad bajo la quilla (raycast a la
  malla M50, cada 6 frames â€” mismo ciclo del throttle RF4 de M70).
- UMBRAL de AVISO: profundidad < 2.0 m (60% del draft): toast M53
  "Aguas poco profundas" + SFX de roce M43 cada 3 s (anti-spam).
- MECANICA de ESCAPE: a < 1.2 m el motor baja el empuje al 40% (evita
  encallar con velocidad); al encallar (profundidad < 0.8 m y velocidad
  ~0 el vehiculo queda en reposo): reversa automatica a 25% durante 2 s
  y luego control devuelto al jugador. 0 softlocks por encallamiento
  (el nudge de M70 P6 aplica tambien).

**Colisiones con islas/rocas/vegetacion (L44/L90) â€” tipos de respuesta:**
- CAPAS fisicas: isla/roca = collision_layer terreno ( solido- sÃ³lido);
  vegetacion alta = area segura (no colisiona con el casco, auto-normal
  del L53); vegetacion baja = colision suave.
- RESPUESTA por tipo/velocidad: (a) roca/isla: rebote elastico 0.4 +
  dano estructural proporcional (v > 8 m/s => dano x 2, v > 12 => dano x 3
  y detencion total); (b) vegetacion baja: rozamiento (reduce 20%
  velocidad, sin rebote, sfx de rama M43); (c) otro vehiculo: rebote
  simetrico 0.5 semillas por velocidad relativa.
- MARGEN por velocidad: el casco tiene CollisionShape inflado 0.3 m
  (margen); a > 10 m/s el margen sube a 0.5 m (el contacto detecta antes
  para que la respuesta no atraviese en el mismo tick â€” tunneling
  prevention con continuous collision en el casco del vehiculo).
- UMBRAL: 0 atravesamientos de isla/roca en 100 colisiones de test
  (script deagnostico con semilla M29 por caso); 0 tunneling a > 10 m/s.


## Specs Vehículos (Beam 517)

### Buceo/emersión con límite −40 m y flotabilidad mínima
- Spec: buceo/emersión con límite −40 m y flotabilidad mínima. Coherente con M67 (vehículos) y M51 (agua).

### Explorar cuevas subacuáticas (M25)
- Spec: explorar cuevas subacuáticas (M25). Coherente con M67 (vehículos) y M25 (templo subterráneo).

### LOD de chunks por altitud del dirigible
- Spec: LOD de chunks por altitud del dirigible. Coherente con M67 (vehículos) y M61 (rendimiento).

### Testear barco/dirigible/submarino sin popping de terreno
- Spec: testear barco/dirigible/submarino sin popping de terreno. Coherente con M67 (vehículos) y M08 (terreno).

### Atraque con magnetismo suave en muelles
- Spec: atraque con magnetismo suave en muelles. Coherente con M67 (vehículos) y M28 (viajes).

### Testear docking en muelles angostos y con olas (M51)
- Spec: testear docking en muelles angostos y con olas (M51). Coherente con M67 (vehículos) y M51 (agua).

### Probar con profiler (M116) y baja calidad (M90)
- Spec: probar con profiler (M116) y baja calidad (M90). Coherente con M67 (vehículos) y M116 (profiling).

### Carga de guardado con vehículo en el agua o a 60 m (M59)
- Spec: carga de guardado con vehículo en el agua o a 60 m (M59). Coherente con M67 (vehículos) y M59 (guardado).
## Specs Vehículos (Beam 562)

### Navegar por agua leyendo la superficie (M51, sin fluidos)
- Spec: navegar por agua leyendo la superficie (M51, sin fluidos). Coherente with M67 (vehículos) and M51 (agua).

### Vela desplegable (M48) y estela por evento (M52)
- Spec: vela desplegable (M48) y estela por evento (M52). Coherente with M67 (vehículos) and M48 (animación).

### Vuelo con altitud/descenso y aterrizaje suave en plataformas
- Spec: vuelo con altitud/descenso y aterrizaje suave en plataformas. Coherente with M67 (vehículos) and M10 (personaje).

### No romper el streaming a gran altura (chunk_target + LOD, M10/M61)
- Spec: no romper el streaming a gran altura (chunk_target + LOD, M10/M61). Coherente with M67 (vehículos) and M61 (rendimiento).

### No colisionar con vegetación alta (paso por encima)
- Spec: no colisionar con vegetación alta (paso por encima). Coherente with M67 (vehículos) and M50 (vegetación).
## Specs Vehículos (Beam 563)

### Viento lateral (M32) y farol nocturno (M49)
- Spec: viento lateral (M32) y farol nocturno (M49). Coherente with M67 (vehículos) and M32 (clima).

### Visibilidad y luces bajo el agua (M49)
- Spec: visibilidad y luces bajo el agua (M49). Coherente with M67 (vehículos) and M49 (iluminación).

### Cámara estable bajo el agua (sin mareo)
- Spec: cámara estable bajo el agua (sin mareo). Coherente with M67 (vehículos) and M10 (personaje).

### Vagón de carga (16 slots, M14)
- Spec: vagón de carga (16 slots, M14). Coherente with M67 (vehículos) and M14 (recursos).

### Controles con WASD y gamepad (palanca/gatillos)
- Spec: controles con WASD y gamepad (palanca/gatillos). Coherente with M67 (vehículos) and M56 (interfaz).
## Specs Vehículos (Beam 564)

### Volver chunk_target = jugador al salir
- Spec: volver chunk_target = jugador al salir. Coherente with M67 (vehículos) and M61 (rendimiento).

### Cargar islas cercanas (M27) antes que el terreno lejano
- Spec: cargar islas cercanas (M27) antes que el terreno lejano. Coherente with M67 (vehículos) and M27 (islas).

### Colisiones suaves con islas, rocas y vegetación (M50)
- Spec: colisiones suaves con islas, rocas y vegetación (M50). Coherente with M67 (vehículos) and M50 (vegetación).

### Barco no puede ir a tierra; submarino no emerge en tierra
- Spec: barco no puede ir a tierra; submarino no emerge en tierra. Coherente with M67 (vehículos) and M51 (agua).

### Vehículos no atraviesan puentes (M11) ni ruinas (M25)
- Spec: vehículos no atraviesan puentes (M11) ni ruinas (M25). Coherente with M67 (vehículos) and M25 (templo).
## Specs Vehículos (Beam 565)

### No atropellar animales (M36)
- Spec: no atropellar animales (M36). Coherente with M67 (vehículos) and M36 (fauna).

### Interacción para entrar/salir del vehículo
- Spec: interacción para entrar/salir del vehículo. Coherente with M67 (vehículos) and M56 (interfaz).

### Entrada solo si está docked o en superficie
- Spec: entrada solo si está docked o en superficie. Coherente with M67 (vehículos) and M28 (viajes).
## Specs Vehículos (Beam 566)

### No quedar atascado cerca de muros al entrar/salir
- Spec: no quedar atascado cerca de muros al entrar/salir. Coherente with M67 (vehículos) and M10 (personaje).

### Testear entrada/salida con gamepad y durante eventos (M74)
- Spec: testear entrada/salida con gamepad y durante eventos (M74). Coherente with M67 (vehículos) and M74 (eventos).

### Ajustar posición y rotación; ángulo inválido → reintento
- Spec: ajustar posición y rotación; ángulo inválido → reintento. Coherente with M67 (vehículos) and M28 (viajes).

### Docking de barco y dirigible en plataformas
- Spec: docking de barco y dirigible en plataformas. Coherente with M67 (vehículos) and M28 (viajes).

### Baúl integrado con slots por tipo (barco 12, dirigible 8, submarino 10)
- Spec: baúl integrado con slots por tipo (barco 12, dirigible 8, submarino 10). Coherente with M67 (vehículos) and M14 (recursos).
## Specs Vehículos (Beam 567)

### Abrir el baúl desde el HUD y mover ítems
- Spec: abrir el baúl desde el HUD y mover ítems. Coherente with M67 (vehículos) and M53 (UI).

### Límite de slots respetado y apilables
- Spec: límite de slots respetado y apilables. Coherente with M67 (vehículos) and M14 (recursos).

### Mejora de baúl persistente (M59)
- Spec: mejora de baúl persistente (M59). Coherente with M67 (vehículos) and M59 (guardado).

### Testear baúl con inventario lleno
- Spec: testear baúl con inventario lleno. Coherente with M67 (vehículos) and M14 (recursos).

### Persistencia y visualización de nivel en el HUD
- Spec: persistencia y visualización de nivel en el HUD. Coherente with M67 (vehículos) and M53 (UI).
## Specs Vehículos (Beam 568)

### Mejoras de faroles (M49) y baúl (compuesto, no se flippea)
- Spec: mejoras de faroles (M49) y baúl. Item compuesto: baúl SÍ implementado (baul_slots_efectivo por nivel, techo 20 barco / 16 submarino), faroles/luces = M49, dueño externo, sin integración. NO se flippea el 05 (anti-inflación). Coherente with M67 (vehículos) and M49 (iluminación).

### Pintura del vehículo (paleta cozy, M46)
- Spec: pintura del vehículo (paleta cozy, M46). Coherente with M67 (vehículos) and M46 (texturas).

### Banderas personalizables con viento (M50/M48)
- Spec: banderas personalizables con viento (M50/M48). Coherente with M67 (vehículos) and M50 (vegetación).

### Nombre del vehículo editable y localizable (M87)
- Spec: nombre del vehículo editable y localizable (M87). Coherente with M67 (vehículos) and M87 (fuentes).

### Materiales de pintura del pool (M45/M49)
- Spec: materiales de pintura del pool (M45/M49). Coherente with M67 (vehículos) and M45 (arte 2D).

## Specs Vehiculos (Beam 569)

### Persistencia de personalizacion (M59)
- Spec: persistencia de personalizacion (M59). Coherente with M67 (vehiculos) and M59 (guardado).

## Specs Vehículos (Beam 570)

### Timón al girar, olas/estela y hélices del dirigible
- Spec: timón al girar, olas/estela y hélices del dirigible. Coherente with M67 (vehículos) and M51 (agua).

### Pasajeros a bordo y banderas con viento
- Spec: pasajeros a bordo y banderas con viento. Coherente with M67 (vehículos) and M48 (animación).

### Cámara 3ª persona con zoom de cámara
- Spec: cámara 3ª persona con zoom de cámara. Coherente with M67 (vehículos) and M10 (personaje).

### Seguimiento suave sin mareo (M57)
- Spec: seguimiento suave sin mareo (M57). Coherente with M67 (vehículos) and M57 (accesibilidad).

### Reducir movimiento con Reduce Motion (M58)
- Spec: reducir movimiento con Reduce Motion (M58). Coherente with M67 (vehículos) and M58 (accesibilidad).
## Specs Vehículos (Beam 571)

### Cámara del submarino estable y sin clipping del dirigible
- Spec: cámara del submarino estable y sin clipping del dirigible. Coherente with M67 (vehículos) and M10 (personaje).

### Testear cámara en 16:9 y 4:3 (M08)
- Spec: testear cámara en 16:9 y 4:3 (M08). Coherente with M67 (vehículos) and M08 (terreno).

### Luces de faroles en pool (M49, máx 2 por vehículo)
- Spec: luces de faroles en pool (M49, máx 2 por vehículo). Coherente with M67 (vehículos) and M49 (iluminación).

### Sin GC pesado durante la conducción
- Spec: sin GC pesado durante la conducción. Coherente with M67 (vehículos) and M61 (rendimiento).

### Entrar con inventario abierto (M14) o durante diálogo (M21, bloqueado)
- Spec: entrar con inventario abierto (M14) o durante diálogo (M21, bloqueado). Coherente with M67 (vehículos) and M14 (recursos).
## Specs Vehículos (Beam 572)

### Vehículo atascado en roca (desatascado manual)
- Spec: vehículo atascado en roca (desatascado manual). Coherente with M67 (vehículos) and M10 (personaje).

### Barco en agua congelada (hielo M51) y dirigible con viento fuerte (M32)
- Spec: barco en agua congelada (hielo M51) y dirigible con viento fuerte (M32). Coherente with M67 (vehículos) and M51 (agua).

### Localizar HUD del vehículo (velocidad, dirección)
- Spec: localizar HUD del vehículo (velocidad, dirección). Coherente with M67 (vehículos) and M53 (UI).
## Specs Vehículos (Beam 573)

### Localizar menús de personalización y avisos de docking
- Spec: localizar menús de personalización y avisos de docking. Coherente with M67 (vehículos) and M86 (localización).

### Localizar nombres de vehículos
- Spec: localizar nombres de vehículos. Coherente with M67 (vehículos) and M86 (localización).

### Testear HUD en 3 idiomas sin desbordes
- Spec: testear HUD en 3 idiomas sin desbordes. Coherente with M67 (vehículos) and M86 (localización).

### Localizar mensajes de límites (profundidad, altitud)
- Spec: localizar mensajes de límites (profundidad, altitud). Coherente with M67 (vehículos) and M86 (localización).

### Subtítulos en avisos del vehículo
- Spec: subtítulos en avisos del vehículo. Coherente with M67 (vehículos) and M58 (accesibilidad).
## Specs Vehículos (Beam 574)

### HUD legible con alto contraste opcional
- Spec: HUD legible con alto contraste opcional. Coherente with M67 (vehículos) and M58 (accesibilidad).

### Controles completos con gamepad (sin mouse)
- Spec: controles completos con gamepad (sin mouse). Coherente with M67 (vehículos) and M56 (interfaz).

### Probar ciclo dirigible: despegar → volar → aterrizar
- Spec: probar ciclo dirigible: despegar → volar → aterrizar. Coherente with M67 (vehículos) and M68 (transporte).

### Probar ciclo submarino: sumergir → explorar → emerger
- Spec: probar ciclo submarino: sumergir → explorar → emerger. Coherente with M67 (vehículos) and M68 (transporte).

### Alimentar logros de exploración (M72) por viajes
- Spec: alimentar logros de exploración (M72) por viajes. Coherente with M67 (vehículos) and M72 (logros).
## Specs Vehículos (Beam 575)

### Registrar fotos del vehículo (M56, PHOTO_POSE_REQUEST)
- Spec: registrar fotos del vehículo (M56, PHOTO_POSE_REQUEST). Coherente with M67 (vehículos) and M56 (fotografía).

### Guardar estado del vehículo en el mundo (M59)
- Spec: guardar estado del vehículo en el mundo (M59). Coherente with M67 (vehículos) and M59 (guardado).

### Coordinar con M68 la navegación asistida
- Spec: coordinar con M68 la navegación asistida. Coherente with M67 (vehículos) and M68 (transporte).

### Testear integración con M28 (viajes entre islas)
- Spec: testear integración con M28 (viajes entre islas). Coherente with M67 (vehículos) and M28 (viajes).

### Firmar los documentos del módulo (modelo y plataforma)
- Spec: firmar los documentos del módulo (modelo y plataforma). Coherente with M67 (vehículos) and AGENTS.md §3.

### Actualizar CHECKLIST-GLOBAL con el progreso real
- Spec: actualizar CHECKLIST-GLOBAL con el progreso real. Coherente with M67 (vehículos) and AGENTS.md §21.

## Specs Vehiculos (Beam 576)

### Actualizar DOCUMENTACION/README.md con el modulo 67
- Spec: actualizar DOCUMENTACION/README.md con el modulo 67. Coherente with M67 (vehiculos) and AGENTS.md sec 11.

### Actualizar ESTADO-PARALELO.md
- Spec: actualizar ESTADO-PARALELO.md. Coherente with M67 (vehiculos) and AGENTS.md sec 21.

### Generar el log 63 en Logs/
- Spec: generar el log 63 en Logs/. Coherente with M67 (vehiculos) and AGENTS.md sec 6.


## Specs Vehiculos (Beam 577)

### Verificar con verificar_checklist.py (sin alertas nuevas)
- Spec: verificar con verificar_checklist.py (sin alertas nuevas). Coherente with M67 (vehiculos) and AGENTS.md sec 21.9.

### Push del modulo y reporte al usuario
- Spec: push del modulo y reporte al usuario. Coherente with M67 (vehiculos) and AGENTS.md sec 4.

### Marcar items solo al cumplir la DoD (seccion 21.6)
- Spec: marcar items solo al cumplir la DoD (seccion 21.6). Coherente with M67 (vehiculos) and AGENTS.md sec 21.6.

### Revisar que plan-inicial == plan-actual (SHA-256)
- Spec: revisar que plan-inicial == plan-actual (SHA-256). Coherente with M67 (vehiculos) and AGENTS.md sec 11.

### Confirmar 130 items exactos
- Spec: confirmar 130 items exactos. Coherente with M67 (vehiculos) and AGENTS.md sec 11.

### Specs items degradados T079 (2026-10-26, Reflection-Beam-1.0)
- **LOD de audio: atenuar > 40 m, silenciar > 80 m:** spec definida — atenuación de volumen por distancia (40 m atenuado, 80 m silenciado) para audio de vehículos. Dueño M91 (audio). Implementación: AudioStreamPlayer3D con max_distance=80 y attenuation model.

### Specs items degradados T079 (2026-10-26, Reflection-Beam-1.0)
- **L124 (Mejoras de faroles M49 y baúl):** baúl SÍ implementado (baul_slots_efectivo por nivel, techo 20 barco / 16 submarino = §3.1, testeado); faroles/lucernas = M49 (dueño externo, sin integración). Spec parcial: el baúl cumple; faroles diferidos a M49.
