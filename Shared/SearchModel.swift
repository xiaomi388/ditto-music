//
//  SearchModel.swift
//  Ditto Music
//
//  Created by 陈语梵 on 2021/5/8.
//

import Foundation


struct Song: Identifiable, Decodable {
    var artist_name: String
    var name: String
    var id: String {
        get {
            "\(artist_name)_\(name)"
        }
    }
}
