import SwiftUI

/// Compara dos sueldos brutos (por ejemplo, tu trabajo actual contra una
/// oferta) y muestra cuánto cambia el neto mensual y el ingreso anual.
struct ComparadorView: View {
    @AppStorage("uit") private var uit = 5350.0
    @AppStorage("asignacionFamiliar") private var montoAsignacion = 113.0
    @AppStorage("recibeAsignacion") private var recibeAsignacion = false
    @AppStorage("sueldoBase") private var sueldoActual = 0.0
    @AppStorage("regimenPension") private var regimenActual: RegimenPension = .integra

    @State private var sueldoOferta = 0.0
    @State private var regimenOferta: RegimenPension = .integra

    private var asignacion: Double { recibeAsignacion ? montoAsignacion : 0 }

    private var resultadoActual: ResultadoSueldoNeto {
        CalculadoraPlanilla.sueldoNeto(
            sueldoMensual: sueldoActual,
            asignacionFamiliar: asignacion,
            regimen: regimenActual,
            uit: uit
        )
    }

    private var resultadoOferta: ResultadoSueldoNeto {
        CalculadoraPlanilla.sueldoNeto(
            sueldoMensual: sueldoOferta,
            asignacionFamiliar: asignacion,
            regimen: regimenOferta,
            uit: uit
        )
    }

    private var diferenciaMensual: Double {
        resultadoOferta.sueldoNeto - resultadoActual.sueldoNeto
    }

    private var diferenciaAnual: Double {
        resultadoOferta.ingresoAnualNeto - resultadoActual.ingresoAnualNeto
    }

    private var veredicto: String {
        if abs(diferenciaMensual) < 1 {
            return "Ambas opciones te dejan prácticamente el mismo neto."
        }
        let gana = diferenciaMensual > 0 ? "La oferta" : "Tu sueldo actual"
        return "\(gana) te deja \(abs(diferenciaMensual).enSoles) más al mes (\(abs(diferenciaAnual).enSoles) al año, incluyendo gratificaciones)."
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CampoMonto(titulo: "Sueldo bruto", valor: $sueldoActual)
                    Picker("Régimen de pensión", selection: $regimenActual) {
                        ForEach(RegimenPension.allCases) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                } header: {
                    Text("Tu sueldo actual")
                }

                Section {
                    CampoMonto(titulo: "Sueldo bruto", valor: $sueldoOferta)
                    Picker("Régimen de pensión", selection: $regimenOferta) {
                        ForEach(RegimenPension.allCases) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                } header: {
                    Text("La oferta")
                } footer: {
                    Text("Si negocias en bruto, aquí ves lo que de verdad te llega al bolsillo.")
                }

                if sueldoActual > 0 && sueldoOferta > 0 {
                    Section {
                        TarjetaTotal(
                            titulo: diferenciaMensual >= 0 ? "Ganas más con la oferta" : "Pierdes con la oferta",
                            monto: diferenciaMensual
                        )
                    } footer: {
                        Text(veredicto)
                    }

                    Section {
                        FilaResultado(titulo: "Neto actual", monto: resultadoActual.sueldoNeto)
                        FilaResultado(titulo: "Neto de la oferta", monto: resultadoOferta.sueldoNeto)
                        FilaResultado(titulo: "Anual actual", monto: resultadoActual.ingresoAnualNeto)
                        FilaResultado(titulo: "Anual de la oferta", monto: resultadoOferta.ingresoAnualNeto)
                        FilaResultado(titulo: "Diferencia anual", monto: diferenciaAnual, destacado: true)
                    } header: {
                        Text("Detalle")
                    } footer: {
                        Text("El anual incluye 12 sueldos netos y 2 gratificaciones con bonificación de EsSalud. No incluye CTS ni bonos del empleador.")
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Comparar")
        }
    }
}

#Preview {
    ComparadorView()
}
