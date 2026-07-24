import SwiftUI

@main
struct SueldoPeruApp: App {
    @StateObject private var sesion = Sesion()

    var body: some Scene {
        WindowGroup {
            Group {
                if sesion.usuario == nil {
                    AuthView()
                } else {
                    ContentView()
                }
            }
            .environmentObject(sesion)
        }
    }
}
