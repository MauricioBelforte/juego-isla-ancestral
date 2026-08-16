**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 03-Diseno.md — Módulo 131: Créditos

## 1. Arquitectura

```
M78 (Legal) ──► Validador de licencias
M87 (Localización) ──► Traductor de textos
M90 (Config Gráfica) ──► Configuración de fuente y tamaño
M91 (Config Audio) ──► Volumen y velocidad de animación
                       │
                       ▼
                       CreditsDirector (autoload, singleton)
                       │
               ──► UI CreditsCanvas (CanvasLayer)
                       │
               ──► CreditsText (RichTextLabel, desplazamiento)
                       │
               ──► CreditsSearch (TextEdit, filtro en tiempo real)
                       │
               ──► CreditsNavigator (controles de navegación)
                       │
                       ▼
                       World Persistence (guardado último idioma)
```

## 2. Flujo de operación

1. **Inicialización:** CreditsDirector carga todos los datos de créditos (equipos, contribuyentes, assets)
2. **Idioma:** Si configuración M91/M87 indica idioma diferente, se cargan textos traducidos
3. **Visualización:** UI CreditsCanvas muestra la lista comenzando desde el inicio
4. **Navegación:** Usuario puede:
   - Desplazarse manualmente con teclas arriba/abajo
   - Buscar por nombre, rol o equipo (filtro en tiempo real)
   - Detener/continuar animación automática
   - Cambiar tamaño de texto (S/M/L)
   - Alternar modo alto contraste
5. **Finalización:** Después de tiempo máximo (5 min) o cuando usuario detiene, cerrar escena

## 3. Categorías de créditos

| Categoría | Contenido |
|---|---|
| Equipos Principales | Desarrollo, Arte, Sonido, QA, Comunidad |
| Colaboradores Especiales | Testers, traductores, diseñadores de UI/UX |
| Assets de Terceros | Bibliotecas, texturas, modelos, sonido con licencia |
| Reconocimientos | Fundación, patrocinadores, comunidad activa |

## 4. Configuración de interfaz (M91/M87/M90)

- **Fuente:** Nunito (principal), Fredoka One (títulos) - definidos en M90
- **Tamaño inicial:** 16px, ajustable S(12px) - M(16px) - L(20px)
- **Velocidad animación:** Normal, Lenta, Rápida - configurable en M91
- **Alto contraste:** Toggle que invierte colores para lectura mejorar

## 5. QA

- Test M115: todos los equipos principales listados y visibles
- Test de búsqueda: filtro por nombre, rol y equipo funciona correctamente
- Test de idioma: conmutación español/inglés cambia todos los textos
- Test de accesibilidad: tamaño de texto ajustable y modo contraste alternan
- Test de tiempo: duración máxima 5 minutos con animación continua
- Test de copyright: año actual y leyenda displayados correctamente