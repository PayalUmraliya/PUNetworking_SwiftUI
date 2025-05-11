//
//  NewView.swift
//  PUNetworking

import SwiftUI
struct ProductView: View {
    @StateObject private var viewModel = ProductViewModel()

    let product = ProductRepo(
        id: 0,
            title: "Test Product",
        price: 0.1,
            description: "This is a test.",
            image: "http://example.com",
            category: "electronics"
        )
        var body: some View {
            VStack(spacing: 20) {
                Text("Post a Product")
                    .font(.title)
                
                Button("Submit Product") {
                    viewModel.postProduct(product)
                }
                .buttonStyle(.borderedProminent)
                
                if !viewModel.statusMessage.isEmpty {
                    Text(viewModel.statusMessage)
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Product (POST Request)")
        }
}
