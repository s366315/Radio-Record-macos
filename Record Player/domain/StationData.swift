//
//  StationData.swift
//  Record Player
//
//  Created by Евгений K on 27.04.2024.
//

struct StationData: Equatable, Hashable {
    var id: Int
    var title: String
    var prefix: String
    var svg: String
    var artist: String
    var song: String
    var isFav: Bool
    var image: String
    var shareUrl: String
}
