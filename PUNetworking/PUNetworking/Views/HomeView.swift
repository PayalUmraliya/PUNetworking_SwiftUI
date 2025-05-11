//
//  HomeView.swift
//  PUNetworking


import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var navigateToNewView = false
    @State private var isDataLoaded = false
    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.viewState {
                case .loading:
                    ProgressView(StringConstants.fetchingRecords)
                case .error(let message):
                    Text(message)
                        .foregroundColor(.red)
                case .dataLoaded:
                    HomeContent
                }
            }
            .navigationTitle("Home - (GET Request)")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        navigateToNewView = true
                                    }) {
                                        Image(systemName: "plus")
                                    }
                                }
                        }
            .navigationDestination(isPresented: $navigateToNewView) {
                ProductView()
                        }
            .onAppear {
                if !isDataLoaded && viewModel.PhotoItems.isEmpty {
                       isDataLoaded = true
                       viewModel.fetchAllPhotos()
                   }
            }
        }
        .accentColor(.pink)
    }

    private var HomeContent: some View {
        VStack(alignment: .leading) {
            List(viewModel.PhotoItems) { photo in
                VStack(alignment: .leading) {
                    Text(photo.author)
                        .font(.headline)
                    AsyncImage(url: URL(string: photo.download_url)) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        ProgressView()
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                    case .failure:
                                                        Image(systemName: "photo")
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                }
                .padding(.vertical, 8)
            }
            .listStyle(.plain)
        }
    }
}


#Preview {
    HomeView()
}
