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
struct CampoMonto: View {
    let titulo: String
    @Binding var valor: Double

    var body: some View {
        HStack {
            Text(titulo)
            Spacer()
            TextField("0.00", value: $valor, format: .number.precision(.fractionLength(0...2)))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 140)
        }
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
