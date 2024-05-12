//
//  ContentView.swift
//  Record Player
//
//  Created by Евгений K on 21.04.2024.
//

import SwiftUI
import AVKit


struct MainView: View {
    
    @ObservedObject var presenter: MainPresenter
    
    @State private var isPlaying: Bool = false
    @State private var selection = "All"
    
    private let categories = ["All", "Favourites"]
    
    init(presenter: MainPresenter) {
        self.presenter = presenter
    }
    
    var body: some View {
<<<<<<< HEAD:Record Player/view/MainView.swift
        NavigationSplitView(columnVisibility: $presenter.songPanelIsShowing) {
            VStack() {
                if presenter.stationState != nil {
                    AsyncImage(url: URL(string: presenter.stationState?.image ?? "")) { image in
                        if let image = image.image {
                            image.resizable()
                        } else if image.error != nil {
                            Image("DefaultTrack_600")
                                .resizable()
                        }
=======
        List(presenter.filteredStations, id: \.id) { station in
            StationItem(
                id: station.id,
                title: station.title,
                artist: station.artist,
                song: station.song,
                svg: station.svg,
                isFav: false,
                onFav: presenter.onSetFav
            ).contentShape(Rectangle())
                .onTapGesture {
                    isPlaying = true
                    windowTitleState = "Record - \(station.title)"
                    playerPlay(station: presenter.onStationClick(station: station))
                }
        }
        .onAppear { presenter.onAppear() }
        .onChange(of: volumeState, perform: setPlayerVolume)
        .onChange(of: shortcutState) { newValue in
            print(newValue)
            if (newValue == Shortcuts.up) {
                setPlayerVolume(to: volumeState + 0.1)
            }
            if (newValue == Shortcuts.up) {
                setPlayerVolume(to: volumeState - 0.1)
            }
        }
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(keys: [.space]) { press in
            isPlaying ? player.pause() : player.play()
            isPlaying = !isPlaying
            return .handled
        }
        .navigationTitle(windowTitleState)
        .toolbar{
            ToolbarItemGroup(placement: .primaryAction) {
                Picker("Select categorie", selection: $selection) {
                    ForEach(categories, id: \.self) {
                        Text($0)
>>>>>>> main:Record Player/view/ContentView.swift
                    }
                    .frame(width: songCoverWH, height: songCoverWH)
                    .scaledToFit()
                    .animation(Animation.default.speed(1))
                    Text(presenter.stationState?.artist ?? "").padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    Text(presenter.stationState?.song ?? "").padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    HStack{
                        Image(systemName: "square.and.arrow.up").help("Share track link").onTapGesture {
                            presenter.onShareClick()
                        }
                        Image(systemName: "list.bullet.clipboard").help("Copy trackname to clipboard").onTapGesture {
                            presenter.onClipboardClick()
                        }
                    }.padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .navigationSplitViewColumnWidth(songPanelW)
            .frame(alignment: .top)
        } detail: {
            List(presenter.filteredStations, id: \.self, selection: $presenter.stationState) { station in
                StationItem(
                    id: station.id,
                    title: station.title,
                    artist: station.artist,
                    song: station.song,
                    svg: station.svg,
                    isFav: false,
                    onFav: presenter.onSetFav
                )
                .contentShape(Rectangle())
                .onTapGesture { presenter.onStationClick(station: station) }
            }
            .onAppear { presenter.onAppear() }
            .focusable()
            .focusEffectDisabled()
            .onChange(of: presenter.volumeState, { presenter.onVolumeChange(volume: presenter.volumeState) })
            .onKeyPress(keys: [.space]) { press in
                presenter.onSpacePressed()
                return .handled
            }
            .navigationTitle(presenter.windowTitleState)
            .toolbar{
                ToolbarItemGroup(placement: .primaryAction) {
                    /*Picker("Select categorie", selection: $selection) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                    .disabled(true)
                    .pickerStyle(.menu)*/
                    TextField("Filter", text: $presenter.searchText)
                        .frame(width: 100)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: presenter.onStopClick) {
                        Label("Stop", systemImage: "stop.fill")
                    }
                    Button(action: presenter.onPlayClick) {
                        Label("Play", systemImage: "play.fill")
                    }
<<<<<<< HEAD:Record Player/view/MainView.swift
                    Slider(value: $presenter.volumeState, in: 0...1)
                        .frame(width: 100)
                }
=======
                Slider(value: $volumeState, in: 0...1)
                    .frame(width: 100)
>>>>>>> main:Record Player/view/ContentView.swift
            }
        }
    }
}

#Preview {
    MainView(presenter: MainPresenter())
}
