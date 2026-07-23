import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SueldoNetoView()
                .tabItem {
                    Label("Sueldo Neto", systemImage: "banknote")
                }

            ComparadorView()
                .tabItem {
                    Label("Comparar", systemImage: "arrow.left.arrow.right")
                }

            GratificacionView()
                .tabItem {
                    Label("Gratificación", systemImage: "gift")
                }

            CTSView()
                .tabItem {
                    Label("CTS", systemImage: "building.columns")
                }

            MasView()
                .tabItem {
                    Label("Más", systemImage: "ellipsis.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
