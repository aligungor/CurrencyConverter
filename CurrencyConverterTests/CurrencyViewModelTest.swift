import XCTest
import Combine
@testable import CurrencyConverter

final class CurrencyViewModelTests: XCTestCase {
    private var viewModel: CurrencyViewModel!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        viewModel = CurrencyViewModel(symbol: "EUR", name: "Euro")
    }
    
    func testBaseAmountFormat() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Amount format should be fixed")
        expectation.expectedFulfillmentCount = 1

        // When
        viewModel.updateBaseAmount("")
        
        // Then
        viewModel.$baseAmount
            .sink { newValue in
                if newValue == "10.50" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.updateBaseAmount("10,500")
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testRemoveLastCommaWhenBaseAmountHasAlreadyCents() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Amount format should be fixed")
        expectation.expectedFulfillmentCount = 1

        // When
        viewModel.updateBaseAmount("12,45")
        
        // Then
        viewModel.$baseAmount
            .sink { newValue in
                if newValue == "12.45" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.updateBaseAmount("12.45,")
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
}
