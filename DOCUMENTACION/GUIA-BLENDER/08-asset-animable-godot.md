**Modelo:** opencode/mimo-v2-pro-free
**Plataforma:** OpenCode
**Fecha:** 2026-09-10

---

# 08 — Requisitos del Asset para ser Animado en Godot

## 8. Requisitos del asset para ser ANIMADO en Godot (2026-09-02 — glm-5.3/Kilo Code, directiva del usuario tras el caso tortuga M36)

> El flujo completo (Blender -> GLB -> Godot -> moverlo) esta en
> `GUIA-GODOT/11-blender-godot.md` (lado Godot). Esta seccion cubre el LADO BLENDER: que debe
> cumplir un asset para que despues otro agente pueda animarlo en Godot.

### 8.1 Reglas del asset animable

1. **Pieza movil = objeto SEPARADO `SM_`** con nombre descriptivo y sufijo de
   lado SI aplica: `SM_Tortuga_Aleta_D_0` / `_1` (izq/der), `SM_Tortuga_Cabeza`,
   `SM_Tortuga_Cola`. El GLB conserva cada pieza como nodo hijo y el script de
   Godot la encuentra por sufijo (minuscula/merge tolerant).
2. **Espejo de piezas pareadas (E-74): NEGAR el angulo, nunca `pi - ang`.**
   Con `pi - ang` la pieza izquierda apunta al lado contrario, cruza por
   debajo del cuerpo y queda invisible ("una sola pata").
3. **Pivot logico:** la rotacion en Godot pivota sobre el ORIGEN del nodo.
   Una aleta debe modelarse con el origen en el HOMBRO (donde nace del
   caparazon), no en el centro de la pala: modelar la pala extendida desde
   el origen (loft con t*LARGO desde 0) deja el pivot correcto gratis.
4. **NO fundir las piezas animables en la ALTA:** el merge de
   `generar_variante.py` (umbral volumetrico) puede agrupar piezas chicas
   en la media/baja — aceptable (el script de Godot debe tolerar refs null),
   pero la ALTA debe conservarlas separadas para que la animacion se vea.
5. **z_min 0.045 (E-12):** obligatorio igual que siempre. El script de Godot
   compensa el asentado con `modelo.position.y = -0.045`; si el asset nace
   a otra altura, esa constante hay que ajustarla y el agente de Godot no
   lo sabra — mantener 0.045 EXACTO.
6. **Contar piezas (E-70) contando las animables de mas:** cada pieza que se
   quiera mover es un SM_ que suma al tope ALTA de <=16. La tortuga quedo en
   14 con 5 piezas animables (2 aletas D + 2 aletas T + cabeza).

### 8.2 ERRORES FATALES del lado Blender (no repetir)

1. **Modelar la pieza animada pegada al cuerpo (1 malla):** imposible de
   animar en Godot sin rig. Si la pieza se debe mover, es OTRO objeto.
2. **Origen/pivot en el centro geometrico de la pala:** en Godot la rotacion
   pivota ahi y la aleta "orbita" en vez de remar. Modelar con el origen en
   la raiz articular (E-09 mide z del bounding: ojo con piezas loftadas).
3. **Espejo con `pi - ang` (E-74):** pieza invisible del lado contrario.
4. **Exceder 16 SM_ por agregar piezas animadas:** recortar decorativas antes
   que las articulares (ej: 9 escudos de la tortuga = 1 sola malla multi-pad
   bmesh, no 9 objetos).
5. **Asentar cada pieza animable por separado:** el asentado es del GRUPO
   (todas las SM_ del script) — las aletas nacen tocando 0.045 en su pose de
   GLB, y Godot preserva esa pose (el script anima SUMANDO sobre la base,
   nunca reemplazando — ver 07 §11.4).

### 8.3 Checklist Blender del asset animable (ademas del §4 existente)

- [ ] Cada pieza que Godot deba mover es `SM_` separado con nombre claro.
- [ ] Pares espejados: angulo negado entre lados (E-74), verificado con la
      Y de cada pieza cayendo a su lado del eje de simetria.
- [ ] Origen de cada pieza articular en su raiz (hombro/base del cuello).
- [ ] ALTA conserva las piezas separadas; MEDIA/BAJA pueden fusionar (Godot
      tolera nulls con contador `N/M nodos animables`).
- [ ] z_min 0.045 EXACTO del grupo (Godot usa la constante -0.045).
- [ ] Capturas 6 azimuts E-13 + hoja: las piezas animables deben verse en su
      pose de GLB (esa es la base que Godot preserva al animar).
