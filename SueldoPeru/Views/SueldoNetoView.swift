import SwiftUI

struct SueldoNetoView: View {
    @AppStorage("uit") private var uit = 5350.0
    @AppStorage("asignacionFamiliar") private var montoAsignacion = 113.0

    @State private var sueldo = 0.0
    @State private var recibeAsignacion = false
    @State private var regimen: RegimenPension = .integra

    private var resultado: ResultadoSueldoNeto {
        CalculadoraPlanilla.sueldoNeto(
            sueldoMensual: sueldo,
            asignacionFamiliar: recibeAsignacion ? montoAsignacion : 0,
            regimen: regimen,
            uit: uit
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Datos") {
                    CampoMonto(titulo: "Sueldo bruto mensual", valor: $sueldo)
                    Toggle("Asignación familiar", isOn: $recibeAsignacion)
                    Picker("Régimen de pensión", selection: $regimen) {
                        ForEach(RegimenPension.allCases) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                }

                if sueldo > 0 {
                    Section {
                        TarjetaTotal(titulo: "Sueldo neto mensual", monto: resultado.sueldoNeto)
                    }

                    Section("Descuentos") {
                        if regimen == .onp {
                            FilaResultado(titulo: "ONP (13%)", monto: resultado.descuentoPension, negativo: true)
                        } else {
                            FilaResultado(titulo: "Aporte AFP (10%)", monto: resultado.aportePension, negativo: true)
                            FilaResultado(titulo: "Comisión AFP", monto: resultado.comisionPension, negativo: true)
                            FilaResultado(titulo: "Prima de seguro", monto: resultado.primaSeguro, negativo: true)
                        }
                        FilaResultado(titulo: "Renta 5ta categoría", monto: resultado.rentaQuintaMensual, negativo: true)
                    } footer: {
                        Text("Renta anual proyectada: \(resultado.rentaQuintaAnual.enSoles) (retención repartida en 12 meses). Cálculo referencial: la retención real de SUNAT varía según el mes y otros ingresos.")
                    }

                    Section {
                        FilaResultado(titulo: "Remuneración bruta", monto: resultado.remuneracionBruta)
                        FilaResultado(titulo: "Total descuentos", monto: resultado.descuentoPension + resultado.rentaQuintaMensual, negativo: true)
                    }
                }
            }
            .navigationTitle("Sueldo Neto")
        }
    }
}

#Preview {
    SueldoNetoView()
}
