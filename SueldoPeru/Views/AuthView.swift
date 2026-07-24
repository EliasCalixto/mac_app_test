import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var sesion: Sesion

    private enum Modo: String, CaseIterable {
        case iniciar = "Iniciar sesión"
        case registrar = "Crear cuenta"
    }

    @State private var modo: Modo = .iniciar
    @State private var nombre = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                encabezado

                Picker("Modo", selection: $modo) {
                    ForEach(Modo.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                campos
                botonPrincipal

                if let error = sesion.error {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }

                separador
                botonesProveedores

                Text("Al continuar aceptas que tus cálculos se guarden en tu cuenta para sincronizarlos entre tus dispositivos.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding(24)
            .frame(maxWidth: 480)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .overlay {
            if sesion.cargando {
                ProgressView()
                    .padding(24)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .animation(.default, value: modo)
        .animation(.default, value: sesion.error)
    }

    private var encabezado: some View {
        VStack(spacing: 12) {
            LogoCalqui(tamano: 84)
                .shadow(color: Marca.verdeOscuro.opacity(0.3), radius: 12, y: 6)
            Text("Calqui")
                .font(.largeTitle.bold())
            Text("Tus cálculos de sueldo, siempre contigo")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 24)
    }

    @ViewBuilder
    private var campos: some View {
        VStack(spacing: 12) {
            if modo == .registrar {
                campo("Nombre", texto: $nombre, systemImage: "person")
                    .textContentType(.name)
            }
            campo("Correo electrónico", texto: $email, systemImage: "envelope")
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            campoSeguro("Contraseña", texto: $password, systemImage: "lock")
        }
    }

    private var botonPrincipal: some View {
        Button {
            Task {
                switch modo {
                case .iniciar: await sesion.iniciar(email: email, password: password)
                case .registrar: await sesion.registrar(nombre: nombre, email: email, password: password)
                }
            }
        } label: {
            Text(modo.rawValue)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Marca.verdeClaro, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .foregroundStyle(.white)
        }
        .disabled(sesion.cargando)
    }

    private var separador: some View {
        HStack(spacing: 12) {
            Rectangle().frame(height: 1).foregroundStyle(.secondary.opacity(0.3))
            Text("o continúa con").font(.caption).foregroundStyle(.secondary).fixedSize()
            Rectangle().frame(height: 1).foregroundStyle(.secondary.opacity(0.3))
        }
    }

    private var botonesProveedores: some View {
        VStack(spacing: 12) {
            Button {
                Task { await sesion.continuarConApple() }
            } label: {
                proveedorLabel(texto: "Continuar con Apple", systemImage: "apple.logo",
                               fondo: .black, tinte: .white, borde: false)
            }
            .disabled(sesion.cargando)

            Button {
                Task { await sesion.continuarConGoogle() }
            } label: {
                proveedorLabel(texto: "Continuar con Google", letraG: true,
                               fondo: Color(.systemBackground), tinte: .primary, borde: true)
            }
            .disabled(sesion.cargando)
        }
    }

    // MARK: - Piezas reutilizables

    private func campo(_ titulo: String, texto: Binding<String>, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage).foregroundStyle(.secondary).frame(width: 20)
            TextField(titulo, text: texto)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func campoSeguro(_ titulo: String, texto: Binding<String>, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage).foregroundStyle(.secondary).frame(width: 20)
            SecureField(titulo, text: texto)
                .textContentType(.password)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func proveedorLabel(texto: String, systemImage: String? = nil, letraG: Bool = false,
                                fondo: Color, tinte: Color, borde: Bool) -> some View {
        HStack(spacing: 10) {
            if let systemImage {
                Image(systemName: systemImage)
            } else if letraG {
                Text("G").font(.headline.bold()).foregroundStyle(Color(red: 0.26, green: 0.52, blue: 0.96))
            }
            Text(texto).font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .foregroundStyle(tinte)
        .background(fondo, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            if borde {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.secondary.opacity(0.3), lineWidth: 1)
            }
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(Sesion())
}
