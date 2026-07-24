import SwiftUI

/// Fila de resultado con etiqueta y monto en soles.
struct FilaResultado: View {
    let titulo: String
    let monto: Double
    var destacado = false
    var negativo = false

    var body: some View {
        HStack {
            Text(titulo)
                .font(destacado ? .headline : .subheadline)
            Spacer()
            Text(negativo ? "− \(monto.enSoles)" : monto.enSoles)
                .font(destacado ? .title3.bold() : .subheadline.monospacedDigit())
                .foregroundStyle(destacado ? Color.accentColor : (negativo ? .red : .primary))
        }
        .accessibilityElement(children: .combine)
    }
}

/// Campo de monto en soles con teclado decimal.
///
/// Está respaldado por un `String` y confirma el valor en **cada tecla** (no al
/// cerrar el teclado), de modo que el monto queda guardado aunque el usuario
/// cierre la app de inmediato, y los resultados se actualizan en vivo mientras
/// escribe. Se muestra vacío cuando el valor es cero.
///
/// Supone separador decimal "." y de miles "," (configuración de Perú).
struct CampoMonto: View {
    let titulo: String
    @Binding var valor: Double

    @State private var texto = ""
    @FocusState private var enfocado: Bool

    private static let agrupado: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.groupingSeparator = ","
        f.decimalSeparator = "."
        return f
    }()

    var body: some View {
        HStack {
            Text(titulo)
            Spacer()
            Text("S/")
                .foregroundStyle(.secondary)
            TextField("0.00", text: $texto)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 130)
                .focused($enfocado)
                .onChange(of: texto) { _, nuevo in confirmar(nuevo) }
                .onChange(of: enfocado) { _, activo in
                    activo ? mostrarCrudo() : mostrarConSeparadores()
                }
        }
        .onAppear { mostrarConSeparadores() }
        .onChange(of: valor) { _, _ in
            if !enfocado { mostrarConSeparadores() }
        }
    }

    /// Parsea el texto y escribe el valor en cada cambio (persistencia inmediata).
    private func confirmar(_ nuevo: String) {
        let limpio = nuevo.replacingOccurrences(of: ",", with: "")
                          .replacingOccurrences(of: " ", with: "")
        if limpio.isEmpty {
            if valor != 0 { valor = 0 }
        } else if let d = Double(limpio), d != valor {
            valor = d
        }
    }

    /// Mientras se edita: número plano, sin separadores de miles.
    private func mostrarCrudo() {
        texto = valor == 0 ? "" : recortado(valor)
    }

    /// En reposo: con separadores de miles (p. ej. "4,200").
    private func mostrarConSeparadores() {
        texto = valor == 0 ? "" : (Self.agrupado.string(from: NSNumber(value: valor)) ?? recortado(valor))
    }

    /// Sin ".0" cuando es un entero.
    private func recortado(_ v: Double) -> String {
        v == v.rounded() ? String(Int(v)) : String(v)
    }
}

/// Tarjeta con cuenta regresiva a una fecha de pago (gratificación o CTS).
struct TarjetaCountdown: View {
    let titulo: String
    let fecha: Date

    private var dias: Int { FechasPlanilla.diasHasta(fecha) }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(fecha, format: .dateTime.day().month(.wide))
                    .font(.headline)
            }
            Spacer()
            VStack(spacing: 0) {
                Text("\(dias)")
                    .font(.system(.title, design: .rounded).bold())
                    .foregroundStyle(Color.accentColor)
                    .monospacedDigit()
                Text(dias == 1 ? "día" : "días")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// Logo de la app (el mismo ícono, redondeado) para usar dentro de la interfaz.
struct LogoCalqui: View {
    var tamano: CGFloat = 44

    var body: some View {
        Image("LogoCalqui")
            .resizable()
            .scaledToFill()
            .frame(width: tamano, height: tamano)
            .clipShape(RoundedRectangle(cornerRadius: tamano * 0.22, style: .continuous))
    }
}

/// Encabezado de marca: logo + nombre + descripción de la app.
struct EncabezadoMarca: View {
    var body: some View {
        HStack(spacing: 14) {
            LogoCalqui(tamano: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text("Calqui")
                    .font(.title3.bold())
                Text("Calculadora de sueldos del Perú")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

/// Tarjeta grande con el resultado principal.
struct TarjetaTotal: View {
    let titulo: String
    let monto: Double

    var body: some View {
        VStack(spacing: 4) {
            Text(titulo)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(monto.enSoles)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Color.accentColor)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}
