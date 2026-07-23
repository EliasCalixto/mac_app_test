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

/// Campo de monto en soles con teclado decimal. Se muestra vacío cuando el
/// valor es cero para que el usuario no tenga que borrar el "0" antes de
/// escribir.
struct CampoMonto: View {
    let titulo: String
    @Binding var valor: Double

    private var valorOpcional: Binding<Double?> {
        Binding(
            get: { valor == 0 ? nil : valor },
            set: { valor = $0 ?? 0 }
        )
    }

    var body: some View {
        HStack {
            Text(titulo)
            Spacer()
            Text("S/")
                .foregroundStyle(.secondary)
            TextField("0.00", value: valorOpcional, format: .number.precision(.fractionLength(0...2)))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 110)
        }
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
