import Foundation
import Combine

// MARK: Class
final class CurrencyViewModel: ObservableObject, Identifiable {
    // MARK: Variables
    let id = UUID()
    let symbol: String
    var conversion: String {
        "1 \(base) = \(String(format: "%.2f", rate))"
    }
    let name: String
    let base: String
    var rate: Double {
        didSet {
            updateConvertedAmount()
        }
    }
    @Published var baseAmount: String {
        didSet {
            updateConvertedAmount()
        }
    }
    @Published var convertedAmount: String
    var isSelected: Bool
    @Published var isTextFieldFocused: Bool = false

    // MARK: Lifecycle
    init(
        symbol: String,
        name: String,
        rate: Double = 1,
        base: String = "",
        baseAmount: String = "",
        isSelected: Bool = false
    ) {
        self.symbol = symbol
        self.name = name
        self.rate = rate
        self.base = base
        self.baseAmount = baseAmount
        self.isSelected = isSelected
        self.convertedAmount = baseAmount
        if isSelected {
            self.isTextFieldFocused = true
        }
    }
    
    // MARK: Implementation
    public func updateBaseAmount(_ newValue: String) {
        if newValue.contains(".") && newValue.hasSuffix(",") {
            baseAmount = String(newValue.dropLast(1))
            return
        }
        
        let commaReplaced = newValue.replacingOccurrences(of: ",", with: ".")
        if commaReplaced.contains(".") &&
            commaReplaced.split(separator: ".").count > 1 &&
            commaReplaced.split(separator: ".").last?.count ?? 0 > 2 {
            baseAmount = String(commaReplaced.dropLast(1))
        } else {
            baseAmount = commaReplaced
        }
    }

    // MARK: Private
    private func updateConvertedAmount() {
        let baseValue = Double(baseAmount) ?? 1.0
        let number = NSNumber(value: baseValue * rate)
        convertedAmount = number.currencyFormatted ?? ""
    }
}
