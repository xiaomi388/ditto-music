//
//  ContentView.swift
//  Shared
//
//  Created by 陈语梵 on 2021/5/8.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(iOS)
        iOSContentView()
        #elseif os(macOS)
        macContentView()
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
