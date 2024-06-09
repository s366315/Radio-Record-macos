//
//  StationsResponseModel.swift
//  Record Player
//
//  Created by Евгений K on 22.04.2024.
//

struct StationModel: Codable {
    let id: Int
    let title: String
    let prefix: String
    let svg_outline: String
}

struct StationTagsModel: Codable {
    let stations: [StationModel]
}

struct StationResultModel: Codable {
    let result: StationTagsModel
}

extension StationModel {
    func map(_ favs: [Int]) -> StationData {
        let isFav = favs.contains(id)
        return StationData(id: id,
                           title: self.title,
                           prefix: self.prefix,
                           svg: "",//self.svg_outline,
                           artist: String(),
                           song: String(),
                           isFav: isFav,
                           image: String(),
                           shareUrl: String()
        )
    }
}
