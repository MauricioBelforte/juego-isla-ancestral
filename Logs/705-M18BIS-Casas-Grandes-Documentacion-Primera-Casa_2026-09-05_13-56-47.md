# Log 705: M18-BIS — Casas grandes habitables: documentación + primera casa

**Fecha:** 2026-09-05
**Hora:** 13:56
**Modelo:** glm-5.3-free
**Plataforma:** Kilo Code

## Resumen
Directiva del usuario: crear CASAS GRANDES que se puedan ENTRAR DENTRO,
amplias, proporcionales a los personajes, con muebles propios (camas, mesas,
sillas, nevera...). Detectado que el sistema lógico de muebles (RF5-RF7)
existía pero NO los assets 3D. Documentado el gap, registrados 19 ítems
nuevos y construida la primera casa completa.

## Cambios Realizados

### 1. Documentación del alcance nuevo
- DOCUMENTACION/18-Casas/plan-actual/01-Requerimientos.md §6 NUEVO:
  escala de referencia (NPC 1.75 m → puerta 1.00×2.10, techo interior 2.60,
  cama 2.00×0.90, mesa 0.80), familia de 4+1 casas, tabla de 14 muebles
  interiores, nota de lore (nevera rústica en vez de heladera eléctrica,
  M147 sin electricidad), presupuesto por sub-grupos.
- CHECKLIST-OBJETOS-BLENDER.md §M18-BIS: 19 ítems (5 casas + 14 muebles),
  contadores actualizados (total 135, pendientes 53).
- CHECKLIST-GLOBAL.md: M18 reabierto 🟡 (11/145) con la directiva.

### 2. Casa mediana habitable (primera del tier)
	ools/mcp/blender-mcp/18-Casas/scripts/crear_casa_mediana_lowpoly.py v2:
- 8×6 m exterior (43.7 m² útiles), muros 2.60, techo a dos aguas paja
- DOS ambientes: dormitorio 4.38 m (cama 2.00×0.90 con manta+almohada,
  velador+farol con llama, cómoda, cofre, alfombra) y sala/cocina 3.18 m
  (mesa 1.20×0.80, 2 sillas, estufa de leña con chimenea, nevera rústica
  de piedra, estantería con libros, alfombra)
- PUERTA PRINCIPAL REAL: vano 1.00×2.10 con marco, hoja abierta 35° hacia
  afuera, umbral de piedra — NPC 1.75 m entra sin agacharse
- Puerta interior 0.90×2.10 (vano entre ambientes), 6 ventanas con vidrio
  semitransparente, zócalo perimetral de piedra, piso tablones, techo
  SM_Techo_* (sub-grupo ocultable al entrar en Godot)
- 45 SM_ (sub-grupos: Zocalo 1, Piso 2, Muro 4, Ventana 12, Puerta 6,
  Divisoria 1, Techo 1, Mueble 18) · 2104 tris · 11 materiales
- z_min 0.045 medido en vértices reales (E-24) + assert

### 3. Verificación NUMÉRICA (sin visión, M154 V0)
Raycasts en Blender MCP:
- Vano principal LIBRE: ray paralelo al muro pasa limpio 5.64 m hasta el
  muro trasero (v1 tenía la hoja de 1.98 cruzando el vano — FIX v2: hoja
  0.98 girada 35° hacia afuera).
- Puerta interior LIBRE en 3 alturas.
- 18/18 muebles dentro del interior (v1: nevera interpenetrada con la
  estantería — FIX v2: movida a la esquina junto a la divisoria).
- Alturas de uso: colchón top 0.645, mesa 0.905 (esperadas ±0.03).
- 6 capturas orbitales v2 en 18-Casas/capturas/ (13-54-20) — PENDIENTE
  de aprobación visual del usuario (V1).

## Bugs encontrados y corregidos en la propia sesión
1. Hoja de puerta 1.98 de largo bloqueaba el vano → 0.98 + rotación correcta
   (raycast paralelo al muro como validador de "entrable").
2. Nevera interpenetrada con estantería → reubicada (validador AABB por
   pieza contra los límites interiores).
3. UnboundLocalError en ventana() lateral (orden de asignación) — fix.

