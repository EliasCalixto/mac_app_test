import Foundation
import CryptoKit

// MARK: - Modelo de usuario

struct Usuario: Codable, Identifiable, Equatable {
    let id: String
    var nombre: String
    var email: String?
    var proveedor: Proveedor

    enum Proveedor: String, Codable {
        case correo, apple, google

        var etiqueta: String {
            switch self {
            case .correo: return "Correo"
            case .apple: return "Apple"
            case .google: return "Google"
            }
        }
    }
}

// MARK: - Errores

enum ErrorAuth: LocalizedError {
    case camposIncompletos
    case correoInvalido
    case passwordCorta
    case correoYaRegistrado
    case credencialesInvalidas

    var errorDescription: String? {
        switch self {
        case .camposIncompletos: return "Completa todos los campos."
        case .correoInvalido: return "Ingresa un correo válido."
        case .passwordCorta: return "La contraseña debe tener al menos 6 caracteres."
        case .correoYaRegistrado: return "Ya existe una cuenta con ese correo."
        case .credencialesInvalidas: return "Correo o contraseña incorrectos."
        }
    }
}

// MARK: - Protocolo de autenticación

/// Contrato de autenticación. La app usa `LocalAuth` (cuentas en el dispositivo)
/// hasta conectar Firebase; para migrar basta con crear un `FirebaseAuth` que
/// cumpla este mismo protocolo e inyectarlo en `Sesion`. Ver INTEGRACION_CUENTAS.md.
protocol ServicioAuth {
    func registrarConCorreo(nombre: String, email: String, password: String) async throws -> Usuario
    func iniciarConCorreo(email: String, password: String) async throws -> Usuario
    func continuarConApple() async throws -> Usuario
    func continuarConGoogle() async throws -> Usuario
    func cerrarSesion() throws
    func usuarioActual() -> Usuario?
}

// MARK: - Implementación local (demo, sin nube)

/// Guarda cuentas y sesión en `UserDefaults`. La contraseña nunca se almacena en
/// texto plano: se guarda un hash SHA-256 con salt aleatorio por cuenta.
///
/// ⚠️ Es una implementación de demostración para probar el flujo sin backend. No
/// sincroniza entre dispositivos; eso lo hará la implementación de Firebase.
final class LocalAuth: ServicioAuth {
    private let defaults = UserDefaults.standard
    private let claveCuentas = "cuentasLocales"
    private let claveSesion = "sesionUsuario"

    private struct CuentaLocal: Codable {
        let id: String
        var nombre: String
        var email: String
        var salt: String
        var hash: String
        var proveedor: Usuario.Proveedor
    }

    // MARK: Correo + contraseña

    func registrarConCorreo(nombre: String, email: String, password: String) async throws -> Usuario {
        let nombreLimpio = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        let correo = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !nombreLimpio.isEmpty, !correo.isEmpty, !password.isEmpty else { throw ErrorAuth.camposIncompletos }
        guard correo.contains("@"), correo.contains(".") else { throw ErrorAuth.correoInvalido }
        guard password.count >= 6 else { throw ErrorAuth.passwordCorta }

        var cuentas = leerCuentas()
        guard cuentas[correo] == nil else { throw ErrorAuth.correoYaRegistrado }

        let salt = Self.nuevoSalt()
        let cuenta = CuentaLocal(
            id: UUID().uuidString,
            nombre: nombreLimpio,
            email: correo,
            salt: salt,
            hash: Self.hashear(password, salt: salt),
            proveedor: .correo
        )
        cuentas[correo] = cuenta
        guardarCuentas(cuentas)

        let usuario = Usuario(id: cuenta.id, nombre: cuenta.nombre, email: cuenta.email, proveedor: .correo)
        guardarSesion(usuario)
        return usuario
    }

    func iniciarConCorreo(email: String, password: String) async throws -> Usuario {
        let correo = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !correo.isEmpty, !password.isEmpty else { throw ErrorAuth.camposIncompletos }

        guard let cuenta = leerCuentas()[correo],
              cuenta.hash == Self.hashear(password, salt: cuenta.salt) else {
            throw ErrorAuth.credencialesInvalidas
        }

        let usuario = Usuario(id: cuenta.id, nombre: cuenta.nombre, email: cuenta.email, proveedor: .correo)
        guardarSesion(usuario)
        return usuario
    }

    // MARK: Proveedores externos (demo local; se reemplazan por Firebase)

    func continuarConApple() async throws -> Usuario {
        let usuario = Usuario(id: "apple-demo", nombre: "Usuario Apple", email: nil, proveedor: .apple)
        guardarSesion(usuario)
        return usuario
    }

    func continuarConGoogle() async throws -> Usuario {
        let usuario = Usuario(id: "google-demo", nombre: "Usuario Google", email: nil, proveedor: .google)
        guardarSesion(usuario)
        return usuario
    }

    // MARK: Sesión

    func cerrarSesion() throws {
        defaults.removeObject(forKey: claveSesion)
    }

    func usuarioActual() -> Usuario? {
        guard let data = defaults.data(forKey: claveSesion) else { return nil }
        return try? JSONDecoder().decode(Usuario.self, from: data)
    }

    // MARK: Persistencia

    private func leerCuentas() -> [String: CuentaLocal] {
        guard let data = defaults.data(forKey: claveCuentas),
              let cuentas = try? JSONDecoder().decode([String: CuentaLocal].self, from: data) else {
            return [:]
        }
        return cuentas
    }

    private func guardarCuentas(_ cuentas: [String: CuentaLocal]) {
        if let data = try? JSONEncoder().encode(cuentas) {
            defaults.set(data, forKey: claveCuentas)
        }
    }

    private func guardarSesion(_ usuario: Usuario) {
        if let data = try? JSONEncoder().encode(usuario) {
            defaults.set(data, forKey: claveSesion)
        }
    }

    // MARK: Hashing

    private static func hashear(_ password: String, salt: String) -> String {
        let digest = SHA256.hash(data: Data((salt + password).utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func nuevoSalt() -> String {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return bytes.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Estado de sesión (observable)

/// Fuente de verdad de la sesión para la UI. La vista raíz muestra el login
/// cuando `usuario == nil` y la app cuando hay un usuario.
@MainActor
final class Sesion: ObservableObject {
    @Published private(set) var usuario: Usuario?
    @Published var cargando = false
    @Published var error: String?

    private let servicio: ServicioAuth

    init(servicio: ServicioAuth = LocalAuth()) {
        self.servicio = servicio
        self.usuario = servicio.usuarioActual()
    }

    func registrar(nombre: String, email: String, password: String) async {
        await ejecutar { try await self.servicio.registrarConCorreo(nombre: nombre, email: email, password: password) }
    }

    func iniciar(email: String, password: String) async {
        await ejecutar { try await self.servicio.iniciarConCorreo(email: email, password: password) }
    }

    func continuarConApple() async {
        await ejecutar { try await self.servicio.continuarConApple() }
    }

    func continuarConGoogle() async {
        await ejecutar { try await self.servicio.continuarConGoogle() }
    }

    func cerrarSesion() {
        try? servicio.cerrarSesion()
        usuario = nil
        error = nil
    }

    private func ejecutar(_ accion: @escaping () async throws -> Usuario) async {
        cargando = true
        error = nil
        do {
            usuario = try await accion()
        } catch {
            self.error = error.localizedDescription
        }
        cargando = false
    }
}
