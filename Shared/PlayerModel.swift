//
//  PlayerModel.swift
//  Ditto Music
//
//  Created by 陈语梵 on 2021/5/8.
//

import Foundation
import AVFoundation
import AVKit

struct SongItem {
    var playerItem: AVPlayerItem
    var name: String
    var artist_name: String
    var id: String {
        get {
            "\(artist_name)_\(name)"
        }
    }
}
