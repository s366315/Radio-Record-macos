//
//  MainPresenter.swift
//  Record Player
//
//  Created by Евгений K on 23.04.2024.
//

import Foundation
import SwiftUI
import MediaPlayer

public class MainPresenter: ObservableObject {
    private let favouritesKey = "favourites"
    private static let baseUrl = "https://www.radiorecord.ru/api/"
    private let stationsUrl = "\(baseUrl)stations/"
    private let currentUrl = "\(baseUrl)stations/now/"
    
    private let player: AVPlayer
    private var isPlaying: Bool = false
    
    @Published var data: [StationData] = []
    @Published var searchText: String = ""
    @Published var stationState: StationData? = nil {
        willSet(newValue){
            if newValue != nil {
                setNowPlayingMetadata(metadata: newValue!)
            }
        }
    }
    @Published var windowTitleState: String = "Record"
    @Published var songPanelIsShowing = NavigationSplitViewVisibility.detailOnly
    @AppStorage("volume") var volumeState = 0.5
    
    init() {
        player = AVPlayer(playerItem: nil)
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        
        commandCenter.playCommand.addTarget { [self] (commandEvent) -> MPRemoteCommandHandlerStatus in
            onSpacePressed()
            return MPRemoteCommandHandlerStatus.success
        }
        
        commandCenter.pauseCommand.addTarget { [self] (commandEvent) -> MPRemoteCommandHandlerStatus in
            onSpacePressed()
            return MPRemoteCommandHandlerStatus.success
        }
    }
    
    var favouritesSet: Set<Int> {
        get {
            return UserDefaults.standard.object(forKey: favouritesKey) as? Set<Int> ?? Set<Int>()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: favouritesKey)
        }
    }
    
    var filteredStations: [StationData] {
        guard !searchText.isEmpty else { return data }
        return data.filter { station in
            station.title.lowercased().contains(searchText.lowercased())
        }
    }
    
    //MARK: Public functions
    
    func onAppear() {
        guard let url = URL(string: stationsUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let posts = try JSONDecoder().decode(StationResultModel.self, from: data)
                DispatchQueue.main.async {
                    self.data = posts.result.stations.map { $0.map() }
                    self.updateTracks()
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func onVolumeChange(volume: Double) {
        player.volume = Float(volume)
    }
    
    func onStopClick() {
        stop()
    }
    
    func onPlayClick() {
        if isPlaying { return }
        guard let station = stationState else { return }
        play(station: station)
    }
    
    func onStationClick(station: StationData) {
        stationState = station
        windowTitleState = "Record - \(station.title)"
        onUpdateTracks()
        play(station: station)
        songPanelIsShowing = .automatic
    }
    
    func onSetFav(to id: Int) {
        print(id)
    }
    
    func onHotkeyPressed(shortcutState: Shortcuts) {
        let shortcutState = shortcutState
        
        switch(shortcutState) {
            case .play:
                play(station: stationState)
                break
            case .stop:
                stop()
                break
            case .next:
                for (index, item) in data.enumerated() {
                    if (item.id == stationState?.id) {
                        let nextIndex = index == (data.count - 1) ? 0 : index + 1
                        let station = data[nextIndex]
                        onStationClick(station: station)
                        break
                    }
                }
                break
            case .previous:
                for (index, item) in data.enumerated() {
                    if (item.id == stationState?.id) {
                        let nextIndex = index == 0 ? (data.count - 1 ) : index - 1
                        let station = data[nextIndex]
                        onStationClick(station: station)
                        break
                    }
                }
                break
            case .up:
                if volumeState < 1 {
                    volumeState += 0.1
                }
                break
            case .down:
                if volumeState > 0 {
                    volumeState -= 0.1
                }
                break
            case .none:
                print()
                break
        }
    }
    
    func onShareClick() {
        guard let station = stationState else { return }
        copyToClipboard(string: "\(station.shareUrl)")
    }
    
    func onClipboardClick() {
        guard let station = stationState else { return }
        copyToClipboard(string: "\(station.artist) - \(station.song)")
    }
    
    func onSpacePressed() {
        guard let station = stationState else { return }
        isPlaying ? stop() : onStationClick(station: station)
    }
    
    //MARK: Private functions
    
    private func updateTracks() {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { timer in self.onUpdateTracks() })
    }
    
    private func updateCurrentTrack() {
        data.forEach { item in
            if item.id == stationState?.id {
                stationState = item
            }
        }
    }
    
    private func getStationUrl(station: StationData) -> String {
        let prefix = if (station.prefix == "record") {
            "record"
        } else {
<<<<<<< HEAD
            "record-\(station.prefix.replacingOccurrences(of: "-", with: ""))"
=======
            "record-\(stationsMap[station.prefix] ?? "")"
>>>>>>> main
        }
        print(prefix)
        return "https://hls-01-radiorecord.hostingradio.ru/\(prefix)/playlist.m3u8"
    }
    
    private func onUpdateTracks() {
        guard let url = URL(string: currentUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let posts = try JSONDecoder().decode(NowModel.self, from: data)
                DispatchQueue.main.async {
                    let now = posts.result
                    
                    self.data = self.data.map { item in
                        let newItem = now.first(where: { $0.id == item.id})?.track
                        
                        return StationData(
                            id: item.id,
                            title: item.title,
                            prefix: item.prefix,
                            svg: item.svg,
                            artist: newItem?.artist ?? String(),
                            song: newItem?.song ?? String(),
                            isFav: false,
                            image: newItem?.image200 ?? String(),
                            shareUrl: newItem?.shareUrl ?? String()
                        )
                    }
                    
                    self.updateCurrentTrack()
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    private func setNowPlayingMetadata(metadata: StationData) {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = Float(player.currentItem?.duration.seconds ?? 0)
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Float(player.currentItem?.currentTime().seconds ?? 0)
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.artist
        nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.song
        let image = NSImage(named: "DefaultTrack_600")!
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    private func play(station: StationData?) {
        guard let station = station else { return }
        isPlaying = true
        playerPlay(station: getStationUrl(station: station))
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    private func stop() {
        isPlaying = false
        player.pause()
        MPNowPlayingInfoCenter.default().playbackState = .stopped
    }
    
    private func playerPlay(station: String) {
        let url = URL(string: station)
        let playerItem = AVPlayerItem(url: url!)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        player.volume = Float(volumeState)
    }
    
    private func copyToClipboard(string: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(string, forType: .string)
    }
}

extension View {
    
    func renderAsImage() -> NSImage? {
        let view = NoInsetHostingView(rootView: self)
        view.setFrameSize(view.fittingSize)
        return view.bitmapImage()
    }

}

class NoInsetHostingView<V>: NSHostingView<V> where V: View {
    
    override var safeAreaInsets: NSEdgeInsets {
        return .init()
    }
    
}

public extension NSView {
    
    func bitmapImage() -> NSImage? {
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        cacheDisplay(in: bounds, to: rep)
        guard let cgImage = rep.cgImage else {
            return nil
        }
        return NSImage(cgImage: cgImage, size: bounds.size)
    }
    
}
