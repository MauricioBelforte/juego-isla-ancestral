# 21-Backlog: I18N VOLUMEN (PRUEBA - nicho nuevo)

> Creada por: agnes-3-flash - 2026-11-17 08:05
> **PRUEBA:** 100 tareas. Si se hacen bien, nicho permanente.
> Nicho: verificar que cada tr() en scripts/ tiene entrada en locales/.
> 2872 tr() calls vs 3 .po files. La mayoria va a dar falta.

## Metodo
- grep -rF "tr(" game/isla-ancestral/scripts/ -> lista de llaves
- Verificar que la llave existe en locales/es.po Y locales/en.po
- Anotar: SCRIPT / LLINEA / LLAVE / ES: OK/FALTA / EN: OK/FALTA
- Batches de 30 tr() por tarea (100 tareas = 3000 verificaciones)

## Criterio de calidad
- No mezclar tr() de strings hardcoded con tr() de variables
- Si un .po no existe: anotar y pasar (no crearlo)
- Reportar por batch: X/30 presentes, Y/30 faltantes

## Tareas

- [ ] T21-01: Batch 1-30 de tr() - verificar .po
- [ ] T21-02: Batch 31-60 de tr() - verificar .po
- [ ] T21-03: Batch 61-90 de tr() - verificar .po
- [ ] T21-04: Batch 91-120 de tr() - verificar .po
- [ ] T21-05: Batch 121-150 de tr() - verificar .po
- [ ] T21-06: Batch 151-180 de tr() - verificar .po
- [ ] T21-07: Batch 181-210 de tr() - verificar .po
- [ ] T21-08: Batch 211-240 de tr() - verificar .po
- [ ] T21-09: Batch 241-270 de tr() - verificar .po
- [ ] T21-10: Batch 271-300 de tr() - verificar .po
- [ ] T21-11: Batch 301-330 de tr() - verificar .po
- [ ] T21-12: Batch 331-360 de tr() - verificar .po
- [ ] T21-13: Batch 361-390 de tr() - verificar .po
- [ ] T21-14: Batch 391-420 de tr() - verificar .po
- [ ] T21-15: Batch 421-450 de tr() - verificar .po
- [ ] T21-16: Batch 451-480 de tr() - verificar .po
- [ ] T21-17: Batch 481-510 de tr() - verificar .po
- [ ] T21-18: Batch 511-540 de tr() - verificar .po
- [ ] T21-19: Batch 541-570 de tr() - verificar .po
- [ ] T21-20: Batch 571-600 de tr() - verificar .po
- [ ] T21-21: Batch 601-630 de tr() - verificar .po
- [ ] T21-22: Batch 631-660 de tr() - verificar .po
- [ ] T21-23: Batch 661-690 de tr() - verificar .po
- [ ] T21-24: Batch 691-720 de tr() - verificar .po
- [ ] T21-25: Batch 721-750 de tr() - verificar .po
- [ ] T21-26: Batch 751-780 de tr() - verificar .po
- [ ] T21-27: Batch 781-810 de tr() - verificar .po
- [ ] T21-28: Batch 811-840 de tr() - verificar .po
- [ ] T21-29: Batch 841-870 de tr() - verificar .po
- [ ] T21-30: Batch 871-900 de tr() - verificar .po
- [ ] T21-31: Batch 901-930 de tr() - verificar .po
- [ ] T21-32: Batch 931-960 de tr() - verificar .po
- [ ] T21-33: Batch 961-990 de tr() - verificar .po
- [ ] T21-34: Batch 991-1020 de tr() - verificar .po
- [ ] T21-35: Batch 1021-1050 de tr() - verificar .po
- [ ] T21-36: Batch 1051-1080 de tr() - verificar .po
- [ ] T21-37: Batch 1081-1110 de tr() - verificar .po
- [ ] T21-38: Batch 1111-1140 de tr() - verificar .po
- [ ] T21-39: Batch 1141-1170 de tr() - verificar .po
- [ ] T21-40: Batch 1171-1200 de tr() - verificar .po
- [ ] T21-41: Batch 1201-1230 de tr() - verificar .po
- [ ] T21-42: Batch 1231-1260 de tr() - verificar .po
- [ ] T21-43: Batch 1261-1290 de tr() - verificar .po
- [ ] T21-44: Batch 1291-1320 de tr() - verificar .po
- [ ] T21-45: Batch 1321-1350 de tr() - verificar .po
- [ ] T21-46: Batch 1351-1380 de tr() - verificar .po
- [ ] T21-47: Batch 1381-1410 de tr() - verificar .po
- [ ] T21-48: Batch 1411-1440 de tr() - verificar .po
- [ ] T21-49: Batch 1441-1470 de tr() - verificar .po
- [ ] T21-50: Batch 1471-1500 de tr() - verificar .po
- [ ] T21-51: Batch 1501-1530 de tr() - verificar .po
- [ ] T21-52: Batch 1531-1560 de tr() - verificar .po
- [ ] T21-53: Batch 1561-1590 de tr() - verificar .po
- [ ] T21-54: Batch 1591-1620 de tr() - verificar .po
- [ ] T21-55: Batch 1621-1650 de tr() - verificar .po
- [ ] T21-56: Batch 1651-1680 de tr() - verificar .po
- [ ] T21-57: Batch 1681-1710 de tr() - verificar .po
- [ ] T21-58: Batch 1711-1740 de tr() - verificar .po
- [ ] T21-59: Batch 1741-1770 de tr() - verificar .po
- [ ] T21-60: Batch 1771-1800 de tr() - verificar .po
- [ ] T21-61: Batch 1801-1830 de tr() - verificar .po
- [ ] T21-62: Batch 1831-1860 de tr() - verificar .po
- [ ] T21-63: Batch 1861-1890 de tr() - verificar .po
- [ ] T21-64: Batch 1891-1920 de tr() - verificar .po
- [ ] T21-65: Batch 1921-1950 de tr() - verificar .po
- [ ] T21-66: Batch 1951-1980 de tr() - verificar .po
- [ ] T21-67: Batch 1981-2010 de tr() - verificar .po
- [ ] T21-68: Batch 2011-2040 de tr() - verificar .po
- [ ] T21-69: Batch 2041-2070 de tr() - verificar .po
- [ ] T21-70: Batch 2071-2100 de tr() - verificar .po
- [ ] T21-71: Batch 2101-2130 de tr() - verificar .po
- [ ] T21-72: Batch 2131-2160 de tr() - verificar .po
- [ ] T21-73: Batch 2161-2190 de tr() - verificar .po
- [ ] T21-74: Batch 2191-2220 de tr() - verificar .po
- [ ] T21-75: Batch 2221-2250 de tr() - verificar .po
- [ ] T21-76: Batch 2251-2280 de tr() - verificar .po
- [ ] T21-77: Batch 2281-2310 de tr() - verificar .po
- [ ] T21-78: Batch 2311-2340 de tr() - verificar .po
- [ ] T21-79: Batch 2341-2370 de tr() - verificar .po
- [ ] T21-80: Batch 2371-2400 de tr() - verificar .po
- [ ] T21-81: Batch 2401-2430 de tr() - verificar .po
- [ ] T21-82: Batch 2431-2460 de tr() - verificar .po
- [ ] T21-83: Batch 2461-2490 de tr() - verificar .po
- [ ] T21-84: Batch 2491-2520 de tr() - verificar .po
- [ ] T21-85: Batch 2521-2550 de tr() - verificar .po
- [ ] T21-86: Batch 2551-2580 de tr() - verificar .po
- [ ] T21-87: Batch 2581-2610 de tr() - verificar .po
- [ ] T21-88: Batch 2611-2640 de tr() - verificar .po
- [ ] T21-89: Batch 2641-2670 de tr() - verificar .po
- [ ] T21-90: Batch 2671-2700 de tr() - verificar .po
- [ ] T21-91: Batch 2701-2730 de tr() - verificar .po
- [ ] T21-92: Batch 2731-2760 de tr() - verificar .po
- [ ] T21-93: Batch 2761-2790 de tr() - verificar .po
- [ ] T21-94: Batch 2791-2820 de tr() - verificar .po
- [ ] T21-95: Batch 2821-2850 de tr() - verificar .po
- [ ] T21-96: Batch 2851-2872 de tr() - verificar .po
- [ ] T21-97: Batch 2881-2872 de tr() - verificar .po
- [ ] T21-98: Batch 2911-2872 de tr() - verificar .po
- [ ] T21-99: Batch 2941-2872 de tr() - verificar .po
- [ ] T21-100: Batch 2971-2872 de tr() - verificar .po

