**Modelo:** MiniMax-M3
**Plataforma:** WorkBuddy AI

# Log 196 — Verificación multi-ángulo obligatoria (E-13, directiva del usuario)

**Fecha:** 2026-08-28 15:53:00

## Descripción breve
El usuario dejó explícita la regla: **"si es necesario girá la cámara y sacá captura, pero no deben flotar los objetos en la base"**. Lo documenté en `09-GUIA-BLENDER.md` como E-13, agregué una nueva sección §6.2bis con el procedimiento, y creé la herramienta `capturar_angulos.py` que orbita la cámara alrededor del asset y genera N capturas equi-espaciadas (default 4, recomendado 6-8). Sin todas las capturas orbitales, el ítem del checklist **no** se aprueba.

## Archivos creados
- `tools/mcp/blender-mcp/scripts-reutilizables/capturar_angulos.py` — nueva herramienta. Crea una cámara orbital `CAM_Orbital` en la escena, calcula el centro y radio del grupo `SM_*` indicado, y renderiza N capturas a igual distancia y altura, con azimuths `i*360/N` grados. Los archivos salen con sufijo `*_az000.png`, `*_az090.png`, etc. Uso:
  ```
  python capturar_angulos.py SM_Coco_ capturas/cap_15_2026-08-28_15-52-00_nido-orbita.png 6
  ```

## Archivos modificados
- `DOCUMENTACION/09-GUIA-BLENDER.md`:
  - **E-13** (nuevo): *"Una sola captura frontal puede ocultar flotación (revisar desde varios ángulos)"*. Síntoma: el nido estaba aprobado numéricamente pero al rotar la cámara default se vio el problema. Solución: captura orbital + revisar TODAS.
  - **§6.2bis** (nuevo): procedimiento obligatorio de captura multi-ángulo. 6 capturas equi-espaciadas, todas requeridas, sin TODAS el ítem no se aprueba.
  - **§4** del checklist: ítem nuevo *"Verificación multi-ángulo (E-13, directiva del usuario 2026-08-28)"*.
  - **§1** tabla: nueva fila para `capturar_angulos.py`.
  - **§7.4** regla 7: *"Verificación multi-ángulo obligatoria"*.
  - Firma actualizada.

## Verificación
Probé la herramienta sobre el nido de cocos ya corregido. Las 4 capturas (`az000`, `az090`, `az180`, `az270`) muestran el asset apoyado en la base, sin huecos de luz ni aire. La de atrás (`az180`) en particular confirma que las hojas del anillo perimetral y el disco marrón están completamente debajo de los cocos, sin puntos de contacto fallidos.

## Estado del módulo
✅ Herramienta lista · documentación sincronizada · regla del usuario formalizada
