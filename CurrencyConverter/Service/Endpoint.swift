import Foundation

enum Endpoint {
    case exchangeRates(base: String)
    case currencies
    
    var url: URL? {
        switch self {
        case .exchangeRates(let base):
            return URL(string: "https://api.frankfurter.app/latest?base=\(base)")
        case .currencies:
            return URL(string: "https://api.frankfurter.dev/v1/currencies")
        }
    }
}
