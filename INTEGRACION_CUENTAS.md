# Integración de cuentas y sincronización (Firebase)

La app ya tiene toda la interfaz de inicio de sesión, registro y cierre de
sesión funcionando con una implementación **local** (`LocalAuth` en
`SueldoPeru/Models/Autenticacion.swift`). Las cuentas se guardan en el
dispositivo con la contraseña hasheada (SHA-256 + salt), pero **no sincronizan
entre dispositivos**.

Para tener login real con Apple / Google / correo **y** sincronización en la
nube, se conecta **Firebase**. La arquitectura ya está lista: solo hay que crear
una clase `FirebaseAuth` que cumpla el protocolo `ServicioAuth` e inyectarla en
`Sesion`.

## Por qué Firebase

Es el único servicio que soporta los tres métodos que pediste (Apple, Google y
correo/contraseña) a la vez, con sincronización en cualquier plataforma y un
backend gratuito administrado por Google (no lo mantienes tú). El plan gratuito
(Spark) sobra para esta app.

## Pasos (se hacen en tu Mac con Xcode y tu cuenta)

### 1. Crear el proyecto de Firebase
1. Entra a https://console.firebase.google.com y crea un proyecto (ej. "Calqui").
2. Agrega una app iOS con el bundle ID **com.eliascalixto.SueldoPeru**.
3. Descarga **GoogleService-Info.plist** y arrástralo al proyecto en Xcode
   (dentro de la carpeta `SueldoPeru/`, marca "Copy items if needed").

### 2. Agregar el SDK (Swift Package Manager)
En Xcode: File ▸ Add Package Dependencies… y pega:
```
https://github.com/firebase/firebase-ios-sdk
```
Agrega estos productos al target: **FirebaseAuth**, **FirebaseFirestore** y, si
usarás Google, **GoogleSignIn** (paquete aparte:
`https://github.com/google/GoogleSignIn-iOS`).

### 3. Habilitar los métodos de acceso
En la consola de Firebase ▸ Authentication ▸ Sign-in method, habilita:
- **Correo/contraseña**
- **Google**
- **Apple**

### 4. Capacidades en Xcode (target ▸ Signing & Capabilities)
- **Sign in with Apple** (requiere la cuenta de Apple Developer de pago).
- Para Google: en Info ▸ URL Types agrega el **REVERSED_CLIENT_ID** que está
  dentro de `GoogleService-Info.plist`.

### 5. Inicializar Firebase
En `SueldoPeruApp.swift`, dentro de un `init()` del `App`:
```swift
import FirebaseCore
init() { FirebaseApp.configure() }
```

### 6. Crear `FirebaseAuth: ServicioAuth`
Implementa el mismo protocolo que `LocalAuth` usando `Auth.auth()`:
- `registrarConCorreo` → `Auth.auth().createUser(withEmail:password:)`
- `iniciarConCorreo` → `Auth.auth().signIn(withEmail:password:)`
- `continuarConApple` → flujo `ASAuthorizationAppleIDProvider` + `OAuthProvider`
- `continuarConGoogle` → `GIDSignIn.sharedInstance.signIn(...)` + credencial
- `cerrarSesion` → `try Auth.auth().signOut()`
- `usuarioActual` → mapear `Auth.auth().currentUser`

Luego, en `Sesion.init`, cambia el valor por defecto:
```swift
init(servicio: ServicioAuth = FirebaseAuth()) { ... }
```
La interfaz (`AuthView`, `MasView`) no necesita ningún cambio.

### 7. Sincronizar los datos del usuario
Hoy los cálculos se guardan con `@AppStorage` (local). Para sincronizarlos:
1. Al iniciar sesión, **descargar** el documento del usuario desde Firestore
   (colección `usuarios/{uid}`) y volcar los valores a `UserDefaults`
   (`sueldoBase`, `asignacionFamiliar`, `recibeAsignacion`, `regimenPension`,
   `uit`).
2. Cuando el usuario cambie un valor, **subir** ese documento a Firestore.
3. Opcional: escuchar cambios en tiempo real con un `snapshotListener` para que
   se actualice al vuelo entre dispositivos.

Como los datos son pocos (unos números), esto es liviano y encaja en el plan
gratuito sin problema.

## Qué NO cambiar
- El protocolo `ServicioAuth` es el contrato estable. Mantén los mismos métodos.
- `AuthView` y el botón de cerrar sesión en `MasView` ya funcionan tal cual.

## Estado actual (local, sin nube)
- ✅ Pantalla de login al abrir la app.
- ✅ Crear cuenta con nombre + correo + contraseña.
- ✅ Botones "Continuar con Apple" y "Continuar con Google" (demo local).
- ✅ Cerrar sesión desde la pestaña **Más**.
- ✅ La sesión persiste al cerrar y reabrir la app.
- ⛔ Aún **no** sincroniza entre dispositivos (eso lo habilita Firebase).
