import Foundation

extension NSNumber {
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        return formatter
    }
    
    var currencyFormatted: String? {
        currencyFormatter.string(from: self)
    }
}
