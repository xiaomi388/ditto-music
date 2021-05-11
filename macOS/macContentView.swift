//
//  ContentView.swift
//  Ditto Music (macOS)
//
//  Created by 陈语梵 on 2021/5/9.
//

import CoreData
import AppKit
import SwiftUI
import AVKit
import AVFoundation

struct SearchBarView: NSViewRepresentable {
    class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: SearchBarView
        
        init(_ parent: SearchBarView) {
            self.parent = parent
        }
        
        func controlTextDidChange(_ notification: Notification) {
//            guard let searchField = notification.object as? NSSearchField else {
//                return
//            }
        }
    
        func controlTextDidEndEditing(_ notification: Notification) {
            guard let searchField = notification.object as? NSSearchField else {
                return
            }
            
            if self.parent.search != searchField.stringValue {
                self.parent.search = searchField.stringValue
                self.parent.fetcher.fetchSongsOf(keyword: self.parent.search)
            }
        }
    }
    
    @Binding var search: String
    @EnvironmentObject var fetcher : SearchFetcher
    
    func makeNSView(context: Context) -> NSSearchField {
        let searchfield = NSSearchField(frame: .zero)
        searchfield.translatesAutoresizingMaskIntoConstraints = false
        searchfield.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        return searchfield
    }
    
    func changeSearchFieldItem(searchfield: NSSearchField, sender: AnyObject) -> NSSearchField {
        //Based on the Menu item selection in the search field the placeholder string is set
        (searchfield.cell as? NSSearchFieldCell)?.placeholderString = sender.title
        return searchfield
    }
    
    func updateNSView(_ searchField: NSSearchField, context: Context) {
        searchField.stringValue = search
        searchField.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}


struct SidebarView: View {
    @EnvironmentObject private var fetcher: SearchFetcher
    @EnvironmentObject private var player: SongPlayer
    
    @State var searchText: String = ""
    
    @State var isMainViewActive = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SearchBarView(search: $searchText)
            Text("Ditto Music").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).foregroundColor(Color(.lightGray)).font(.body)
            NavigationLink(destination: MainView(), isActive: $isMainViewActive) {
                HStack {
                    Image(systemName: "music.note.house")
                    Text("Browse")
                }.padding(.horizontal, 5)
            }.buttonStyle(PlainButtonStyle()).tag(0)
            Spacer()
        }.padding()
    }
}

struct PlayerView: View {
    @EnvironmentObject var player: SongPlayer
    
    var body: some View {
        HStack(alignment: .center) {
            Group {
                Image(systemName: "backward.fill").imageScale(.large)
                Image(systemName: "stop.fill").imageScale(.large)
            }
            Group {
                VStack {
                    if !player.songQueue.isEmpty {
                        VStack(spacing: 0) {
                            Text(player.songQueue[0].name)
                            Text(player.songQueue[0].artist_name).font(.caption)
                        }
                    } else {
                        Text("Not Playing")
                        Text("Search to Strat").font(.caption)
                    }
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
                    ).controlSize(.mini).disabled(player.songQueue.isEmpty)
                    
                }
            }
            
            Group {
                if player.player.rate > 0 {
                    Image(systemName: "pause.fill").imageScale(.large).onTapGesture {
                        player.player.pause()
                    }
                } else {
                    Image(systemName: "play.fill").imageScale(.large).onTapGesture {
                        player.player.play()
                    }
                }
                Image(systemName: "forward.fill").imageScale(.large)
            }
        }.frame(minWidth: 0, maxWidth: .infinity).animation(.linear)
    }
}

struct SearchListView: View {
    @EnvironmentObject var fetcher: SearchFetcher
    @EnvironmentObject var player: SongPlayer
    
    @State var currentSelected: Int? = nil
    
    var body: some View {
        if fetcher.lastSearchKeyword != "" {
            HStack(spacing: 0) {
                Text("Showing results for ").foregroundColor(Color(.lightGray))
                Text("\"\(fetcher.lastSearchKeyword)\"")
            }.padding(.horizontal)
            
            List {
                Section(header: HStack {
                    Text("name").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.title3).frame(minWidth: 0, maxWidth: .infinity)
                    Text("artist").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.title3).frame(minWidth: 0, maxWidth: .infinity)
                }) {
                    ForEach (fetcher.fetchedSongs.indices) { index in
                        HStack {
                            Text(fetcher.fetchedSongs[index].name).frame( minWidth: 0, maxWidth: .infinity)
                            Text(fetcher.fetchedSongs[index].artist_name).frame(minWidth: 0, maxWidth: .infinity)
                        }.foregroundColor(currentSelected == index ? Color.white : Color.black)
                        .contentShape(Rectangle())
                        .gesture(TapGesture(count: 2).onEnded {
                            player.play(song: fetcher.fetchedSongs[index].name, by: fetcher.fetchedSongs[index].artist_name)
                        })
                        .simultaneousGesture(TapGesture().onEnded {
                            currentSelected = index
                        })
                        .listRowBackground(
                            currentSelected == index ? Color(.systemRed) :
                                (index % 2 == 0) ?
                                Color(red: 0.96, green: 0.96, blue: 0.96) :   Color.white)
                    }
                }
            }
        } else {
            HStack {
                Text("Search to Start...").font(.headline)
            }.frame( minWidth: 0, maxWidth: .infinity,minHeight: 0, maxHeight: .infinity)
        }
    }
}

struct MainView: View {
    @EnvironmentObject var fetcher: SearchFetcher
    @EnvironmentObject var player: SongPlayer
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                PlayerView().padding(.horizontal)
                SearchListView()
            }
        }
    }
}

struct macContentView: View {
    @State private var tabBarHeight: CGFloat = .zero
    @ObservedObject private var player = SongPlayer()
    @ObservedObject private var fetcher = SearchFetcher()
    
    var body: some View {
        NavigationView {
            SidebarView()
        }
        .frame(minWidth: 800, minHeight: 600).background(Color.white)
        .environmentObject(fetcher).environmentObject(player)
    }
}

struct macContentView_Previews: PreviewProvider {
    static var previews: some View {
        macContentView()
    }
}
