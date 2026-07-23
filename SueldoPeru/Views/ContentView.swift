import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SueldoNetoView()
                .tabItem {
                    Label("Sueldo Neto", systemImage: "banknote")
                }

            GratificacionView()
                .tabItem {
                    Label("Gratificación", systemImage: "gift")
                }

            CTSView()
                .tabItem {
                    Label("CTS", systemImage: "building.columns")
                }

            AjustesView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
}
