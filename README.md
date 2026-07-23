# Sueldo Perú 🇵🇪

App iOS (SwiftUI) para calcular en segundos los tres montos que todo trabajador en planilla del Perú quiere saber:

- **Sueldo neto mensual** — descuenta AFP (Habitat, Integra, Prima, Profuturo) u ONP, y la retención de renta de 5ta categoría. Incluye proyección anual (12 sueldos + 2 gratis) y ahorro CTS del año.
- **Gratificación** (julio y diciembre) — proporcional a los meses trabajados, con bonificación extraordinaria del 9% (EsSalud) o 6.75% (EPS), y cuenta regresiva a la próxima fecha de pago.
- **CTS** (mayo y noviembre) — remuneración computable (sueldo + asignación + 1/6 de gratificación), por meses y días trabajados, con cuenta regresiva al próximo depósito.

Además (v1.1):

- **Comparador de ofertas** — neto actual vs. neto de una oferta, con diferencia mensual y anual.
- **Recibos por honorarios (4ta categoría)** — retención del 8% y límite de suspensión de retenciones.
- **Compartir cálculo** desde Sueldo Neto y Gratificación.
- El sueldo se escribe una vez y se comparte entre todas las calculadoras (persistido con `@AppStorage`).
- Pantalla de **Ajustes** para actualizar la UIT y la asignación familiar cuando cambien, sin necesidad de actualizar la app.

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
    ├── ContentView.swift        # TabView principal (5 pestañas)
    ├── SueldoNetoView.swift
    ├── ComparadorView.swift     # Sueldo actual vs. oferta
    ├── GratificacionView.swift
    ├── CTSView.swift
    ├── CuartaCategoriaView.swift # Recibos por honorarios
    ├── MasView.swift            # Pestaña "Más": honorarios + ajustes
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

## Roadmap (ideas para v1.2+)

- Retención de 5ta con el método exacto de SUNAT por mes.
- Widget de pantalla de inicio con cuenta regresiva a la próxima grati/CTS.
- Notificación local unos días antes de cada fecha de pago.
- Modo "de neto a bruto" (¿cuánto bruto necesito para llevarme X?).
- Monetización: gratis con compra única "Pro" (comparador ilimitado, widget, exportar PDF).
