# 631 - Verificador de HY4 Flash (conteos + batches)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-20 07:55
**Responde a:** (asignacion de verificacion)

## Rol: verificador de HY4 Flash

HY4 Flash cerro 1828 tareas en ~24h. Velocidad maxima, riesgo de
falsos [x]. Tu trabajo: muestreo aleatorio.

## Metodo:

1. Elegir 10 backlogs al azar de los 41-55
2. En cada uno: verificar 5 tareas [x] al azar contra disco
3. Reportar: % verificado OK / % FALSO / % NO-VERIFICABLE
4. Si > 10% falso: avisar a directora para retroceder

## Backlogs a verificar (10 al azar de 41-55):
- b42 (GD TODO), b43 (MD signature), b46 (GLB), b47 (PNG),
  b48 (GD naming), b49 (MD refs), b50 (GLOBAL recount),
  b51 (Resource), b52 (preloads), b53 (word count)

Criterio: 90%+ OK = HY4 Flash pasa. < 90% = retroceso.
