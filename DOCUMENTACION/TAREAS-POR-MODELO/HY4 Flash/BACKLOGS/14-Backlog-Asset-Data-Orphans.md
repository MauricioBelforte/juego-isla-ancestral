# 14-Backlog: Asset + Data orphan detection

> Creada por: agnes-3-flash - 2026-11-17 07:55
> 1779 assets, 1012 data files. Verificar que esten referenciados.
> Metodo: grep -rlf "NOMBRE_ARCHIVO" game/ DOCUMENTACION/ | si 0 hits = orphan
> Batches de 20.

## Tareas

- [x] T14-01: Batch 1-20 - verificar referencias — OK 20/20 referenciados
- [x] T14-02: Batch 21-40 - verificar referencias — OK 20/20 referenciados
- [x] T14-03: Batch 41-60 - verificar referencias — OK 20/20 referenciados
- [x] T14-04: Batch 61-80 - verificar referencias — 18/20 OK · 2 huerfanos: ico_item_obj_cam_007.png.import, ico_item_obj_cam_008.png.import
- [x] T14-05: Batch 81-100 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_coc_003.png.import, ico_item_obj_coc_004.png.import, ico_item_obj_coc_005.png.import, ico_item_obj_coc_006.png.import
- [x] T14-06: Batch 101-120 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_coc_013.png.import, ico_item_obj_coc_014.png.import, ico_item_obj_coc_015.png.import, ico_item_obj_coc_016.png.import
- [x] T14-07: Batch 121-140 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_con_003.png.import, ico_item_obj_con_004.png.import, ico_item_obj_con_005.png.import, ico_item_obj_con_006.png.import
- [x] T14-08: Batch 141-160 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_con_013.png.import, ico_item_obj_con_014.png.import, ico_item_obj_con_015.png.import, ico_item_obj_cua_001.png.import
- [x] T14-09: Batch 161-180 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_cua_008.png.import, ico_item_obj_cua_009.png.import, ico_item_obj_cua_010.png.import, ico_item_obj_esp_001.png.import
- [x] T14-10: Batch 181-200 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_est_003.png.import, ico_item_obj_est_004.png.import, ico_item_obj_est_005.png.import, ico_item_obj_est_006.png.import
- [x] T14-11: Batch 201-220 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_eve_003.png.import, ico_item_obj_eve_004.png.import, ico_item_obj_eve_005.png.import, ico_item_obj_ext_001.png.import
- [x] T14-12: Batch 221-240 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_ext_008.png.import, ico_item_obj_ext_009.png.import, ico_item_obj_ext_010.png.import, ico_item_obj_ext_011.png.import
- [x] T14-13: Batch 241-260 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_ext_018.png.import, ico_item_obj_ext_019.png.import, ico_item_obj_ext_020.png.import, ico_item_obj_her_001.png.import
- [x] T14-14: Batch 261-280 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_her_008.png.import, ico_item_obj_her_009.png.import, ico_item_obj_her_010.png.import, ico_item_obj_her_011.png.import
- [x] T14-15: Batch 281-300 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_her_018.png.import, ico_item_obj_her_019.png.import, ico_item_obj_her_020.png.import, ico_item_obj_ite_001.png.import
- [x] T14-16: Batch 301-320 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_ite_008.png.import, ico_item_obj_ite_009.png.import, ico_item_obj_ite_010.png.import, ico_item_obj_ite_011.png.import
- [x] T14-17: Batch 321-340 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_ite_022.png.import, ico_item_obj_ite_023.png.import, ico_item_obj_ite_024.png.import, ico_item_obj_ite_025.png.import
- [x] T14-18: Batch 341-360 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_ite_032.png.import, ico_item_obj_ite_033.png.import, ico_item_obj_ite_034.png.import, ico_item_obj_ite_035.png.import
- [x] T14-19: Batch 361-380 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_ite_052.png.import, ico_item_obj_ite_053.png.import, ico_item_obj_ite_054.png.import, ico_item_obj_ite_055.png.import
- [x] T14-20: Batch 381-400 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_luz_005.png.import, ico_item_obj_luz_006.png.import, ico_item_obj_luz_007.png.import, ico_item_obj_luz_008.png.import
- [x] T14-21: Batch 401-420 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_luz_015.png.import, ico_item_obj_mes_001.png.import, ico_item_obj_mes_002.png.import, ico_item_obj_mes_003.png.import
- [x] T14-22: Batch 421-440 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_mes_010.png.import, ico_item_obj_nat_001.png.import, ico_item_obj_nat_002.png.import, ico_item_obj_nat_003.png.import
- [x] T14-23: Batch 441-460 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_nat_010.png.import, ico_item_obj_nat_011.png.import, ico_item_obj_nat_012.png.import, ico_item_obj_nat_013.png.import
- [x] T14-24: Batch 461-480 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_nat_020.png.import, ico_item_obj_nat_021.png.import, ico_item_obj_nat_022.png.import, ico_item_obj_nat_023.png.import
- [x] T14-25: Batch 481-500 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_pla_002.png.import, ico_item_obj_pla_003.png.import, ico_item_obj_pla_004.png.import, ico_item_obj_pla_005.png.import
- [x] T14-26: Batch 501-520 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_pla_012.png.import, ico_item_obj_pla_013.png.import, ico_item_obj_pla_014.png.import, ico_item_obj_rel_001.png.import
- [x] T14-27: Batch 521-540 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_rop_004.png.import, ico_item_obj_rop_005.png.import, ico_item_obj_sec_001.png.import, ico_item_obj_sec_002.png.import
- [x] T14-28: Batch 541-560 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_sil_004.png.import, ico_item_obj_sil_005.png.import, ico_item_obj_sil_006.png.import, ico_item_obj_sil_007.png.import
- [x] T14-29: Batch 561-580 - verificar referencias — 14/20 OK · 6 huerfanos: ico_item_obj_tal_004.png.import, ico_item_obj_tal_005.png.import, ico_item_obj_tal_006.png.import, ico_item_obj_tal_007.png.import
- [x] T14-30: Batch 581-600 - verificar referencias — 14/20 OK · 6 huerfanos: ico_mud.png.import, ico_pergamino_rec_tela_lino.png.import, ico_piedra_caliza.png.import, ico_planks.png.import
- [x] T14-31: Batch 601-620 - verificar referencias — OK 20/20 referenciados
- [x] T14-32: Batch 621-640 - verificar referencias — OK 20/20 referenciados
- [x] T14-33: Batch 641-660 - verificar referencias — OK 20/20 referenciados
- [x] T14-34: Batch 661-680 - verificar referencias — OK 20/20 referenciados
- [x] T14-35: Batch 681-700 - verificar referencias — OK 20/20 referenciados
- [x] T14-36: Batch 701-720 - verificar referencias — OK 20/20 referenciados
- [x] T14-37: Batch 721-740 - verificar referencias — OK 20/20 referenciados
- [x] T14-38: Batch 741-760 - verificar referencias — OK 20/20 referenciados
- [x] T14-39: Batch 761-780 - verificar referencias — OK 20/20 referenciados
- [x] T14-40: Batch 781-800 - verificar referencias — OK 20/20 referenciados
- [x] T14-41: Batch 801-820 - verificar referencias — OK 20/20 referenciados
- [x] T14-42: Batch 821-840 - verificar referencias — OK 20/20 referenciados
- [x] T14-43: Batch 841-860 - verificar referencias — OK 20/20 referenciados
- [x] T14-44: Batch 861-880 - verificar referencias — OK 20/20 referenciados
- [x] T14-45: Batch 881-900 - verificar referencias — OK 20/20 referenciados
- [x] T14-46: Batch 901-920 - verificar referencias — OK 20/20 referenciados
- [x] T14-47: Batch 921-940 - verificar referencias — OK 20/20 referenciados
- [x] T14-48: Batch 941-960 - verificar referencias — OK 20/20 referenciados
- [x] T14-49: Batch 961-980 - verificar referencias — OK 20/20 referenciados
- [x] T14-50: Batch 981-1000 - verificar referencias — OK 20/20 referenciados
- [x] T14-51: Batch 1001-1020 - verificar referencias — OK 20/20 referenciados
- [x] T14-52: Batch 1021-1040 - verificar referencias — OK 20/20 referenciados
- [x] T14-53: Batch 1041-1060 - verificar referencias — OK 20/20 referenciados
- [x] T14-54: Batch 1061-1080 - verificar referencias — OK 20/20 referenciados
- [x] T14-55: Batch 1081-1100 - verificar referencias — OK 20/20 referenciados
- [x] T14-56: Batch 1101-1120 - verificar referencias — OK 20/20 referenciados
- [x] T14-57: Batch 1121-1140 - verificar referencias — OK 20/20 referenciados
- [x] T14-58: Batch 1141-1160 - verificar referencias — OK 20/20 referenciados
- [x] T14-59: Batch 1161-1180 - verificar referencias — OK 20/20 referenciados
- [x] T14-60: Batch 1181-1200 - verificar referencias — OK 20/20 referenciados
- [x] T14-61: Batch 1201-1220 - verificar referencias — OK 20/20 referenciados
- [x] T14-62: Batch 1221-1240 - verificar referencias — OK 20/20 referenciados
- [x] T14-63: Batch 1241-1260 - verificar referencias — OK 20/20 referenciados
- [x] T14-64: Batch 1261-1280 - verificar referencias — OK 20/20 referenciados
- [x] T14-65: Batch 1281-1300 - verificar referencias — OK 20/20 referenciados
- [x] T14-66: Batch 1301-1320 - verificar referencias — OK 20/20 referenciados
- [x] T14-67: Batch 1321-1340 - verificar referencias — OK 20/20 referenciados
- [x] T14-68: Batch 1341-1360 - verificar referencias — OK 20/20 referenciados
- [x] T14-69: Batch 1361-1380 - verificar referencias — OK 20/20 referenciados
- [x] T14-70: Batch 1381-1400 - verificar referencias — OK 20/20 referenciados
- [x] T14-71: Batch 1401-1420 - verificar referencias — OK 20/20 referenciados
- [x] T14-72: Batch 1421-1440 - verificar referencias — OK 20/20 referenciados
- [x] T14-73: Batch 1441-1460 - verificar referencias — OK 20/20 referenciados
- [x] T14-74: Batch 1461-1480 - verificar referencias — OK 20/20 referenciados
- [x] T14-75: Batch 1481-1500 - verificar referencias — OK 20/20 referenciados
- [x] T14-76: Batch 1501-1520 - verificar referencias — OK 20/20 referenciados
- [x] T14-77: Batch 1521-1540 - verificar referencias — OK 20/20 referenciados
- [x] T14-78: Batch 1541-1560 - verificar referencias — OK 20/20 referenciados
- [x] T14-79: Batch 1561-1580 - verificar referencias — OK 20/20 referenciados
- [x] T14-80: Batch 1581-1600 - verificar referencias — 19/20 OK · 1 huerfanos: conejo_cozy.blend1
- [x] T14-81: Batch 1601-1620 - verificar referencias — OK 20/20 referenciados
- [x] T14-82: Batch 1621-1640 - verificar referencias — OK 20/20 referenciados
- [x] T14-83: Batch 1641-1660 - verificar referencias — OK 20/20 referenciados
- [x] T14-84: Batch 1661-1680 - verificar referencias — OK 20/20 referenciados
- [x] T14-85: Batch 1681-1700 - verificar referencias — OK 20/20 referenciados
- [x] T14-86: Batch 1701-1720 - verificar referencias — OK 20/20 referenciados
- [x] T14-87: Batch 1721-1740 - verificar referencias — OK 20/20 referenciados
- [x] T14-88: Batch 1741-1760 - verificar referencias — OK 20/20 referenciados
- [x] T14-89: Batch 1761-1780 - verificar referencias — OK 20/20 referenciados
- [x] T14-90: Batch 1781-1800 - verificar referencias — OK 20/20 referenciados
- [x] T14-91: Batch 1801-1820 - verificar referencias — OK 20/20 referenciados
- [x] T14-92: Batch 1821-1840 - verificar referencias — OK 20/20 referenciados
- [x] T14-93: Batch 1841-1860 - verificar referencias — OK 20/20 referenciados
- [x] T14-94: Batch 1861-1880 - verificar referencias — OK 20/20 referenciados
- [x] T14-95: Batch 1881-1900 - verificar referencias — OK 20/20 referenciados
- [x] T14-96: Batch 1901-1920 - verificar referencias — OK 20/20 referenciados
- [x] T14-97: Batch 1921-1940 - verificar referencias — OK 20/20 referenciados
- [x] T14-98: Batch 1941-1960 - verificar referencias — OK 20/20 referenciados
- [x] T14-99: Batch 1961-1980 - verificar referencias — OK 20/20 referenciados
- [x] T14-100: Batch 1981-2000 - verificar referencias — OK 20/20 referenciados
- [x] T14-101: Batch 2001-2020 - verificar referencias — OK 20/20 referenciados
- [x] T14-102: Batch 2021-2040 - verificar referencias — OK 20/20 referenciados
- [x] T14-103: Batch 2041-2060 - verificar referencias — OK 20/20 referenciados
- [x] T14-104: Batch 2061-2080 - verificar referencias — OK 20/20 referenciados
- [x] T14-105: Batch 2081-2100 - verificar referencias — OK 20/20 referenciados
- [x] T14-106: Batch 2101-2120 - verificar referencias — OK 20/20 referenciados
- [x] T14-107: Batch 2121-2140 - verificar referencias — OK 20/20 referenciados
- [x] T14-108: Batch 2141-2160 - verificar referencias — OK 20/20 referenciados
- [x] T14-109: Batch 2161-2180 - verificar referencias — OK 20/20 referenciados
- [x] T14-110: Batch 2181-2200 - verificar referencias — OK 20/20 referenciados
- [x] T14-111: Batch 2201-2220 - verificar referencias — OK 20/20 referenciados
- [x] T14-112: Batch 2221-2240 - verificar referencias — OK 20/20 referenciados
- [x] T14-113: Batch 2241-2260 - verificar referencias — OK 20/20 referenciados
- [x] T14-114: Batch 2261-2280 - verificar referencias — OK 20/20 referenciados
- [x] T14-115: Batch 2281-2300 - verificar referencias — OK 20/20 referenciados
- [x] T14-116: Batch 2301-2320 - verificar referencias — OK 20/20 referenciados
- [x] T14-117: Batch 2321-2340 - verificar referencias — OK 20/20 referenciados
- [x] T14-118: Batch 2341-2360 - verificar referencias — OK 20/20 referenciados
- [x] T14-119: Batch 2361-2380 - verificar referencias — OK 20/20 referenciados
- [x] T14-120: Batch 2381-2400 - verificar referencias — OK 20/20 referenciados
- [x] T14-121: Batch 2401-2420 - verificar referencias — OK 20/20 referenciados
- [x] T14-122: Batch 2421-2440 - verificar referencias — OK 20/20 referenciados
- [x] T14-123: Batch 2441-2460 - verificar referencias — OK 20/20 referenciados
- [x] T14-124: Batch 2461-2480 - verificar referencias — OK 20/20 referenciados
- [x] T14-125: Batch 2481-2500 - verificar referencias — OK 20/20 referenciados
- [x] T14-126: Batch 2501-2520 - verificar referencias — OK 20/20 referenciados
- [x] T14-127: Batch 2521-2540 - verificar referencias — OK 20/20 referenciados
- [x] T14-128: Batch 2541-2560 - verificar referencias — OK 20/20 referenciados
- [x] T14-129: Batch 2561-2580 - verificar referencias — OK 20/20 referenciados
- [x] T14-130: Batch 2581-2600 - verificar referencias — OK 20/20 referenciados
- [x] T14-131: Batch 2601-2620 - verificar referencias — OK 20/20 referenciados
- [x] T14-132: Batch 2621-2640 - verificar referencias — OK 20/20 referenciados
- [x] T14-133: Batch 2641-2660 - verificar referencias — OK 20/20 referenciados
- [x] T14-134: Batch 2661-2680 - verificar referencias — OK 20/20 referenciados
- [x] T14-135: Batch 2681-2700 - verificar referencias — OK 20/20 referenciados
- [x] T14-136: Batch 2701-2720 - verificar referencias — OK 20/20 referenciados
- [x] T14-137: Batch 2721-2740 - verificar referencias — OK 20/20 referenciados
- [x] T14-138: Batch 2741-2760 - verificar referencias — OK 20/20 referenciados
- [x] T14-139: Batch 2761-2780 - verificar referencias — OK 20/20 referenciados
- [x] T14-140: Batch 2781-2791 - verificar referencias — OK 11/11 referenciados






## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:4x UTC)

Universo: 1779 assets + 1012 data = **2791 archivos**, 140 batches. Se construyó un índice de nombres de archivo citados como texto en `game/` y `DOCUMENTACION/` (excluidos binarios) y se marcó como huérfano todo archivo cuyo `nombre.ext` no aparece en ese índice. **Solo detección: no se borró ni movió nada.**

| Resultado | Archivos |
|---|---|
| Referenciados | 2632 |
| Huérfanos detectados | 159 |

Extensiones de huérfanos: .import=158; .blend1=1.

Batches con huérfanos: 28 de 140.

Primeros 40 huérfanos:

- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_cam_007.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_cam_008.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_coc_003.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_coc_004.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_coc_005.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_coc_006.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_coc_007.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_coc_008.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_coc_013.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_coc_014.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_coc_015.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_coc_016.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_coc_017.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_coc_018.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_con_003.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_con_004.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_con_005.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_con_006.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_con_007.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_con_008.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_con_013.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_con_014.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_con_015.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_cua_001.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_cua_002.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_cua_003.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_cua_008.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_cua_009.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_cua_010.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_esp_001.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_esp_002.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_esp_003.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_est_003.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_est_004.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_est_005.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_est_006.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_est_007.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_est_008.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_eve_003.png.import
- game/isla-ancestral/assets/2d/items_m159/ico_item_obj_eve_004.png.import

**Firma:** agnes-3-flash (directora) - 2026-11-17 07:55
**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:4x
