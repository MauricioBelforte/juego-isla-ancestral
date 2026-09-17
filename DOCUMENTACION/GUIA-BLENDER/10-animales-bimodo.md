**Modelo:** opencode/mimo-v2-pro-free
**Plataforma:** OpenCode
**Fecha:** 2026-09-10

---

# 10 — Animales con Dos Modos de Comportamiento (Bimodo)

## 10. ANIMALES CON DOS MODOS DE COMPORTAMIENTO (2026-09-05 — glm-5.3-free / Kilo Code, caso gaviota M36)

> **PARA QUIEN ES ESTA SECCION:** cualquier agente que deba modelar un animal
> con DOS poses (vuelo/tierra, nadar/tierra, etc.) — paloma, loro, pato, una
> tortuga marina, lo que sea. La gaviota (Log 694/695) es el CASO DE
> REFERENCIA: 2 sesiones de iteracion dolorosa destiladas en reglas duras.
> El lado Godot esta en `GUIA-GODOT/12-animales-bimodo.md`. LEER AMBAS ANTES DE EMPEZAR.
> Scripts de referencia: `36-Fauna/scripts/crear_gaviota_lowpoly.py` (v14d,
> blender) y `game/isla-ancestral/scripts/fauna/gaviota_npc.gd` (v16, godot).

### 10.1 PRINCIPIO FUNDAMENTAL: el .blend guarda UNA sola pose — la PRIMARIA

El asset viaja a Godot en UNA pose (la del GLB) y **el segundo modo se
compone EN GODOT por rotacion de piezas**, nunca modelando dos assets.

- La pose del GLB debe ser el **MODO PRIMARIO** (el de reposo natural):
  gaviota = VUELO (patas recogidas, alas extendidas). Un animal acuatico
  = NADO (aletas en posicion de remo). Una paloma tambien = vuelo.
- El modo secundario (tierra) NO se modela: Godot rota las piezas hacia
  la pose secundaria con QUATERNIONES medidos (ver guia Godot §12.3).
- Si modelas los dos modos como assets separados, te van a desincronizar
  en cada ajuste (la gaviota v14 tenia 2 GLB y se descarto el approach).

### 10.2 Anatomia minima del ave bimodo (o animal bimodo en general)

```
SM_<Animal>_Cuerpo        (tronco, ojos, pico/hocico — todo lo estatico)
SM_<Animal>_Ala_L / _R    (o aletas/patas delanteras: LA pieza del modo 1)
SM_<Animal>_Pata_0 / _1   (o patas traseras: LA pieza del modo 2)
SM_<Animal>_Pie_0 / _1    (opcional: apoyo terminal pegado al extremo)
SM_<Animal>_Cola          (estetica + tope de escala del modo secundario)
SM_<Animal>_Punta_0 / _1  (detalles de la punta del ala — NEGRO en gaviota)
```

Reglas por pieza (aprendidas de 5 iteraciones fallidas):

1. **ALAS: loft por ANILLOS desde el hombro (seccion 9.4), NO cubos.**
   Perfil decreciente con N=8: cuerda gruesa en el hombro (rc 0.045),
   afinandose a la punta (rc 0.028). El ORIGEN del objeto en el HOMBRO
   (rotation pivot de Godot) con la malla extendida hacia su lado
   (loft con t*LARGO desde 0, §8.1 regla 3).
   **VOCABULARIO DEL ALA (usado en toda la documentacion de giros —
   ver GUIA-GODOT/12-animales-bimodo.md):** SPAN = el largo del ala (lo que se
   extiende desde el hombro, 0.60 en gaviota v14); CUERDA = el ancho
   pico→cola de la superficie (~0.07 en el hombro); el ala se modela
   con la CUERDA alineada al eje X del objeto y el SPAN naciendo del
   origen. El rollo de giros en Godot entero (que eje es el span, que
   signos se niegan por lado, el orden de composicion R=Ry·Rx·Rz) esta
   documentado en `GUIA-GODOT/12-animales-bimodo.md` — el LADO BLENDER de esa
   anatomia es: origen en hombro + cuerda en X + span desde 0. Si el
   pivot queda en el centro de la pala, TODA la tabla de giros falla
   ("el ala orbita") y no hay codigo que lo arregle.
2. **ALAS: el lado L sale hacia -Y y el R hacia +Y en Blender (Z-up).**
   Tras el export Y-up quedan: span L en +Z, R en -Z (dump_glb.py lo
   confirma). El hombro L se ubica en y=-0.05*lado — ojo v14b: hombro
   en `-0.05*lado` invierte el ala y sale por el costado opuesto.
3. **PATAS del modo secundario: CONOS con el ORIGEN en la CADERA y el
   eje del cono apuntando en la DIRECCION DE REPOSO del modo primario.**
   Gaviota: dir (-0.85, 0, -0.45) (atras-abajo bajo la cola) via
   `dir.to_track_quat('Z', 'Y').to_euler()`. La razon: Godot rota DESDE
   esa direccion hacia la vertical con un quaternion — si el origen no
   esta en la cadera o el eje no es el real, el despliegue falla.
   TAPER: radius1 (cadera) GRUESO, radius2 (tobillo) fino — v14c lo
   invirtio y las patas parecian al reves.
