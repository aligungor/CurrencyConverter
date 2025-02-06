@testable import CurrencyConverter

enum MockError: Error {
    case failedToFetchRates
}

class MockCurrencyService: CurrencyService {
    var shouldFail: Bool = false
    var mockRatesResponses: [Symbol: ExchangeRatesResponse] = [
        "EUR": ExchangeRatesResponse(
            amount: 1.0,
            base: "EUR",
            rates: [
                "USD": 0.89,
                "GBP": 0.77
            ]
        ),
        "USD": ExchangeRatesResponse(
            amount: 1.0,
            base: "USD",
            rates: [
                "EUR": 1.11,
                "GBP": 0.81
            ]
        ),
        "GBP": ExchangeRatesResponse(
            amount: 1.0,
            base: "GBP",
            rates: [
                "EUR": 1.31,
                "USD": 1.20
            ]
        )
    ]
    
    let mockCurrenciesResponse: CurrenciesResponse = [
        "EUR": "Euro",
        "USD": "US Dollar",
        "GBP": "Pound Sterling"
    ]
    
    func fetchRates(base: Symbol) async throws -> ExchangeRatesResponse {
        guard !shouldFail else {
            throw MockError.failedToFetchRates
        }
        return mockRatesResponses[base]!
    }

    func fetchCurrencies() async throws -> CurrenciesResponse {
        return mockCurrenciesResponse
    }
}

