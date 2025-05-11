//
//  PostProductViewModel.swift
//  PUNetworking


import Foundation
import SwiftUI
import Combine
class ProductViewModel: ObservableObject {
    @Published var statusMessage: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    func postProduct(_ product: ProductRepo) {
        NetworkManager.shared.postData(
            urlString: "/products",
            body: product,
            responseType: ProductRepo.self
        )
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                self.statusMessage = "Product posted successfully!"
            case .failure(let error):
                self.statusMessage = "Error: \(error.localizedDescription)"
            }
        }, receiveValue: { response in
            print("Posted product response: \(response)")
        })
        .store(in: &cancellables)
    }
}
