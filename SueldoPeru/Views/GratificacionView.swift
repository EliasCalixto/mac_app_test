import SwiftUI

struct GratificacionView: View {
    @AppStorage("asignacionFamiliar") private var montoAsignacion = 113.0
    @AppStorage("sueldoBase") private var sueldo = 0.0
    @AppStorage("recibeAsignacion") private var recibeAsignacion = false

    @State private var mesesTrabajados = 6
    @State private var salud: RegimenSalud = .essalud

    private var resultado: ResultadoGratificacion {
        CalculadoraPlanilla.gratificacion(
            sueldoMensual: sueldo,
            asignacionFamiliar: recibeAsignacion ? montoAsignacion : 0,
            mesesTrabajados: mesesTrabajados,
            salud: salud
        )
    }

    private var resumenCompartir: String {
        """
        🎁 Mi gratificación con Calqui
        Gratificación: \(resultado.gratificacion.enSoles)
        Bonificación extraordinaria: \(resultado.bonificacionExtraordinaria.enSoles)
        Total a recibir: \(resultado.total.enSoles)
        """
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TarjetaCountdown(
                        titulo: "Próxima gratificación",
                        fecha: FechasPlanilla.proximaGratificacion()
                    )
                }

                Section {
                    CampoMonto(titulo: "Sueldo bruto mensual", valor: $sueldo)
                    Toggle("Asignación familiar", isOn: $recibeAsignacion)
                    Picker("Meses completos trabajados", selection: $mesesTrabajados) {
                        ForEach(1...6, id: \.self) { m in
                            Text("\(m) \(m == 1 ? "mes" : "meses")").tag(m)
                        }
                    }
                    Picker("Seguro de salud", selection: $salud) {
                        ForEach(RegimenSalud.allCases) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                } header: {
                    Text("Datos")
                } footer: {
                    Text("Selecciona solo los meses calendario completos que trabajaste en el semestre. Los meses incompletos no se computan para la gratificación (los días sueltos se pagan aparte como \"gratificación trunca\").")
                }

                if sueldo > 0 {
                    Section {
                        TarjetaTotal(titulo: "Total a recibir", monto: resultado.total)
                    }

                    Section {
                        FilaResultado(titulo: "Gratificación", monto: resultado.gratificacion)
                        FilaResultado(
                            titulo: salud == .essalud ? "Bonificación extraordinaria (9%)" : "Bonificación extraordinaria (6.75%)",
                            monto: resultado.bonificacionExtraordinaria
                        )
                    } header: {
                        Text("Detalle")
                    } footer: {
                        Text("La gratificación se paga en julio y diciembre, no tiene descuento de AFP/ONP y se calcula por meses calendario completos trabajados en el semestre. Puede estar sujeta a retención de renta de 5ta categoría.")
                    }

                    Section {
                        ShareLink(item: resumenCompartir) {
                            Label("Compartir cálculo", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .barraCalqui("Gratificación")
        }
    }
}

#Preview {
    GratificacionView()
}
