//
//  Networking.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/17.
//

import Foundation
import Combine
import OSLog
import FeedKit

struct Networking {
    struct Failure: Error, Equatable {}

    var search: (String) -> AnyPublisher<SearchPodcastResult, Failure>
    var fetchPodcast: (URL) -> AnyPublisher<FetchPodcastResult, Failure>
}

private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}()

private let logger = Logger(subsystem: "com.bivre.podcasts", category: "Networking")

extension Episode {
    init(_ feed: RSSFeedItem) {
        self.title = feed.title
        self.desc = feed.description
        self.pubDate = feed.pubDate
        self.link = feed.link.flatMap(URL.init(string:))
        self.subtitle = feed.iTunes?.iTunesSubtitle
        self.duration = feed.iTunes?.iTunesDuration
        self.enclosure = feed.enclosure?.attributes?.url.flatMap(URL.init(string:))
    }
}

extension FetchPodcastResult {
    init(_ rss: RSSFeed) {
        self.title = rss.title
        self.desc = rss.description
        self.link = rss.link.flatMap(URL.init(string:))
        self.author = rss.iTunes?.iTunesAuthor
        self.imageUrl = rss.iTunes?.iTunesImage?.attributes?.href.flatMap(URL.init(string:))
        self.summary = rss.iTunes?.iTunesSummary
        self.episodes = rss.items?.compactMap(Episode.init) ?? []
    }
}

extension Networking {
    static let live = Networking(
        search: { searchText in
            let escaped = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

            let mediaQueryItem: URLQueryItem? = URLQueryItem(name: "media", value: "podcast")
            let limitQueryItem: URLQueryItem? = URLQueryItem(name: "limit", value: "50")
            let countryQueryItem: URLQueryItem? = Locale.current
                .regionCode
                .flatMap {
                    URLQueryItem(name: "country", value: $0)
                }
            let termQueryItem: URLQueryItem? = escaped.flatMap {
                URLQueryItem(name: "term", value: $0)
            }

            var component = URLComponents(string: "https://itunes.apple.com/search")!
            component.queryItems = [mediaQueryItem, countryQueryItem, termQueryItem, limitQueryItem]
                .compactMap { $0 }

            logger.debug("\(component.url!)")

            return URLSession.shared.dataTaskPublisher(for: component.url!)
                .map(\.data)
                .decode(type: SearchPodcastResult.self, decoder: decoder)
                .mapError { _ in Failure() }
                .eraseToAnyPublisher()
        },
        fetchPodcast: { feedUrl in
            let parser = FeedParser(URL: feedUrl)

            return Deferred {
                Future<FetchPodcastResult, Failure> { callback in
                    parser.parseAsync { result in
                        switch result {
                        case let .success(feed):
                            debugPrint(feed)
                            callback(.success(FetchPodcastResult(feed.rssFeed!)))
                        case let .failure(parserError):
                            debugPrint("Failed to parse XML feed:", parserError)
                            callback(.failure(Failure()))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
        }
    )
}
