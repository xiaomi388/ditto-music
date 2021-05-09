//
//  SearchFetcher.swift
//  Ditto Music
//
//  Created by 陈语梵 on 2021/5/8.
//

import Foundation

class SearchFetcher : ObservableObject {
    @Published private(set) var fetchedSongs = [Song]()
    
    func fetchSongsOf(keyword: String) {
        var urlComps = URLComponents(string: "https://vms.n.xiaomi388.com:10443/v1/metadata/songs")!
        urlComps.queryItems = [URLQueryItem(name: "q", value: keyword)]
        if let url = urlComps.url {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: request) { data, response, error in
                // handle the result here.
                guard let data = data else {
                    print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                    return
                }
                if let songs = try? JSONDecoder().decode([Song].self, from: data) {
                    DispatchQueue.main.async {
                        self.fetchedSongs = songs
                    }
                } else {
                    print("Invalid response from server")
                }
            }.resume()
        }
    }
}
