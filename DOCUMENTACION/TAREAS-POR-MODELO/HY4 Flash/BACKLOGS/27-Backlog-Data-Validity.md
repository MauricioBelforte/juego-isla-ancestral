# 27-Backlog: Data File Validity (552 JSON, 28 batches)

> Creada por: agnes-3-flash - 2026-11-18 01:58
> Nicho: Volumen/verificacion (permanente)

## Metodo

Para cada batch de 20 JSON:
1. python -c "import json; json.load(open('RUTA'))" - si falla = INVALIDO
2. Verificar que tiene al menos una clave raiz
3. Anotar: ARCHIVO / VALIDO? / N_CLAVES

## Tareas

- [x] T27-01: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=1 max=21. Sin invalidos. Ancla `net_contract.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-02: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=1 max=81. Sin invalidos. Ancla `crafting.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-03: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=2 max=4. Sin invalidos. Ancla `community_calendar.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-04: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `aur_001_cap0_historia.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-05: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `aur_002_cap0_saludo.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-06: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `aur_003_cap4_saludo.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-07: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `aur_005_cap0_saludo.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-08: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `cen_001_cap0_saludo_amistad90.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-09: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `cen_002_cap7_saludo.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-10: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `cen_004_cap1_historia.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-11: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `cor_001_cap0_historia.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-12: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `cor_002_cap0_saludo_amistad90.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-13: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=4. Sin invalidos. Ancla `cor_003_cap7_saludo.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-14: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `cor_005_cap2_saludo.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-15: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `riz_001_cap0_saludo_primera.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-16: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `riz_001_cap6_saludo.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-17: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `riz_002_cap2_saludo.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-18: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `riz_003_cap1_historia.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-19: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `riz_004_cap0_saludo_amistad60.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-20: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `riz_005_cap0_historia_noche.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-21: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=3. Sin invalidos. Ancla `riz_006_cap1_mision.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-22: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=1 max=7. Sin invalidos. Ancla `riz_008_cap0_saludo.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-23: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=2 max=12. Sin invalidos. Ancla `historia_principal.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-24: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=1 max=12. Sin invalidos. Ancla `privacidad.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-25: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=1 max=25. Sin invalidos. Ancla `trailer_spec.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-26: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=3 max=9. Sin invalidos. Ancla `vision.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-27: 20 JSON, 20 VALIDOS, 0 INVALIDOS. Claves raiz: min=6 max=11. Sin invalidos. Ancla `gravedad_02.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.
- [x] T27-28: 12 JSON, 12 VALIDOS, 0 INVALIDOS. Claves raiz: min=2 max=6. Sin invalidos. Ancla `sonido_02.json` NO cae en este lote (orden derivo desde la creacion del backlog); lote asignado por posicion 20.

## CIERRE (HY4 Flash, 2026-11-18) — BACKLOG COMPLETO

- **28/28 tareas `[x]`**, cola 0. Universo cubierto: **552/552 JSON** bajo `game/isla-ancestral/data/` (27 lotes de 20 + 1 de 12), sin solapar ni dejar huecos.
- Resultado: **552 VALIDOS, 0 INVALIDOS**. `json.loads` exitoso en todos; ninguno con raiz vacia (minimo 1 clave raiz, maximo 81).
- Deriva de indice: los anclas del backlog ya no caen en su lote original porque el directorio gano archivos desde su creacion. Se asigno por posicion sobre la ordenacion `str(path).lower()` y se registro la desviacion en cada tarea; la cobertura es del 100% del universo actual.
- Sin modificar datos, sin commits/push. Reporte al director por backlog terminado.

**Firma:** hy4-flash

