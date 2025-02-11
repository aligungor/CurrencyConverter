import SwiftUI

// MARK: Struct
struct CurrencyView: View {
    // MARK: Variables
    @ObservedObject var model: CurrencyViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    // MARK: Lifecycle
    var body: some View {
        HStack {
            setupLeftSideTexts()

            Spacer()
            
            if model.isSelected {
                setupTextField()
            } else {
                setupCalculationTexts()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .background(model.isSelected ?  Color.selectedCurrencyBackground : Color.currencyBackground)
        .cornerRadius(8)
    }

    private func setupLeftSideTexts() -> some View {
        VStack(alignment: .leading) {
            Text(model.symbol)
                .font(.headline)
                .foregroundStyle(model.isSelected ? .white : Color.primary)
            Text(model.name)
                .font(.subheadline)
                .foregroundStyle(model.isSelected ? .white : Color.secondary)
        }
    }

    private func setupCalculationTexts() -> some View {
        VStack(alignment: .trailing) {
            Text(model.convertedAmount)
                .foregroundStyle(Color.primary)
            Text(model.conversion)
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
    }

    private func setupTextField() -> some View {
        TextField("", text: $model.baseAmount)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .foregroundColor(.white)
            .font(.title2)
            .background(Color.clear)
            .frame(minWidth: 50, maxWidth: .infinity, alignment: .trailing)
            .tint(Color.white)
            .focused($isTextFieldFocused)
            .onAppear {
                isTextFieldFocused = model.isTextFieldFocused
            }
            .onChange(of: model.isTextFieldFocused) { _, newValue in
                isTextFieldFocused = model.isTextFieldFocused
            }
            .onChange(of: isTextFieldFocused) { _, newValue in
                model.isTextFieldFocused = newValue
            }
            .onChange(of: model.baseAmount) { _, newValue in
                model.updateBaseAmount(newValue)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button("Done") {
                        model.isTextFieldFocused = false
                    }
                }
            }
    }
}

// MARK: Preview
#Preview {
    let selectedModel = CurrencyViewModel(
        symbol: "EUR",
        name: "Euro",
        rate: 1.123123231,
        base: "EUR",
        baseAmount: "",
        isSelected: true
    )
    CurrencyView(model: selectedModel)
        .padding()
        .background(Color.listBackground)
    
    let model = CurrencyViewModel(
        symbol: "USD",
        name: "USD Dollar",
        rate: 1.123123231,
        base: "EUR",
        baseAmount: "2",
        isSelected: false
    )
    CurrencyView(model: model)
        .padding()
        .background(Color.listBackground)
}
