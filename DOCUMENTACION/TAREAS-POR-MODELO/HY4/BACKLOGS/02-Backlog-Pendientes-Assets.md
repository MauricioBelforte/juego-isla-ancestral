# Hy4 — Pendientes globales: M36/M25/M40/M35/M18-BIS/M18/M18-TER
**Fuente:** BACKLOG-MASTER.md Hy4 (sección dividida 4nov por fundador)
**Modelo:** Hy4 preview (Tencent Hunyuan)
**Plataforma:** WorkBuddy
**Estado:** [→] Activo

---

## Pendientes globales

> **RECONTADO 2026-09-13 (Hy4, auditoria 1d):** el titulo decia "21 items" y no
> cerraba con las casillas. Conteo real de `[ ]` de este archivo:
> **M36 = 5 · M25 = 6 · M40 = 1 · M35 = 4 → 16 pendientes propios**
> (mas M18-BIS 2 = **traspasados a MiMo**, no contar; mas M18-TER 30 = bloqueados
> por revision visual). Los encabezados de M25 ("2 pendientes") y M35 ("3
> pendientes") estaban mal y se corrigen abajo.

### M36 Fauna (5 pendientes)
- [ ] Pez tropical (2 variantes de color)
- [ ] Lagarto de isla
- [ ] Cabra
- [ ] Gallina
- [ ] Mariposa (alas simples para animar)

### M25 Ruinas (6 pendientes — el encabezado decia 2, corregido 2026-09-13)
- [ ] Columna rota (2 variantes de altura)
- [ ] Columna entera con capitel
- [ ] Bloque de piedra tallada (modulo de muro)
- [ ] Dintel caido
- [ ] Palanca de puzzle (interactuable)
- [ ] Estructura sumergida parcial (marea)

### M40 Infraestructura (1 pendiente)
- [ ] Valla de madera (modulo recto + esquina)

### M35 Mineria (4 pendientes — el encabezado decia 3, corregido 2026-09-13)
- [ ] Cana de pescar
- [ ] Pez capturable (compartido con fauna)
- [ ] Cangrejo ermitano (recompensa rara)
- [ ] Carrito de vias (26 subterraneo)

### M18-BIS Casas grandes — **TRASPASADO A MiMo (directiva del usuario 2026-09-11)**
HY4 cerro 3/5 (mediana log 806, choza ampliada log 808, casona log 844) y deja el
resto. **No retomar mansión ni casa de vecino salvo que MiMo los libere.**
Para quien los tome, artefactos reutilizables YA listos:/n- `18-Casas/scripts/capturar_casa.py` — capturador GENERICO (dict `VINETAS`).
  Entradas existentes: `casa_mediana` r=22.0/4 vin, `choza_ampliada` r=10.0/4 vin,
  `casona` r=14.0/6 vin. Agregar la entrada de la casa nueva y listo.
- `18-Casas/scripts/crear_casa_casona_lowpoly.py` — plantilla mas reciente y completa
  (~580 lineas): muros con vanos por lista, tabiques interiores, techo de tablones +
  frontones por bmesh, chimenea que atraviesa el techo, porche de entrada.
- `18-Casas/scripts/crear_casa_choza_ampliada_lowpoly.py` — la mas simple (500 lineas).
- `18-Casas/scripts/mobiliario_util.py` + `hoja_util.py` (scripts-reutilizables).
Reglas duras que se aprendieron a costa de iteraciones: pendiente 19-20 deg (12=galpon,
29=choza), chimenea SIEMPRE asomando sobre el techo, frontones en la misma mesh del
techo (E-70), apoyos chicos en CILINDRO y nunca en caja (E-104/E-105).
- [x] **Casa mediana** 2 ambientes (16x12 m por directiva v4) — v8 CERRADA, log 806.
      60 SM_/3172 tris/12 mats ALTA · 17/3172/8 MEDIA · 17/2522/4 BAJA
- [x] **Casa choza ampliada** (1 ambiente 5x4 m) — CERRADA, log 808.
      15 SM_/1140 tris/12 mats ALTA · 11/1140/8 MEDIA · 11/902/4 BAJA.
      Cumple M166 §3.3 **sin excepcion**. Bug corregido: cano de chimenea corto (E-100)
- [x] Casa amplia / casona (10x8 m: sala + 2 dormitorios + cocina) — CERRADA log 844 (30 SM_/3052 tris/12 mats ALTA · 19/3052/8 MEDIA · 19/2122/4 BAJA)
- [ ] Mansion (14x10 m, multi-habitacion, biblioteca + sala de museo) — **TRASPASADO a MiMo**
- [ ] Casa de vecino (variante cozy re-amueblada, para M19 RF12) — **TRASPASADO a MiMo**

### M18 Mobiliario interior interactivo (14/14 CERRADOS — 4 en log 810, 10 en log 811)
Auditados 2026-09-10: figuraban `[x]` en el checklist pero **no existe script,
.blend ni GLB**. Son muebles interactivos (dormir/sentarse/cocinar/almacenar),
NO decoracion estatica. No confundir con los `decor_*` de M18-TER (esos si existen).
- [x] cama_basica — CERRADA log 810 (15·5·5 / 180·180·124 tris / 5·5·4 mats)
- [x] velador — CERRADO log 810 (9·4·4 / 160·160·108 tris / 5·5·4 mats; vela+llama unidas)
- [x] silla_madera — CERRADA log 810 (11·2·2 / 132·132·90 tris / 2·2·2 mats)
- [x] mesa_madera — CERRADA log 810 (9·2·2 / 108·108·74 tris / 2·2·2 mats)
- [x] cama_doble — CERRADA log 811 (14·5·5 / 168·168·114 tris / 5·5·4 mats)
- [x] sillon — CERRADO log 811 (10·3·3 / 120·120·82 tris / 3·3·3 mats)
- [x] nevera_rustica — CERRADA log 811 (11·5·5 / 360·360·248 tris / 5·5·4 mats)
- [x] estufa_lena — CERRADA log 811 (12·3·3 / 268·268·186 tris / 3·3·3 mats)
- [x] estanteria — CERRADA log 811 (10·5·5 / 264·264·184 tris / 5·5·4 mats)
- [x] comoda — CERRADA log 811 (10·3·3 / 144·144·98 tris / 3·3·3 mats)
- [x] lampara_pie — CERRADA log 811 (6·3·3 / 300·300·208 tris / 4·4·4 mats)
- [x] alfombra — CERRADA log 811 (4·4·4 / 496·496·344 tris / 4·4·4 mats)
- [x] cuadro_ancestral — CERRADO log 811 (7·5·5 / 240·240·164 tris / 4·4·4 mats)
- [x] maceta_interior — CERRADA log 811 (5·3·3 / 436·436·302 tris / 3·3·3 mats)

### M18-TER Tienda decoracion (30 pendientes — batch script creado, pendiente revision visual)
- 30 accesorios de decoracion (iluminacion, pared, plantas, alfombras, cocina, ancestral, oceano, floral, mobiliario, exteriores)

---
