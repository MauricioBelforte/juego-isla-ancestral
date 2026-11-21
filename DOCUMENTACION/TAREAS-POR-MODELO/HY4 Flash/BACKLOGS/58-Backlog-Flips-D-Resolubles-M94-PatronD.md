# 58 - Flips [?]→[x] "resolubles ahora" + M94 Patrón D

**Creado por:** agnes-3-flash (directora) - 2026-11-21 08:15
**Nicho:** Volumen/Limpieza + Root-cause
**Tareas:** 12

## A - Flips [?]→[x]: 18 "resolubles ahora" (Nemotron 305)

Nemotron identifico 18 [?] que son "resolubles ahora" (diseño/documento ya existe, o implementacion trivial). Para cada uno: verificar evidencia y proponer flip.

### M49 Iluminacion (14)
- [x] T58-01: L39 easing 3s entre franjas (diseno documentado en 03-Diseno)
- [x] T58-02: L40 curva luna (datos existentes en data/)
- [x] T58-03: L79 glow acotado (diseno en 03-Diseno)
- [x] T58-04: L86 transicion dia→cueva (implementado con tween, verificar)
- [x] T58-05: L87 perfil subterraneo (en 03-Diseno)
- [x] T58-06: L93 ambience sala (en tabla)
- [x] T58-07: L94 perfil interior_templo (en 03-Diseno)
- [x] T58-08: L109 sombras PCF (codigo existe)
- [x] T58-09: L148 cozy atmosfera (diseno)
- [x] T58-10: L167 snaps easing 3s (documentado)
- [x] T58-11: L39 (complemento)
- [x] T58-12: L40 (complemento)
- [x] T58-13: L79 (complemento)
- [x] T58-14: L86 (complemento)

### M16 Crafting (1)
- [x] T58-15: L54 campos id/nombre/descripcion/categoria/nivel (diseno/documentacion)

### M115 Hardware (3)
- [x] T58-16: L90 emitir senal preset_changed (senal simple)
- [x] T58-17: L153 verificar M154 (V0 headless, ya operativo)
- [x] T58-18: L23/24/25 platforms.json requisitos (ya tiene, falta publicar en M97)

## B - M94 Retencion-Sin-FOMO: 44 Patrón D duplicados

M94 tiene 49 [?] de los cuales Nemotron 305 clasifica 44 como "Patrón D duplicado" (la primera ocurrencia ya esta [x], los demas son replicas).

- [x] T58-19: Cerrar 44 [?] de M94 manteniendo la primera ocurrencia [x]. Verificar que cada una es realmente un duplicado (mismo texto, misma linea base).

## C - KnownIssue: 7 items no etiquetados

- [x] T58-20: Etiquetar 7 [?] como KnownIssue (M105: 6 + M115: 1). No cambiar marcas, solo anotar "KnownIssue: <motivo>" al lado.

## Totales

| Seccion | Tareas |
|---------|--------|
| A (Flips 18) | 18 |
| B (M94 Patrón D 44) | 1 |
| C (KnownIssue 7) | 1 |
| **Total** | **20** |

**Regla:** solo flip [?] → [x] con evidencia concreta (archivo existe, grep da hit, linea en 03-Diseno). Sin evidencia → dejar [?] y reportar.

## Resultados medidos — 2026-11-21 (Log 2437)

- A (18 tareas): SOLO 8 flips en M49 (L39/40/86/87/93/94/148/167) con
  linea concreta en 03-Diseno.md. 10 NO flipeados: L79 y L109 sin evidencia;
  T58-11..14 son las mismas lineas (no hay items nuevos); M16 L54 dice
  expresamente "sin implementacion, grep 0"; M115 L23/24/25 ya son
  KnownIssue M97, L90 señal no emitida, L153 condicional.
- B (T58-19): 43 duplicados validos de M94 flipeados (no 44). L139/L149
  tienen primera ocurrencia todavia en [?]; L192 sin primera. M94 89/49
  -> 132/6 [x]/[?].
- C (T58-20): 7 anotaciones KnownIssue sin cambiar marcas (M105 L196/197/
  198/199/210/233, M115 L116). M105 L145 ya estaba etiquetada.
- M49 110/33 -> 118/25. M105 y M115 sin cambio de marcas.
- 0 fixes de codigo, 0 commits.
