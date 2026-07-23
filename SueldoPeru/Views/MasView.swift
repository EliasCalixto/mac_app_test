import SwiftUI

struct MasView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        CuartaCategoriaView()
                    } label: {
                        Label("Recibos por honorarios", systemImage: "doc.text")
                    }
                } footer: {
                    Text("Retención del 8% y suspensión de retenciones para independientes (4ta categoría).")
                }

                Section {
                    NavigationLink {
                        AjustesView()
                    } label: {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                } footer: {
                    Text("UIT, asignación familiar y tasas de referencia.")
                }
            }
            .navigationTitle("Más")
        }
    }
}

#Preview {
    MasView()
}
