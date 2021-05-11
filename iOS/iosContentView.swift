//
//  ContentView.swift
//  Ditto Music (iOS)
//
//  Created by 陈语梵 on 2021/5/9.
//

import SwiftUI
import AVKit
import AVFoundation

struct TabBarAccessor: UIViewControllerRepresentable {
    var callback: (UITabBar) -> Void
    private let proxyController = ViewController()

    func makeUIViewController(context: UIViewControllerRepresentableContext<TabBarAccessor>) ->
                              UIViewController {
        proxyController.callback = callback
        return proxyController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<TabBarAccessor>) {
    }

    typealias UIViewControllerType = UIViewController

    private class ViewController: UIViewController {
        var callback: (UITabBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let tabBar = self.tabBarController {
                self.callback(tabBar.tabBar)
            }
        }
    }
}


struct SearchBarView: View {
    @State private var searchText = ""
    @State private var isEditing = false
    @EnvironmentObject var fetcher: SearchFetcher
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("search...", text: $searchText, onCommit: {
                isEditing = false
                fetcher.fetchSongsOf(keyword: searchText)
            })
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.searchText = ""
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
        .padding(7)
        .background(bgColor)
        .cornerRadius(8)
        .padding(.horizontal, 10)
        .onTapGesture {
            self.isEditing = true
        }
    }
    
    private let bgColor = Color(.systemGray6)
}

struct SearchTypeView : View {
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                Text("Songs")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(7)
                    .padding(.horizontal, 9)
                    .background(Color(.red))
                    .clipShape(Capsule())
                    .foregroundColor(Color.white)
                Text("Artists")
            }
        }
        .padding(5)
        .padding(.horizontal, 20)
    }
}

struct SearchView: View {
    @EnvironmentObject private var fetcher: SearchFetcher
    @EnvironmentObject private var player: SongPlayer
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBarView().environmentObject(fetcher)
                SearchTypeView()
                Divider()
                
                Spacer()
                List(fetcher.fetchedSongs) { song in
                    HStack {
                        Text(song.name).font(.body)
                        Spacer()
                        Text(song.artist_name).font(.caption).foregroundColor(.gray)
                    }.onTapGesture {
                        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                        impactHeavy.impactOccurred()
                        player.play(song: song.name, by: song.artist_name)
                    }
                }.listStyle(PlainListStyle())
                
            }
            .navigationTitle("Search")
        }
    }
}

struct MiniPlayerView: View {
    @EnvironmentObject private var player: SongPlayer
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "music.note").imageScale(.large)
                if (player.songQueue.isEmpty) {
                    Text("Not Playing")
                } else {
                    VStack(alignment: .leading) {
                        Text("\(player.songQueue[0].name)").font(.body)
                        Text("\(player.songQueue[0].artist_name)").font(.caption2).foregroundColor(.gray)
                    }
                }
                Spacer()
                if (player.player.rate <= 0) {
                    Image(systemName: "play.fill").imageScale(.large).onTapGesture {
                        if (!player.songQueue.isEmpty) {
                            player.player.play()
                        }
                    }
                } else {
                    
                    Spacer()
                    Image(systemName: "pause.fill").imageScale(.large).onTapGesture {
                        player.player.pause()
                    }
                    
                }
                Image(systemName: "forward.fill").imageScale(.large)
            }
            if !player.songQueue.isEmpty {
                Slider(
                    value: $player.currentPosition,
                    in: 0...1,
                    onEditingChanged: { _ in
                        guard let item = self.player.player.currentItem else {
                                  return
                        }
                        let targetTime = player.currentPosition * item.duration.seconds
                        self.player.player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 600))
                    }
                )
                
            }
            
        }
        .padding()
        .background(self.bgColor)
        .animation(.linear)
    }
    
    // Constants
    let bgColor = Color(.systemGray6)
}

struct iOSContentView: View {
    @State private var tabBarHeight: CGFloat = .zero
    @ObservedObject private var player = SongPlayer()
    @ObservedObject private var fetcher = SearchFetcher()
    
    
    var body: some View {
            TabView {
                SearchView().environmentObject(fetcher)
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .background(
                        TabBarAccessor { tabBar in tabBarHeight = tabBar.bounds.height }
                    )
            }.overlay(
                VStack {
                    Spacer()
                    MiniPlayerView()
                    Spacer()
                    .frame(height: tabBarHeight)
                }
                .edgesIgnoringSafeArea(.all)
            ).environmentObject(player)
    }
}

struct iOSContentView_Previews: PreviewProvider {
    static var previews: some View {
        iOSContentView()
    }
}
