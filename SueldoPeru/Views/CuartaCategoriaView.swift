import SwiftUI

/// Calculadora para trabajadores independientes: retención del 8% en recibos
/// por honorarios y límite para pedir la suspensión de retenciones.
struct CuartaCategoriaView: View {
    @AppStorage("uit") private var uit = 5350.0

    @State private var montoRecibo = 0.0

    private var resultado: ResultadoCuartaCategoria {
        CalculadoraPlanilla.cuartaCategoria(montoRecibo: montoRecibo)
    }

    private var limiteMensual: Double {
        CalculadoraPlanilla.limiteSuspensionMensual(uit: uit)
    }

    var body: some View {
        Form {
            Section {
                CampoMonto(titulo: "Monto del recibo", valor: $montoRecibo)
            } header: {
                Text("Recibo por honorarios")
            } footer: {
                Text("La retención del 8% aplica cuando el recibo supera S/ \(Int(CalculadoraPlanilla.limiteRetencionRecibo)) y la empresa que te paga es agente de retención.")
            }

            if montoRecibo > 0 {
                Section {
                    TarjetaTotal(titulo: "Neto a cobrar", monto: resultado.neto)
                }

                Section {
                    if resultado.sujetoARetencion {
                        FilaResultado(titulo: "Retención (8%)", monto: resultado.retencion, negativo: true)
                    } else {
                        Text("Este recibo no está sujeto a retención.")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                FilaResultado(titulo: "Ingreso mensual promedio", monto: limiteMensual)
            } header: {
                Text("Suspensión de retenciones")
            } footer: {
                Text("Si proyectas ganar menos que este promedio mensual durante el año, puedes solicitar a SUNAT la suspensión de retenciones (Formulario 1609) y cobrar tus recibos completos. Valor aproximado derivado de 7 UIT y la deducción del 20%.")
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Recibos por honorarios")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CuartaCategoriaView()
    }
}
