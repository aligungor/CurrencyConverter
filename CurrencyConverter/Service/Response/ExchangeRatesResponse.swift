typealias Symbol = String
typealias Rates = [Symbol: Double]

struct ExchangeRatesResponse: Decodable {
    let amount: Double
    let base: Symbol
    let rates: Rates
}
