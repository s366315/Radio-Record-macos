//
//  StationItem.swift
//  Record Player
//
//  Created by Евгений K on 22.04.2024.
//

import SwiftUI

struct StationItem: View {
    var id: Int
    var title: String
    var artist: String
    var song: String
    var svg: String
    @State var isFav: Bool
    var onFav: (Int) -> Void
    
    var body: some View {
        HStack {
            /*SVGWebView(svg: svg)
                .frame(width: 40, height: 40)*/
            Text(title)
            Image(systemName: (isFav ? "star.fill" : "star"))
                .onTapGesture {
                    onFav(self.id)
                    
                    isFav.toggle()
                }
        }.frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: stationItemHeight,
            maxHeight: .infinity,
            alignment: .leading)
    }
}