4. **PIES: cubos chicos pegados al EXTREMO de la pata en reposo** (el
   apex del cono en pose de vuelo). Se re-parentan a la pata EN GODOT
   (§12.4 guia Godot) para acompanar el despliegue. NO modelarlos en
   pose desplegada: en reposo quedarian flotando.
5. **Longitud de patas = hasta donde llega el APOYO del modo secundario.**
   Regla practica gaviota: patas 0.18 permiten cuerpo erguido 0.42 rad
   sin enterrar la cola. Si el usuario pide "mas erguida" y la cola se
   entierra, la solucion es PATAS MAS LARGAS (cambio en Blender), no
   pitch infinito en Godot (v13f lo demostro: patas 0.09 + pitch 0.45
   = cola 0.20 m por debajo de las patas, imposible de asentar).
6. **Materiales por pieza:** PATAS/PIEOS con material propio (gaviota:
   naranja), manto superior del ala con SU material (gris) por
   `p.normal.z > 0.3` en Blender Z-up (tras export queda normal +Y
   hacia arriba en Godot — el criterio z>0.3 se evalua ANTES de export).

### 10.3 FLUJO OBLIGATORIO de creacion (bimodo)

```
0. BACKUP del asset anterior si existe (Obsoletos/, §5 AGENTS.md)
   — ANTES de tocar el .blend. La gaviota se rescato del .blend1.
1. Modelar modo primario completo (patas EN reposo, no desplegadas).
2. Verificar en BLENDER: captura + `dimensión` de patas/alas — el
   eje del cono de la pata en local Y (dump), taper correcto.
3. Guardar .blend (§9.6) — JAMAS exportar sin aprobacion del usuario.
4. Exportar GLB alta (exportar_godot.py con EXPORT_ONLY={ID-Modulo}).
5. DUMPEAR el GLB (dump_glb.py) y LEER los bounds de CADA pieza:
   que eje ocupa el span del ala, que eje el cono de la pata, donde
   quedo el origen de cada nodo. SIN ESTE PASO NO SE ANIMA NADA (E-11).
6. Recien ahi: animar en Godot siguiendo §12 de la guia Godot.
```

### 10.4 ERRORES FATALES del bimodo (cada uno costó iteraciones)

1. **bpy.ops por el socket MCP (E-22):** `primitive_cone_add` y cia
   FALLAN SILENCIOSOS en contexto restringido. La gaviota v14 se creo
   "OK" y las patas/pies/puntas NUNCA EXISTIERON. Siempre `bmesh.ops`
   puro (`create_cone`, `create_cube`) + `objects.new()`.
2. **Crear en la instancia MCP compartida:** otra sesion (la nutria)
   abrio su .blend en el MISMO Blender MCP y guardo encima del blend de
   la gaviota. Perdimos la escena. REGLA: modificaciones serias via
   BLENDER HEADLESS (`blender -b --python script.py`) — no toca la
   instancia interactiva y es reproducible.
3. **Modelar el modo secundario en el .blend** (patas desplegadas):
   rompe el reposo del modo primario y el despliegue en Godot no tiene
   direccion de partida clara. El GLB SIEMPRE en reposo del primario.
4. **Patas con eje/taper/origen mal:** eje en Z en vez de Y tras el
   export, taper invertido, origen fuera de la cadera — cualquiera de
   los tres tumba la pata en vez de desplegarla (v14c/v14d).
5. **Adivinar la altura del modo secundario con constantes:** la altura
   de la pose parada NO se calcula en Blender — se MIDE en Godot con
   el bounding real plegado (§12.5 guia Godot). El -0.28 de la gaviota
   v13 era una constante adivinada que flotaba 20 cm.

### 10.5 Checklist final del asset bimodo (Blender)

- [ ] Piezas animables separadas como SM_ con nombre de lado/indice
- [ ] Alas: loft por anillos, origen en hombro, span L en -Y / R en +Y
- [ ] Patas: cono, origen en cadera, eje = direccion de reposo primario,
      taper cadera-grueso→tobillo-fino, longitud alcanza el apoyo
- [ ] Pies: pegados al apex de la pata EN REPOSO
- [ ] Materiales asignados por pieza (manto por normal.z > 0.3)
- [ ] z_min 0.045 del GRUPO (§8.1 regla 5) — el asentado es del grupo
- [ ] .blend guardado en {ID-Modulo}/ ANTES de exportar (§9.6)
- [ ] GLB alta exportada y DUMPEADA — bounds de cada pieza anotados
- [ ] Backup previo en Obsoletos/ con timestamp

**Naming de .blend:** `{nombre}_{variante}.blend` (ej: `nutria_ribera_v2_alta.blend`).
