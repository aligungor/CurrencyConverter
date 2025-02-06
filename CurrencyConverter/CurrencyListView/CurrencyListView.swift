import SwiftUI

// MARK: View
struct CurrencyListView: View {
    // MARK: Constants
    private enum Constants {
        static let listItemPadding = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    }
    
    // MARK: Variables
    @StateObject private var viewModel = CurrencyListViewModel()
    
    // MARK: Lifecycle
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    setupSelectedCurrencyView()
                    setupList()
                }
                setupProgressView()
            }
            .navigationTitle("Currency Converter")
            .task {
                viewModel.loadCurrencies()
            }
            .onAppear() {
                viewModel.startAutoRefresh()
            }
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) {
                viewModel.showErrorAlert = false
            }
        } message: {
            Text("Currencies could not be loaded.")
        }
    }
    
    // MARK: Setup
    @ViewBuilder
    private func setupSelectedCurrencyView() -> some View {
        CurrencyView(model: viewModel.selectedModel)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .padding(Constants.listItemPadding)
    }
    
    @ViewBuilder
    private func setupList() -> some View {
        ScrollViewReader { proxy in
            List {
                ForEach(viewModel.currencyModels) { model in
                    CurrencyView(model: model)
                        .id(model.id)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .padding(Constants.listItemPadding)
                        .onTapGesture {
                            viewModel.loadCurrencies(base: model.symbol)
                            withAnimation {
                                proxy.scrollTo(viewModel.currencyModels.first?.id)
                            }
                        }
                }
            }
            .simultaneousGesture(
                DragGesture().onChanged({ _ in
                    viewModel.selectedModel.isTextFieldFocused = false
                })
            )
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
    
    @ViewBuilder
    private func setupProgressView() -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .selectedCurrencyBackground))
              .scaleEffect(1.0, anchor: .center)
              .isHidden(!viewModel.showLoader)
    }
}

// MARK: Preview
#Preview {
    CurrencyListView()
}
