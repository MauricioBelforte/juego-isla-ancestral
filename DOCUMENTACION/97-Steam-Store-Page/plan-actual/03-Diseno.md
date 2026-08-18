**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 97: Steam / Store Page

## 1. Arquitectura del módulo

El módulo 97 NO es código de runtime: es un paquete de **contenido y especificaciones** versionado en Markdown, más una **lista de producción** de assets. Su estructura interna:

```
DOCUMENTACION/97-Steam-Store-Page/
├── plan-inicial/          ← Este diseño (original, inmutable)
└── plan-actual/           ← Espejo donde vive la evolución (plantillas completadas)
    ├── plantilla-descripcion.md     ← Short description + About finales (EN/ES)
    ├── lista-capturas.md            ← Shot list con referencias
    ├── guion-trailer.md             ← Storyboard en texto del trailer 60-90 s
    ├── requisitos-sistema.md        ← Tabla final mínimos/recomendados
    ├── keywords-tags.md             ← Los 20 tags + keyword list completa
    └── assets-store.md              ← Checklist con rutas de los archivos finales
```

## 2. Estructura de la página (secciones de texto)

### 2.1 Short description (máx. 300 caracteres)

Ejemplo-esqueleto (EN):

> Fleeing the noise of the world, you arrive at Aurora Island: a voxel paradise of calm fields, friendly neighbors and ancient temples. Farm, fish, mine and build your own cozy haven at your own pace.

Versión ES:

> Huyendo del ruido del mundo, llegas a la Isla Aurora: un paraíso voxel de campos tranquilos, vecinos amistosos y templos ancestrales. Cultiva, pesca, mina y construye tu refugio acogedor a tu propio ritmo.

Regla de oro: mencionar **fantasía + 3 verbos de gameplay + promesa de ritmo propio**.

### 2.2 Descripción larga (About): secciones

1. **Gancho (hook)**: 2–3 líneas enmarcando la llegada a la isla Aurora (narrativa M22).
2. **Tu refugio, tu ritmo**: filosofía cozy, sin presión, día y noche opcionales (M29–M31).
3. **Cultiva tu vida**: agricultura (M33), pesca (M34), minería (M35), crafting (M16), construcción de tu casa (M17/M18).
4. **Una isla viva**: vecinos y amistad (M19–M21), historias (M22–M23), museo y colecciones (M37).
5. **Misterios ancestrales**: templos y ruinas de las islas (M24–M26, M27), viajes entre islas (M28).
6. **Para ti**: accesibilidad (M58), control completo con teclado/mando (M57), subtítulos.
7. **Cierre (CTA)**: "Añade Isla Ancestral a tu lista de deseos" + wishlist button.

Cada sección: máximo 1 párrafo + 2–4 bullets. Sin listas kilométricas: el jugador cozy escanea, no lee.

### 2.3 FAQ breve (opcional)

- ¿Hay multijugador? No: experiencia singleplayer por diseño.
- ¿Tiene final? Historia principal (M22) completable; el mundo sigue después.
- ¿Duración? 20–40 horas según ritmo (estimado de diseño).
- ¿Controles? Teclado y mando (M57).

## 3. Imágenes a generar (shot list)

### 3.1 Capturas de pantalla (6–8 para subir, 10 máx. permitidas)

| # | Escena | Sistema destacado | Momento de luz |
|---|--------|-------------------|----------------|
| 1 | Playa de Aurora al amanecer con personaje | Primera impresión de la isla | Amanecer dorado |
| 2 | Huerto con cultivos listos | Agricultura (M33) | Tarde |
| 3 | Orilla del río pescando | Pesca (M34) | Mañana |
| 4 | Entrada de mina con picos | Minería (M35) | Interior cálido |
| 5 | Taller de crafting + casa construida | Crafting/Construcción (M16/M17) | Atardecer |
| 6 | Plaza del pueblo con 2–3 vecinos | Amistad/diálogos (M19–M21) | Mediodía |
| 7 | Templo en ruinas con puzzle | Misterio/templos (M24) | Noche con antorchas |
| 8 | Vista aérea de la isla (cámara alta) | Mundo voxel completo | Golden hour |

