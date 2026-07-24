import SwiftUI

/// Fila de resultado con etiqueta y monto en soles.
struct FilaResultado: View {
    let titulo: String
    let monto: Double
    var destacado = false
    var negativo = false

    private var color: Color {
        if negativo || monto < 0 { return .red }
        if destacado { return Color.accentColor }
        return .primary
    }

    var body: some View {
        HStack {
            Text(titulo)
                .font(destacado ? .headline : .subheadline)
            Spacer()
            Text(negativo ? "− \(monto.enSoles)" : monto.enSoles)
                .font(destacado ? .title3.bold() : .subheadline.monospacedDigit())
                .foregroundStyle(color)
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

// MARK: - Identidad de marca

/// Paleta y estilos de marca de Calqui, reutilizados en toda la app.
enum Marca {
    static let verdeClaro = Color(red: 0.09, green: 0.73, blue: 0.50)
    static let verdeOscuro = Color(red: 0.02, green: 0.42, blue: 0.31)
    static let ambar = Color(red: 0.95, green: 0.66, blue: 0.20)
}

/// Estilo visual de la tarjeta de resultado principal.
enum EstiloHero {
    case marca, positivo, negativo, neutro

    var degradado: LinearGradient {
        let colores: [Color]
        switch self {
        case .marca, .positivo:
            colores = [Marca.verdeClaro, Marca.verdeOscuro]
        case .negativo:
            colores = [Color(red: 0.92, green: 0.40, blue: 0.36), Color(red: 0.74, green: 0.21, blue: 0.22)]
        case .neutro:
            colores = [Color(red: 0.44, green: 0.49, blue: 0.53), Color(red: 0.27, green: 0.31, blue: 0.35)]
        }
        return LinearGradient(colors: colores, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var sombra: Color {
        switch self {
        case .marca, .positivo: return Marca.verdeOscuro.opacity(0.35)
        case .negativo: return Color(red: 0.74, green: 0.21, blue: 0.22).opacity(0.32)
        case .neutro: return Color.black.opacity(0.2)
        }
    }
}

/// Tarjeta hero con el resultado principal: fondo con degradado de marca y
/// tipografía blanca (estilo de apps fintech). Aplica su propio estilo de fila
/// para verse como tarjeta flotante dentro de un `Form`.
struct TarjetaTotal: View {
    let titulo: String
    let monto: Double
    var subtitulo: String? = nil
    var estilo: EstiloHero = .marca

    var body: some View {
        VStack(spacing: 6) {
            Text(titulo)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
            Text(monto.enSoles)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            if let subtitulo {
                Text(subtitulo)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .padding(.horizontal, 18)
        .background(estilo.degradado)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: estilo.sombra, radius: 14, x: 0, y: 8)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(Color.clear)
        .accessibilityElement(children: .combine)
    }
}

extension View {
    /// Barra de navegación consistente en toda la app: logo de Calqui + título
    /// centrados, como el encabezado de una app de producto (estilo fintech).
    func barraCalqui(_ titulo: String) -> some View {
        navigationTitle(titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        LogoCalqui(tamano: 26)
                        Text(titulo)
                            .font(.headline)
                    }
                }
            }
    }
}
