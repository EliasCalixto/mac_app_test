import SwiftUI

struct MasView: View {
    @EnvironmentObject private var sesion: Sesion

    var body: some View {
        NavigationStack {
            List {
                Section {
                    EncabezadoMarca()
                        .listRowBackground(Color.clear)
                }

                if let usuario = sesion.usuario {
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 38))
                                .foregroundStyle(Marca.verdeClaro)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(usuario.nombre)
                                    .font(.headline)
                                Text(usuario.email ?? "Sesión con \(usuario.proveedor.etiqueta)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Tu cuenta")
                    }
                }

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

                if sesion.usuario != nil {
                    Section {
                        Button(role: .destructive) {
                            sesion.cerrarSesion()
                        } label: {
                            Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
            }
            .navigationTitle("Más")
        }
    }
}

#Preview {
    MasView()
}
