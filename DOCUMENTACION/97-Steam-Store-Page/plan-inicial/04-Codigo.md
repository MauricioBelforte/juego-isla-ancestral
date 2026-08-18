**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 97: Steam / Store Page

## 1. Naturaleza del módulo

Este módulo NO produce scripts de GDScript: produce **contenido versionado** (textos, listas, guiones) y **especificaciones de producción** (assets, capturas, trailer). Los únicos "archivos ejecutables" involucrados son las herramientas de captura del propio juego (escenas del editor de Godot usadas por un operador humano) y la web de Steamworks (subida manual).

## 2. Archivos previstos

### 2.1 Plantillas versionadas (plan-actual del módulo)

| Archivo | Contenido |
|---------|-----------|
| `plantilla-descripcion.md` | Short description ES/EN + About completo por secciones + FAQ |
| `lista-capturas.md` | Shot list con escena, cámara, hora de luz y criterio de aprobación por captura |
| `guion-trailer.md` | Storyboard textual del trailer: tomas, duración, diálogos/textos en pantalla, música |
| `requisitos-sistema.md` | Tabla final de mínimos/recomendados con anotación de profiling |
| `keywords-tags.md` | Los 20 tags elegidos + keyword list completa + idiomas marcados |
| `assets-store.md` | Checklist de assets con dimensiones, rutas de export y estado (listo/por exportar) |

### 2.2 Assets finales (rutas de destino)

```
Assetos de export (fuera de Assets/ del proyecto, son entregables de marketing):
marketing/steam/
├── capsules/header-460x215.png
├── capsules/small-231x87.png
├── capsules/main-616x353.png
├── capsules/vertical-600x900.png
├── library/library-hero-3840x1240.png
├── library/library-header-616x353.png
├── library/library-capsule-600x900.png
├── library/logo-grande-570x110.png
├── page/background-1438x810.png
├── screenshots/01-playa-amancer.png ... 08-vista-aerea.png
└── trailer/trailer-principal.mov + trailer-principal.mp4 (H.264)
```

> ⚠️ Las dimensiones son de referencia vigente; se revalidan contra la documentación de Steamworks antes de exportar los finales (Steam puede cambiarlas).

## 3. Contenido-esqueleto (plantillas)

### 3.1 Plantilla de short description

```
[EN] Fleeing the noise of the world, you arrive at Aurora Island:
a voxel paradise of calm fields, friendly neighbors and ancient temples.
Farm, fish, mine and build your own cozy haven at your own pace.
[ES] Huyendo del ruido del mundo, llegas a la Isla Aurora: un paraíso voxel
de campos tranquilos, vecinos amistosos y templos ancestrales. Cultiva, pesca,
mina y construye tu refugio acogedor a tu propio ritmo.
(Caracteres máx. 300 por idioma — verificar en Steamworks.)
```

### 3.2 Plantilla del About (secciones)

```
## Tu refugio, tu ritmo   → 1 párrafo + 2-4 bullets (día/noche, sin presión)
## Cultiva tu vida        → agricultura M33 + pesca M34 + minería M35
## Construye tu hogar     → crafting M16 + construcción M17 + casa M18
## Una isla viva          → vecinos M19 + amistad M20 + diálogos M21
## Historias y misterios  → historias M22/M23 + templos M24 + ruinas M25 + islas M27
## Para ti                → accesibilidad M58 + controles M57 + subtítulos
## Añade a tu lista de deseos → CTA final (holding text hasta tarifa)
```

Cada sección mantiene el esquema: **título emocional + 1 párrafo + bullets de sistemas** (referencias a módulos del checklist global).

### 3.3 Checklist de assets de Steam (esqueleto)

```
[ ] Header capsule 460x215 (fondo + logo + personaje)
[ ] Small capsule 231x87 (recorte sin texto crítico)
[ ] Main capsule 616x353 (arte principal de listas y destacados)
[ ] Vertical capsule 600x900 (librería)
[ ] Library header 616x353 + hero 3840x1240 (safe 1430x1240) + logo 570x110
[ ] Fondo de página ~1438x810
[ ] Icono de app 32/64/128/256 px
[ ] 6-8 capturas 1920x1080 (shot list)
[ ] Trailer MP4 H.264 60-90 s
[ ] Verificación: todas las dimensiones contra docs vigentes de Steamworks
```

