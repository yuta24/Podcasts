//
//  ImageView.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/17.
//

import SwiftUI
import Nuke
import FetchImage

struct ImageView: View {
    @ObservedObject var image: FetchImage

    var body: some View {
        ZStack {
            Rectangle().fill(Color.gray)
            image.view?
                .resizable()
                .aspectRatio(contentMode: .fill)
        }

        // (Optional) Animate image appearance
        .animation(.default)

        // (Optional) Cancel and restart requests during scrolling
        .onAppear(perform: image.fetch)
        .onDisappear(perform: image.cancel)
    }
}
