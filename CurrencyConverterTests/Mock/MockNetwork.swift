import Foundation
@testable import CurrencyConverter

class MockNetwork: Network {
    let exchangeRatesString = """
    {"amount":1.0,"base":"AUD","date":"2025-01-31","rates":{"BGN":1.171,"BRL":3.6329,"CAD":0.90019,"CHF":0.56574,"CNY":4.5122,"CZK":15.0677,"DKK":4.4676,"EUR":0.59873,"GBP":0.50059,"HKD":4.8491,"HUF":244.25,"IDR":10143,"ILS":2.2272,"INR":53.88,"ISK":87.83,"JPY":96.39,"KRW":902.06,"MXN":12.8589,"MYR":2.7722,"NOK":7.0275,"NZD":1.1011,"PHP":36.332,"PLN":2.5225,"RON":2.9797,"SEK":6.8698,"SGD":0.84367,"THB":20.905,"TRY":22.312,"USD":0.62226,"ZAR":11.5907}}
    """
    
    let currenciesString = """
    {"AUD":"Australian Dollar","BGN":"Bulgarian Lev","BRL":"Brazilian Real","CAD":"Canadian Dollar","CHF":"Swiss Franc","CNY":"Chinese Renminbi Yuan","CZK":"Czech Koruna","DKK":"Danish Krone","EUR":"Euro","GBP":"British Pound","HKD":"Hong Kong Dollar","HUF":"Hungarian Forint","IDR":"Indonesian Rupiah","ILS":"Israeli New Sheqel","INR":"Indian Rupee","ISK":"Icelandic Króna","JPY":"Japanese Yen","KRW":"South Korean Won","MXN":"Mexican Peso","MYR":"Malaysian Ringgit","NOK":"Norwegian Krone","NZD":"New Zealand Dollar","PHP":"Philippine Peso","PLN":"Polish Złoty","RON":"Romanian Leu","SEK":"Swedish Krona","SGD":"Singapore Dollar","THB":"Thai Baht","TRY":"Turkish Lira","USD":"United States Dollar","ZAR":"South African Rand"}
    """
    
    func performRequest<T>(endpoint: Endpoint, decodingType: T.Type) async throws -> T where T: Decodable {
        let jsonString: String
        
        switch endpoint {
        case .exchangeRates:
            jsonString = exchangeRatesString
        case .currencies:
            jsonString = currenciesString
        }
        
        guard let decodedObject = decode(decodingType, from: jsonString) else {
            throw NSError(
                domain: "MockNetworkError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON"]
            )
        }
        
        return decodedObject
    }
    
    private func decode<T: Decodable>(_ type: T.Type, from jsonString: String) -> T? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: jsonData)
    }
}
