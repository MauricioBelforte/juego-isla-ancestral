# 58 - Flips [?]→[x] "resolubles ahora" + M94 Patrón D

**Creado por:** agnes-3-flash (directora) - 2026-11-21 08:15
**Nicho:** Volumen/Limpieza + Root-cause
**Tareas:** 12

## A - Flips [?]→[x]: 18 "resolubles ahora" (Nemotron 305)

Nemotron identifico 18 [?] que son "resolubles ahora" (diseño/documento ya existe, o implementacion trivial). Para cada uno: verificar evidencia y proponer flip.

### M49 Iluminacion (14)
- [ ] T58-01: L39 easing 3s entre franjas (diseno documentado en 03-Diseno)
- [ ] T58-02: L40 curva luna (datos existentes en data/)
- [ ] T58-03: L79 glow acotado (diseno en 03-Diseno)
- [ ] T58-04: L86 transicion dia→cueva (implementado con tween, verificar)
- [ ] T58-05: L87 perfil subterraneo (en 03-Diseno)
- [ ] T58-06: L93 ambience sala (en tabla)
- [ ] T58-07: L94 perfil interior_templo (en 03-Diseno)
- [ ] T58-08: L109 sombras PCF (codigo existe)
- [ ] T58-09: L148 cozy atmosfera (diseno)
- [ ] T58-10: L167 snaps easing 3s (documentado)
- [ ] T58-11: L39 (complemento)
- [ ] T58-12: L40 (complemento)
- [ ] T58-13: L79 (complemento)
- [ ] T58-14: L86 (complemento)

### M16 Crafting (1)
- [ ] T58-15: L54 campos id/nombre/descripcion/categoria/nivel (diseno/documentacion)

### M115 Hardware (3)
- [ ] T58-16: L90 emitir senal preset_changed (senal simple)
- [ ] T58-17: L153 verificar M154 (V0 headless, ya operativo)
- [ ] T58-18: L23/24/25 platforms.json requisitos (ya tiene, falta publicar en M97)

## B - M94 Retencion-Sin-FOMO: 44 Patrón D duplicados

M94 tiene 49 [?] de los cuales Nemotron 305 clasifica 44 como "Patrón D duplicado" (la primera ocurrencia ya esta [x], los demas son replicas).

- [ ] T58-19: Cerrar 44 [?] de M94 manteniendo la primera ocurrencia [x]. Verificar que cada una es realmente un duplicado (mismo texto, misma linea base).

## C - KnownIssue: 7 items no etiquetados

- [ ] T58-20: Etiquetar 7 [?] como KnownIssue (M105: 6 + M115: 1). No cambiar marcas, solo anotar "KnownIssue: <motivo>" al lado.

## Totales

| Seccion | Tareas |
|---------|--------|
| A (Flips 18) | 18 |
| B (M94 Patrón D 44) | 1 |
| C (KnownIssue 7) | 1 |
| **Total** | **20** |

**Regla:** solo flip [?] → [x] con evidencia concreta (archivo existe, grep da hit, linea en 03-Diseno). Sin evidencia → dejar [?] y reportar.
