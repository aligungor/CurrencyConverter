import Foundation
import Combine

// MARK: Class
final class CurrencyListViewModel: ObservableObject {
    // MARK: Constants
    private enum Constants {
        static let defaultBaseCurrency: Symbol = "EUR"
        static let defaultBaseCurrencyName: CurrencyName = "Euro"
        static let autoRefreshInterval: TimeInterval = 3
    }
    
    // MARK: Variables
    private let service: CurrencyService
    private var cancellables: Set<AnyCancellable> = []
    private var selectedModelCancellable: AnyCancellable?
    private var timerCancellable: AnyCancellable?
    private var currencyModelsDictionary = [Symbol: CurrencyViewModel]() {
        didSet {
            currencyModels = currencyModelsDictionary.values.sorted {
                $0.name < $1.name
            }
        }
    }
    @Published var selectedModel = CurrencyViewModel(
        symbol: Constants.defaultBaseCurrency,
        name: Constants.defaultBaseCurrencyName,
        isSelected: true
    )
    @Published var currencyModels = [CurrencyViewModel]()
    @Published var showLoader = false
    @Published var showErrorAlert = false
    
    // MARK: Lifecycle
    init(service: CurrencyService = DefaultCurrencyService()) {
        self.service = service
    }
    
    deinit {
        stopAutoRefresh()
    }
    
    // MARK: Implementation
    func loadCurrencies(base: Symbol = Constants.defaultBaseCurrency) {
        showLoader = currencyModels.isEmpty
        Task { [weak self] in
            guard let self else { return }
            do {
                async let ratesResponse = service.fetchRates(base: base)
                async let currenciesResponse = service.fetchCurrencies()

                let (rates, currencies) = try await (ratesResponse, currenciesResponse)
                
                await self.updateCurrencyModels(
                    ratesResponse: rates,
                    currenciesResponse: currencies
                )
            } catch {
                self.showErrorAlert = true
                print(error.localizedDescription)
            }
        }
    }
    
    func startAutoRefresh() {
        timerCancellable = Timer
            .publish(every: Constants.autoRefreshInterval, on: .main, in: .common)
            .autoconnect()
            .delay(for: .seconds(3), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.loadCurrencies(base: self.selectedModel.symbol)
            }
    }
    
    func stopAutoRefresh() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    // MARK: Private
    @MainActor
    private func updateCurrencyModels(
        ratesResponse: ExchangeRatesResponse,
        currenciesResponse: [Symbol: CurrencyName]
    ) {
        showLoader = false
        let isSelectedCurrencyChanged = ratesResponse.base != selectedModel.symbol
        
        if isSelectedCurrencyChanged {
            selectedModel = createSelectedModel(
                ratesResponse: ratesResponse,
                currenciesResponse: currenciesResponse
            )
        }
        
        if isSelectedCurrencyChanged || currencyModelsDictionary.isEmpty {
            currencyModelsDictionary = createCurrencyModels(
                ratesResponse: ratesResponse,
                currenciesResponse: currenciesResponse
            )
        } else {
            ratesResponse.rates.forEach { (symbol, rate) in
                currencyModelsDictionary[symbol]?.rate = rate
            }
        }
        
        selectedModelCancellable?.cancel()
        selectedModelCancellable = nil
        selectedModelCancellable = selectedModel.$baseAmount
            .sink { [weak self] amount in
                self?.currencyModels.forEach { model in
                    model.baseAmount = amount
                }
            }
    }
    
    private func createCurrencyModels(
        ratesResponse: ExchangeRatesResponse,
        currenciesResponse: CurrenciesResponse
    ) -> [Symbol: CurrencyViewModel] {
        var models = [Symbol: CurrencyViewModel]()
        
        ratesResponse.rates.forEach { (symbol, rate) in
            if let name = currenciesResponse[symbol] {
                let model = CurrencyViewModel(
                    symbol: symbol,
                    name: name,
                    rate: rate,
                    base: ratesResponse.base,
                    isSelected: false
                )
                models[symbol] = model
            }
        }
        
        return models
    }
    
    private func createSelectedModel(
        ratesResponse: ExchangeRatesResponse,
        currenciesResponse: CurrenciesResponse
    ) -> CurrencyViewModel {
        let model = CurrencyViewModel(
            symbol: ratesResponse.base,
            name: currenciesResponse[ratesResponse.base] ?? "",
            base: ratesResponse.base,
            isSelected: true
        )
        return model
    }
}
