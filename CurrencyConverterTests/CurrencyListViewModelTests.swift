import XCTest
import Combine
@testable import CurrencyConverter

final class CurrencyListViewModelTests: XCTestCase {
    private let service = MockCurrencyService()
    private var viewModel: CurrencyListViewModel!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        viewModel = CurrencyListViewModel(
            service: service
        )
    }
    
    func testInitialization() throws {
        XCTAssertTrue(viewModel.currencyModels.isEmpty)
        XCTAssertEqual(viewModel.selectedModel.symbol, "EUR")
        XCTAssertEqual(viewModel.selectedModel.name, "Euro")
        XCTAssertTrue(viewModel.selectedModel.isTextFieldFocused)
        XCTAssertTrue(viewModel.selectedModel.isSelected)
    }
    
    func testLoadCurrencies() async throws {
        // Given
        let expectedSymbol = "EUR"
        let expectedName = "Euro"
        let expectedCurrencyModelsCount = 2
        let expectation = XCTestExpectation(description: "Currencies and selectedModel should be updated")
        expectation.expectedFulfillmentCount = 2

        // When
        viewModel.loadCurrencies()

        // Then
        viewModel.$selectedModel
            .sink { model in
                XCTAssertEqual(model.name, expectedName)
                XCTAssertEqual(model.symbol, expectedSymbol)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        viewModel.$currencyModels
            .drop(while: { $0.isEmpty })
            .sink { models in
                XCTAssertEqual(models.count, expectedCurrencyModelsCount)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testLoadCurrenciesWhenBaseSymbolIsChanged() async throws {
        // Given
        let expectedSymbol = "USD"
        let expectedCurrencyModelsCount = 2
        let expectation = XCTestExpectation(description: "Currencies should be loaded")
        expectation.expectedFulfillmentCount = 2

        // When
        viewModel.loadCurrencies()
        viewModel.loadCurrencies(base: expectedSymbol)
        
        // Then
        viewModel.$selectedModel
            .drop(
                while: { model in
                    return model.symbol != expectedSymbol
                }
            )
            .sink { model in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        viewModel.$currencyModels
            .drop(
                while: { models in
                    return models.isEmpty
                }
            )
            .sink { models in
                if models[0].symbol == "EUR" && models[1].symbol == "GBP" {
                    XCTAssertEqual(models.count, expectedCurrencyModelsCount)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        

        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testConvertedAmountsUpdated() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Converted amounts updated")

        // When
        viewModel.loadCurrencies()
        
        // Then
        viewModel.$currencyModels
            .drop(
                while: { models in
                    return models.isEmpty
                }
            )
            .sink { [weak self] models in
                guard let self else { return }
                models[0].$convertedAmount.sink { newValue in
                    if newValue == "1.54" {
                        expectation.fulfill()
                    }
                }.store(in: &cancellables)
                
                self.viewModel.selectedModel.baseAmount = "2"
            }
            .store(in: &cancellables)
        

        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testAutoRefresh() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Auto refresh should work")
        let timeout: TimeInterval = 4

        // When
        viewModel.startAutoRefresh()
        
        // Then
        viewModel.$currencyModels
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: timeout)
    }
    
    func testFetchErrorHandling() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Error handling should work")
        service.shouldFail = true

        // When
        viewModel.loadCurrencies()
        
        // Then
        viewModel.$showErrorAlert
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2.0)
    }
}
