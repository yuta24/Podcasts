//
//  PodcastItemView.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/23.
//

import SwiftUI
import Core

extension Component {
    struct PodcastItemView: View {
        enum Item {
            case podcast(Podcast)
            case podcastExt(PodcastExt)

            var name: String? {
                switch self {
                case .podcast(let value):
                    return value.trackName
                case .podcastExt(let value):
                    return value.title
                }
            }

            var imageUrl: URL? {
                switch self {
                case .podcast(let value):
                    return value.artworkUrl600.flatMap(URL.init(string:))
                case .podcastExt(let value):
                    return value.imageUrl
                }
            }

            var episodeCount: Int? {
                switch self {
                case .podcast(let value):
                    return value.trackCount
                case .podcastExt(let value):
                    return value.episodes.count
                }
            }
        }

        let item: Item

        var body: some View {
            HStack {
                item.imageUrl.flatMap {
                    ImageView(image: .init(url: $0))
                }
                .frame(width: 72, height: 72)
                .cornerRadius(8)

                VStack(alignment: .leading) {
                    item.name.flatMap(Text.init)
                        .lineLimit(.none)
                        .font(.headline)
                        .foregroundColor(Color(.label))
                    item.episodeCount.map { "\($0) episodes" }
                        .flatMap(Text.init)
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))

                    Spacer()
                }

                Spacer()
            }
        }
    }
}
