//
//  HomeViewModel.swift

import Foundation
import Combine
import SwiftUI

class HomeViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()
    @Published var viewState: AppViewState = .loading
    @Published var PhotoItems = [PhotoItemRepo]()
    
    func fetchAllPhotos()
    {
        if !PhotoItems.isEmpty {
                return
            }
        self.viewState = .loading
        NetworkManager.shared.getData(url: "/v2/list", type: PhotoItemRepo.self)
        .sink { completion in
            switch completion {
            case .failure(let error):
                if let error = error as? URLError,
                   error.code == .timedOut {
                    self.viewState = .error(message: StringConstants.requestTimeout)
                } else {
                    self.viewState = .error(message: StringConstants.somethingWentWrong)
                }
            case .finished:
                print("Finished")
            }
        } receiveValue: { [weak self] responseData in
            self?.PhotoItems = responseData
            self?.viewState = .dataLoaded
        }
        .store(in: &cancellables)
    }
}
