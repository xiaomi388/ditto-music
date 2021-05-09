//
//  SongPlayer.swift
//  Ditto Music
//
//  Created by 陈语梵 on 2021/5/8.
//

import Foundation
import AVKit
import AVFoundation

class SongPlayer : ObservableObject {
    @Published private(set) var player: AVQueuePlayer
    @Published private(set) var songQueue: [SongItem]
    @Published var currentPosition: Double = 0
    
    init() {
        player = AVQueuePlayer()
        songQueue = [SongItem]()
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { time in
            guard let item = self.player.currentItem else {
              return
            }
            self.currentPosition = time.seconds / item.duration.seconds
        }
    }
    
    func play(song name: String, by artist_name: String) {
        let queryItems = [URLQueryItem(name: "name", value: name), URLQueryItem(name: "artist", value: artist_name)]
        var urlComps = URLComponents(string: baseAPI)!
        urlComps.queryItems = queryItems
        let url = urlComps.url!
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player.removeAllItems()
        player.insert(playerItem, after: nil)
        player.play()
        let songItem = SongItem(playerItem: playerItem, name: name, artist_name: artist_name)
        songQueue = [songItem]
    }
    
    // MARK: - constant
    private let baseAPI = "https://vms.n.xiaomi388.com:10443/v1/song"
}

