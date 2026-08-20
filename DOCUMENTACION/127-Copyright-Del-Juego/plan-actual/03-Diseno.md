**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 03-Diseno.md — Módulo 127: Copyright del Juego

## 1. Estructura del módulo

```
Copyright del Juego (registro de copyright)
├── Copyright automatico
│   ├── Código (automatico en creacion)
│   ├── Arte (automatico en creacion)
│   ├── Música (automatico en creacion)
│   ├── Narrativa (automatico en creacion)
│   └── Logos (automatico en creacion)
├── Registro formal (opcional)
│   ├── Registro de código (USCO: Source Code)
│   ├── Registro de arte (USCO: Visual Arts)
│   ├── Registro de música (USCO: Sound Recording)
│   ├── Registro de narrativa (USCO: Literary Work)
│   └── Registro de logos (USCO: Visual Arts)
└── Evidencia de autoría
    ├── Git logs (commits, autores, fechas)
    ├── Timestamps (archivos, commits)
    ├── Borradores (sketches, iteraciones)
    └── Metadata (EXIF, IPTC, tags)
```

## 2. Sistema de registro de copyright

**Archivo: legal/copyright_register.md**

**Estructura:**
```markdown
# Registro de Copyright - Isla Ancestral

## 1. Copyright Automatico
- Código: ✅ Copyright automatico en creacion
- Arte: ✅ Copyright automatico en creacion
- Música: ✅ Copyright automatico en creacion
- Narrativa: ✅ Copyright automatico en creacion
- Logos: ✅ Copyright automatico en creacion

## 2. Registro Formal (Opcional)
- Código: ⏳ Registro USCO: Source Code (USD 35-85)
- Arte: ⏳ Registro USCO: Visual Arts (USD 35-85)
- Música: ⏳ Registro USCO: Sound Recording (USD 35-85)
- Narrativa: ⏳ Registro USCO: Literary Work (USD 35-85)
- Logos: ⏳ Registro USCO: Visual Arts (USD 35-85)

## 3. Evidencia de Autoría
- Git logs: ✅ Commits con autoría
- Timestamps: ✅ Timestamps de archivos y commits
- Borradores: ✅ Borradores de arte, música, narrativa
- Metadata: ✅ Metadata de archivos y proyectos
```

## 3. Pruebas de copyright

**Pruebas manuales:**
- Probar que git logs muestren autoría correcta
- Probar que timestamps sean consistentes
- Probar que borradores estén accesibles
- Probar que metadata esté presente

**Pruebas automáticas:**
- Tests de verificación de git logs
- Tests de verificación de timestamps
- Tests de verificación de metadata
