import SwiftUI

@main
struct CurrencyConverterApp: App {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(Color.navigationBackground)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.titleText]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.titleText]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            CurrencyListView()
        }
    }
}
