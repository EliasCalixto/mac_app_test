import SwiftUI

struct AjustesView: View {
    @AppStorage("uit") private var uit = 5350.0
    @AppStorage("asignacionFamiliar") private var montoAsignacion = 113.0

    var body: some View {
            Form {
                Section {
                    CampoMonto(titulo: "UIT vigente", valor: $uit)
                    CampoMonto(titulo: "Asignación familiar", valor: $montoAsignacion)
                } header: {
                    Text("Valores de referencia")
                } footer: {
                    Text("La UIT la fija el MEF cada año y la asignación familiar es el 10% de la remuneración mínima vital. Actualiza estos valores cuando cambien.")
                }

                Section {
                    ForEach(RegimenPension.allCases.filter { $0 != .onp }) { afp in
                        HStack {
                            Text(afp.rawValue)
                            Spacer()
                            Text(String(format: "%.2f%%", afp.tasaTotal * 100))
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                    HStack {
                        Text("ONP")
                        Spacer()
                        Text("13.00%")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                } header: {
                    Text("Tasas de pensión (referenciales)")
                } footer: {
                    Text("Incluyen aporte obligatorio (10%), comisión sobre flujo y prima de seguro. Las comisiones cambian periódicamente; verifica la tuya en tu boleta o en la SBS.")
                }

                Section("Acerca de") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sueldo Perú v1.1")
                            .font(.headline)
                        Text("Todos los cálculos son referenciales y no reemplazan la información de tu boleta de pago ni la asesoría de un contador. Los montos reales pueden variar según tu empleador, tus ingresos variables y la normativa vigente.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AjustesView()
}
