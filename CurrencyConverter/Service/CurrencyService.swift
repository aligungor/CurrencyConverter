// MARK: Protocol
protocol CurrencyService {
    func fetchRates(base: Symbol) async throws -> ExchangeRatesResponse
    func fetchCurrencies() async throws -> CurrenciesResponse
}

// MARK: Class
final class DefaultCurrencyService: CurrencyService {
    // MARK: Variables
    private let network: Network
    
    // MARK: Lifecycle
    init(network: Network = DefaultNetwork()) {
        self.network = network
    }
    
    // MARK: Implementation
    func fetchRates(base: Symbol) async throws -> ExchangeRatesResponse {
        return try await network.performRequest(
            endpoint: .exchangeRates(base: base),
            decodingType: ExchangeRatesResponse.self
        )
    }
    
    func fetchCurrencies() async throws -> CurrenciesResponse {
        return try await network.performRequest(
            endpoint: .currencies,
            decodingType: CurrenciesResponse.self
        )
    }
}