Reglas de producción: 1920x1080, render real del juego, UI limpia, sin debug, encuadres con personaje visible, varias horas de luz para mostrar la paleta.

### 3.2 Assets gráficos de tienda (dimensiones de referencia)

| Asset | Dimensiones (referencia) | Uso |
|-------|--------------------------|-----|
| Header capsule | 460x215 | Página principal de la tienda |
| Small capsule | 231x87 | Librería/menú |
| Large/Main capsule | 616x353 | Destacados |
| Vertical capsule | 600x900 | Librería vertical |
| Library header | 616x353 | Librería |
| Library hero | 3840x1240 (safe 1430x1240) | Fondo de librería |
| Logo | ~570x110 (transparente) | Sobre el library hero |
| Página de fondo | ~1438x810 | Cabecera de la página del juego |
| Ícono de la aplicación | 32–256 px (varios tamaños) | Escritorio/librería |

> ⚠️ Steam puede actualizar estas dimensiones: verificar siempre en la documentación vigente de Steamworks antes de exportar los assets finales (RN6).

Estilo: arte cozy voxel con paleta cálida (dorados, verdes, turquesas), tipografías del juego (M88), sin texture de bajo contraste, logo legible a tamaño pequeño.

## 4. Trailer (guion)

Estructura de 60–90 s en 3 actos:

1. **Hook (0–8 s)**: despertar/desembarco en la isla, amanecer, personaje en plano medio. Texto corto opcional ("Aurora Island awaits").
2. **Sistemas (8–55 s)**: montaje de 6 tomas (cultivo → pesca → minería → crafting → pueblo → templo) con transiciones suaves, ritmo tranquilo, música cozy con nombre correctamente licenciado (M41/M44).
3. **Cierre (55–90 s)**: logo del juego, fecha/Coming Soon, texto "Add to your Wishlist".

Especificaciones técnicas: MP4 H.264, 1920x1080 a 30 fps (o nativa del juego), audio estéreo, subtítulos opcionales EN/ES (M58), peso objetivo < 1 GB para reproducción fluida.

## 5. Requisitos de sistema (estructura)

| Campo | Mínimo | Recomendado |
|-------|--------|-------------|
| SO | Windows 10 (64-bit) | Windows 11 (64-bit) |
| Procesador | Intel i5 / AMD Ryzen 5 (4–6 núcleos) | Intel i5 / AMD Ryzen 5 (6+ núcleos, recientes) |
| Memoria | 8 GB RAM | 16 GB RAM |
| GPU | iGPU moderna o dedicada básica (DX11) | GTX 1060 / RX 580 o superior |
| DirectX | 11 | 11/12 |
| Red | No requerida (singleplayer) | No requerida |
| Disco | 4 GB (ajustar a build final) | 4 GB (SSD recomendado) |

Valores a validar con profiling real (M62/M90) sobre la máquina mínima elegida antes de publicar; nunca copiar de otro juego.

## 6. Artwork y marcas

- Todos los assets usan la identidad visual del juego (paleta, tipografía M88, logo aprobado).
- Nada de marcas registradas de terceros (Steam, Stardew, etc.) en capturas, trailer o textos.
- Revisión legal M78 antes de publicar cápsulas con palabras/martillos del juego.
- Stock fonts del juego con licencia editable (M88).

## 7. Roadmap de la página

| Fase | Estado | Contenido mínimo | Gate de entrada |
|------|--------|------------------|-----------------|
| F0 | Página oculta con link directo | Paleta de textos ES/EN + 3 capturas + price tier aprobado | Cuenta Steamworks creada (M143), nombre comercial definido |
| F1 | Coming Soon público | Short/About finales + 6–8 capturas + trailer + requisitos + 20 tags + assets de tienda | Hito de marketing de M136 alcanzado |
| F2 | Pre-lanzamiento (última semana) | Trailer final, capturas del build gold, precios regionales, fecha definitiva, changelog | Build gold aprobado (M143) |
| F3 | Lanzamiento | Página en "Ya disponible", review de primer pase de tags 2 semanas post-launch, correcciones de feedback | Día 1 de M143 |

Mantenimiento continuo: en cada milestone de M136 se regraban destacados (capturas/trailer) para reflejar el estado real del juego; cada pase termina con CTA de wishlist reforzado.