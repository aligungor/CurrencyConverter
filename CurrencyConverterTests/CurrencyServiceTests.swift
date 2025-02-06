import XCTest
import Combine
@testable import CurrencyConverter

final class CurrencyServiceTests: XCTestCase {
    private var currencyService: CurrencyService!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        currencyService = DefaultCurrencyService(
            network: MockNetwork()
        )
    }
    
    func testFetchRates() async throws {
        // Given
        let givenBase = "AUD"
        
        // When
        let ratesResponse = try await currencyService.fetchRates(base: givenBase)
        
        // Then
        XCTAssertFalse(ratesResponse.rates.isEmpty)
    }
    
    func testFetchCurrencies() async throws {
        // When
        let currenciesResponse = try await currencyService.fetchCurrencies()
        
        // Then
        XCTAssertFalse(currenciesResponse.isEmpty)
    }
}