### 3.4 Esqueleto de requisitos

| Campo | Mínimo | Recomendado | Fuente de verdad |
|-------|--------|-------------|------------------|
| SO | Win10 64-bit | Win11 64-bit | M96 (plataformas) |
| CPU | i5/Ryzen5 4-6 núcleos | i5/Ryzen5 6+ núcleos | Profiling M62 |
| RAM | 8 GB | 16 GB | Profiling M62 |
| GPU | iGPU moderna/DX11 | GTX1060/RX580+ | Profiling M90 |
| Disco | 4 GB (ajustar) | 4 GB SSD | Build final (M143) |

### 3.5 Keywords-esqueleto

```
cozy, calm, relax, farming, farming sim, island, voxel, build, crafting,
fishing, mining, adventure, exploration, aurora island, life sim (no repetir
los 20 tags; verificar límite de campos en Steamworks)
```

## 4. Flujo de trabajo de implementación

1. Completar `plantilla-descripcion.md` (ES/EN) → aprobación del fundador.
2. Generar capturas con el build real (editor de Godot, cámara libre) según `lista-capturas.md`.
3. Grabar/editar trailer según `guion-trailer.md` (producción de medios).
4. Validar requisitos con profiling (M62/M90) en la máquina mínima.
5. Exportar assets siguiendo `assets-store.md` con dimensiones revalidadas.
6. Subir todo en Steamworks (página oculta F0 → coming soon F1).
7. Primer pase de tags a las 2 semanas post-publicación (F3) y correcciones.

## 5. Logs relacionados

- Logs de captura: `Logs/` del proyecto con NN (sesiones de regrabado en cada milestone M136).
- El módulo no genera logs de runtime: no hay código en ejecución.
- Cadena de firma: todo archivo de `plan-actual/` firmado por el último agente que lo modificó.

## 6. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice

- Documenté el módulo 97 completo (5 archivos en plan-inicial + espejo en plan-actual): requerimientos funcionales RF1–RF10 y no funcionales RN1–RN8, análisis del dominio de store pages cozy (SEO de tags/keywords, capturas, trailer, wishlists, price tiers), diseño de la página por fases (oculta → coming soon → launch), shot list de 8 capturas, guion del trailer, requisitos mínimos/recomendados, blueprint de assets de Steam y plantillas de contenido.
- Verifiqué contra CHECKLIST-GLOBAL.md que el módulo 97 existe (depende de 96, Alta, complejidad 3) y referencié M86/M136/M143 sin tocar esos módulos.
- El contenido corrige el stack real del proyecto: Godot 4.x + Voxel Tools + GDScript (no Unity/C#).
- Documenté explícitamente la advertencia de que Steam puede cambiar sus requisitos de contenido y deben revalidarse contra Steamworks al publicar.

### Lo que NO pude hacer (honestidad obligatoria)

- El **precio final** ($19.99 sugerido) requiere decisión del fundador (RF6): no puedo fijarlo.
- El **nombre comercial** final del juego (ej. "Isla Ancestral" vs. nombre de Steam) requiere decisión del fundador: toda la página depende del naming definitivo.
- El **trailer** y los **assets gráficos** (capsules, hero) no existen aún: son entregables de producción delegados, no puedo generarlos como texto.
- La **fecha de Coming Soon** depende del hito de marketing de M136, que no está implementado: dejé el roadmap por fases sin fechas absolutas.
- No pude ejecutar profiling de requisitos (M62/M90): los valores de la tabla son estimaciones de diseño que deben validarse con la máquina mínima real.

### Recomendaciones para el próximo agente

- Al implementar: verificar primero la cuenta de Steamworks y el nombre comercial aprobado (M143); sin eso, la página no puede crearse.
- Revalidar TODAS las dimensiones y límites (300 caracteres, 20 tags, formatos de video) contra la documentación vigente de Steamworks: Steam los modifica con el tiempo y este documento usa valores de referencia.
- Generar las capturas con el build real más reciente y rehacerlas en cada milestone de M136.
- El primer pase de tags a las 2 semanas de publicación es obligatorio para corregir categorización sin penalizar el descubrimiento.
- Si el precio final difiere de $19.99, revisar el texto del CTA y los descuentos de lanzamiento en F2/F3.
- Los textos finales deben pasar por revisión humana del fundador (política M86): lo aquí documentado es plantilla, no publicación directa.