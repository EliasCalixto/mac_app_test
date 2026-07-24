import SwiftUI

struct SueldoNetoView: View {
    @AppStorage("uit") private var uit = 5350.0
    @AppStorage("asignacionFamiliar") private var montoAsignacion = 113.0
    @AppStorage("sueldoBase") private var sueldo = 0.0
    @AppStorage("recibeAsignacion") private var recibeAsignacion = false
    @AppStorage("regimenPension") private var regimen: RegimenPension = .integra

    private var resultado: ResultadoSueldoNeto {
        CalculadoraPlanilla.sueldoNeto(
            sueldoMensual: sueldo,
            asignacionFamiliar: recibeAsignacion ? montoAsignacion : 0,
            regimen: regimen,
            uit: uit
        )
    }

    private var resumenCompartir: String {
        """
        💰 Mi cálculo con Calqui
        Sueldo bruto: \(resultado.remuneracionBruta.enSoles)
        Descuento de pensión (\(regimen.rawValue)): −\(resultado.descuentoPension.enSoles)
        Renta 5ta categoría: −\(resultado.rentaQuintaMensual.enSoles)
        Sueldo neto: \(resultado.sueldoNeto.enSoles)
        Ingreso anual estimado: \(resultado.ingresoAnualNeto.enSoles)
        """
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CampoMonto(titulo: "Sueldo bruto mensual", valor: $sueldo)
                    Toggle("Asignación familiar", isOn: $recibeAsignacion)
                    Picker("Régimen de pensión", selection: $regimen) {
                        ForEach(RegimenPension.allCases) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                } header: {
                    Text("Datos")
                } footer: {
                    Text("Tu sueldo se guarda y se comparte con las demás calculadoras.")
                }

                if sueldo > 0 {
                    Section {
                        TarjetaTotal(titulo: "Sueldo neto mensual", monto: resultado.sueldoNeto)
                    }

                    Section {
                        if regimen == .onp {
                            FilaResultado(titulo: "ONP (13%)", monto: resultado.descuentoPension, negativo: true)
                        } else {
                            FilaResultado(titulo: "Aporte AFP (10%)", monto: resultado.aportePension, negativo: true)
                            FilaResultado(titulo: "Comisión AFP", monto: resultado.comisionPension, negativo: true)
                            FilaResultado(titulo: "Prima de seguro", monto: resultado.primaSeguro, negativo: true)
                        }
                        FilaResultado(titulo: "Renta 5ta categoría", monto: resultado.rentaQuintaMensual, negativo: true)
                    } header: {
                        Text("Descuentos")
                    } footer: {
                        Text("Renta anual proyectada: \(resultado.rentaQuintaAnual.enSoles) (retención repartida en 12 meses). Cálculo referencial: la retención real de SUNAT varía según el mes y otros ingresos.")
                    }

                    Section {
                        FilaResultado(titulo: "Ingreso neto anual", monto: resultado.ingresoAnualNeto, destacado: true)
                        FilaResultado(titulo: "Ahorro CTS del año", monto: resultado.ctsAnual)
                    } header: {
                        Text("Tu año completo")
                    } footer: {
                        Text("Incluye 12 sueldos netos y 2 gratificaciones con bonificación del 9% (EsSalud). La CTS no es de libre disposición: se deposita en tu cuenta CTS en mayo y noviembre.")
                    }

                    Section {
                        ShareLink(item: resumenCompartir) {
                            Label("Compartir cálculo", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .barraCalqui("Sueldo Neto")
        }
    }
}

#Preview {
    SueldoNetoView()
}
