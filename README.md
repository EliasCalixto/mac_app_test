# Sueldo Perú 🇵🇪

App iOS (SwiftUI) para calcular en segundos los tres montos que todo trabajador en planilla del Perú quiere saber:

- **Sueldo neto mensual** — descuenta AFP (Habitat, Integra, Prima, Profuturo) u ONP, y la retención de renta de 5ta categoría.
- **Gratificación** (julio y diciembre) — proporcional a los meses trabajados, con bonificación extraordinaria del 9% (EsSalud) o 6.75% (EPS).
- **CTS** (mayo y noviembre) — remuneración computable (sueldo + asignación + 1/6 de gratificación), por meses y días trabajados.

Incluye una pantalla de **Ajustes** para actualizar la UIT y la asignación familiar cuando cambien, sin necesidad de actualizar la app.

## Requisitos

- Xcode 16 o superior
- iOS 17.0+

## Cómo correr

1. Abrir `SueldoPeru.xcodeproj` en Xcode.
2. Seleccionar un simulador de iPhone.
3. `Cmd + R`.

No tiene dependencias externas ni backend: todo el cálculo es local.

## Estructura

```
SueldoPeru/
├── SueldoPeruApp.swift          # Entry point
├── Models/
│   └── CalculadoraPlanilla.swift # Toda la lógica de cálculo (pura, sin UI)
└── Views/
    ├── ContentView.swift        # TabView principal
    ├── SueldoNetoView.swift
    ├── GratificacionView.swift
    ├── CTSView.swift
    ├── AjustesView.swift
    └── Componentes.swift        # Filas, campos y tarjetas reutilizables
```

## Fórmulas (referenciales)

- **Pensión**: ONP 13% · AFP = 10% aporte + comisión sobre flujo + prima de seguro (~1.37%). Las comisiones cambian; se muestran como referencia en Ajustes.
- **Renta 5ta**: ingreso anual proyectado (14 sueldos) − 7 UIT, por tramos de 8/14/17/20/30%, retención repartida en 12 meses (aproximación; el método real de SUNAT varía por mes).
- **Gratificación**: sueldo × meses/6 + bonificación extraordinaria (Ley 30334).
- **CTS**: (sueldo + asignación + gratificación/6) × meses/12 + × días/360.

## Valores por defecto a verificar antes de publicar

- **UIT**: por defecto S/ 5,350 (valor 2025). Actualizar al valor vigente en Ajustes o en el código.
- **Asignación familiar**: S/ 113 (10% de la RMV de S/ 1,130).
- **Comisiones AFP**: verificar tasas vigentes en la SBS.

> ⚠️ Todos los cálculos son referenciales y no reemplazan la boleta de pago ni asesoría contable.

## Roadmap (ideas para v1.x)

- Retención de 5ta con el método exacto de SUNAT por mes.
- Comparador AFP vs ONP.
- Widget con cuenta regresiva a la próxima grati/CTS.
- Monetización: gratis con ads discretos o compra única para quitar límites.
