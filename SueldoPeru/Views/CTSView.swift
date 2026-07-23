import SwiftUI

struct CTSView: View {
    @AppStorage("asignacionFamiliar") private var montoAsignacion = 113.0

    @State private var sueldo = 0.0
    @State private var recibeAsignacion = false
    @State private var gratificacion = 0.0
    @State private var mesesCompletos = 6
    @State private var diasAdicionales = 0

    private var resultado: ResultadoCTS {
        CalculadoraPlanilla.cts(
            sueldoMensual: sueldo,
            asignacionFamiliar: recibeAsignacion ? montoAsignacion : 0,
            ultimaGratificacion: gratificacion,
            mesesCompletos: mesesCompletos,
            diasAdicionales: diasAdicionales
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CampoMonto(titulo: "Sueldo bruto mensual", valor: $sueldo)
                    Toggle("Asignación familiar", isOn: $recibeAsignacion)
                    CampoMonto(titulo: "Última gratificación", valor: $gratificacion)
                } header: {
                    Text("Datos")
                } footer: {
                    Text("Si trabajaste el semestre completo, tu última gratificación suele ser igual a un sueldo (sin contar la bonificación extraordinaria).")
                }

                Section("Tiempo trabajado en el semestre") {
                    Picker("Meses completos", selection: $mesesCompletos) {
                        ForEach(0...6, id: \.self) { m in
                            Text("\(m)").tag(m)
                        }
                    }
                    Stepper("Días adicionales: \(diasAdicionales)", value: $diasAdicionales, in: 0...29)
                }

                if sueldo > 0 {
                    Section {
                        TarjetaTotal(titulo: "Depósito de CTS", monto: resultado.total)
                    }

                    Section {
                        FilaResultado(titulo: "Remuneración computable", monto: resultado.remuneracionComputable)
                        FilaResultado(titulo: "Por meses (1/12 c/u)", monto: resultado.porMeses)
                        if resultado.porDias > 0 {
                            FilaResultado(titulo: "Por días (1/360 c/u)", monto: resultado.porDias)
                        }
                    } header: {
                        Text("Detalle")
                    } footer: {
                        Text("La CTS se deposita en mayo (semestre nov–abr) y noviembre (semestre may–oct). Remuneración computable = sueldo + asignación familiar + 1/6 de la última gratificación.")
                    }
                }
            }
            .navigationTitle("CTS")
        }
    }
}

#Preview {
    CTSView()
}
