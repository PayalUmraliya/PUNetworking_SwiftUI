//
//  PhotoItemRepo.swift
//  PUNetworking

import Foundation


struct PhotoItemRepo: Identifiable, Decodable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let download_url: String
}