## Pendiente
- APROBACIÓN VISUAL del usuario (6 capturas az 30-330).
- Resto del tier: choza ampliada, casona, mansión, casa de vecino + los
  14 muebles como assets individuales para el grid RF6 (los de la casa
  mediana ya sirven de patrón).
- GLB + variantes solo tras aprobación (§9.6 — .blend ya guardado).
- QA cruzado §21.8 cuando se complete el módulo.

## Addenda v3-v5 (feedback del usuario sobre la primera casa)
**Problema 1 (techo en V):** el usuario reportó que el techo se veía como
una V (vértice abajo, paja mirando adentro) en vez de una A. Causa: la
rotación X de los tableros tenía el signo invertido (+ang*s subía el
alero y hundía el centro). Fix: ot=(-pend*s, 0, 0) + geometría del
techo derivada de FONDO_Y (alero, pendiente, largo, cabios escalables).
Verificado: rays verticales golpean paja en 3 puntos; cumbrero z 4.62.
**Problema 2 (tamaño):** el usuario pidió la casa EL DOBLE DE AMPLIA para
moverse/equipar/comprar/colocar objetos adentro. Fix: 8×6 → **16×12 m**
(interior útil 15.68×11.68 ≈ 183 m²), muros 2.60 → 3.20 (mejor visión
interior), divisoria a X=2.0 (dormitorio 9.9 m / sala 5.7 m), 4 ventanas
por muro largo, layout de muebles rehecho contra muros con el centro
libre + sofá y mesa baja nuevos en el dormitorio (sala de estar cozy).
Validación: 55 SM_ (20 muebles), vanos libres por raycast (11.64 m y
9.84 m limpios), 0 muebles fuera del interior, 6 capturas nuevas 14-11-01
(cámara orbital reajustada a la escala doble).
**Lección para la guía (documentada inline en el script):** en cajas
rotadas con ot=(rx*s,...) el signo de rx decide si la pendiente sube
hacia el centro (A) o hacia afuera (V) — validar techo con ray vertical
antes de mostrar (un techo en V deja pasar el ray entre los tableros).

## Addenda v6 (2 fixes de feedback visual del usuario)
1. **Ventana pegada a la divisoria:** los vanos (1.30, 1.94) del muro
   frontal/trasero terminaban exactamente en la cara de la divisoria
   (X 1.94, gap 0). Reubicados al centro del tramo real de la sala:
   (2.80, 3.44) y (5.40, 6.04) → gap 86 cm con la divisoria.
2. **"Madera vertical a un costado de la cama":** era el RESPALDO
   parado como tabla lateral en X (0.12 de espesor × 0.90 de alto en el
   costado -X, contra la pared). Fix: respaldo plano en el extremo Y+
   de la cama (0.90 ancho × 0.12 × 0.95, donde va la cabeza), almohada
   movida junto al respaldo (estaba en los pies), manta a los pies,
   velador+farol acompañando la cabeza.
Verificado por bounding numerico: gap ventana-divisoria 0.86 m,
respaldo y -0.61..-0.49 (extremo cabeza), almohada y -0.95..-0.61,
velador y -0.13..0.23 (lado cabeza). 6 capturas 19-08-58.

## Addenda v7 (fix del usuario: triangulo abierto entre muros y techo)
**Problema:** en los extremos X de la casa (sobre los muros laterales)
quedaba el TRIANGULO abierto entre el tope de muros (z 3.245) y las
pendientes del techo (hasta 4.545) — faltaban los FRONTONES (gable ends).
**Fix:** prisma triangular bmesh por extremo (SM_Fronton_I/D, espesor
0.12, madera clara): base = tope de muros, lados hasta la arista del
cumbrero. Verificado con raycasts horizontales desde afuera en 4 alturas
(golpean fronton a 4.02 m) + diagonal que antes entraba libre por la
brecha. 57 SM_ totales. 6 capturas nuevas.
**Leccion inline:** en un techo a dos aguas con cumbrero en X, el
triangulo de cierre vive en los EXTREMOS X (planos de los muros
laterales) — agregar frontones SIEMPRE, o queda abierto.
