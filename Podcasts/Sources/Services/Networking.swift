//
//  Networking.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/17.
//

import Foundation
import Combine
import os.log
import Alamofire
import FeedKit
import ComposableArchitecture

struct Networking {
    struct Failure: Error, Equatable {}

    var searchPodcasts: (String) -> Effect<SearchPodcastResult, Failure>
    var fetchPodcast: (URL) -> Effect<FetchPodcastResult, Failure>
    var downloadEpisode: (URL) -> Effect<URL, Failure>
}

private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}()

private let logger = Logger(subsystem: "com.bivre.podcasts", category: "Networking")

extension Networking {
    static let live = Networking(
        searchPodcasts: { searchText in
            Effect.run { subscriber in
                let escaped = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

                let mediaQueryItem: URLQueryItem? = URLQueryItem(name: "media", value: "podcast")
                let limitQueryItem: URLQueryItem? = URLQueryItem(name: "limit", value: "50")
                let countryQueryItem: URLQueryItem? = Locale.current.regionCode.flatMap { URLQueryItem(name: "country", value: $0) }
                let termQueryItem: URLQueryItem? = escaped.flatMap { URLQueryItem(name: "term", value: $0) }

                var component = URLComponents(string: "https://itunes.apple.com/search")!
                component.queryItems = [mediaQueryItem, countryQueryItem, termQueryItem, limitQueryItem]
                    .compactMap { $0 }

                logger.debug("\(component.url!)")

                let task = AF.request(component.url!).responseDecodable(of: SearchPodcastResult.self, decoder: decoder) { response in
                        if let error = response.error {
                            subscriber.send(completion: .failure(Failure()))
                        } else if let value = response.value {
                            subscriber.send(value)
                        }
                    }

                return AnyCancellable {
                    task.cancel()
                }
            }
        },
        fetchPodcast: { feedUrl in
            Effect.run { subscriber in
                let parser = FeedParser(URL: feedUrl)

                parser.parseAsync { result in
                    switch result {
                    case let .success(feed):
                        subscriber.send(FetchPodcastResult(feed.rssFeed!))
                    case let .failure(parserError):
                        subscriber.send(completion: .failure(Failure()))
                    }
                }

                return AnyCancellable {
                    parser.abortParsing()
                }
            }
        },
        downloadEpisode: { url in
            Effect.run { subscriber in
                let task = AF.download(url).response { response in
                    if let error = response.error {
                        subscriber.send(completion: .failure(Failure()))
                    } else if let url = response.fileURL {
                        logger.debug("\(url)")
                        subscriber.send(url)
                    }
                }

                return AnyCancellable {
                    task.cancel()
                }
            }
        }
    )
}

extension Networking {
    static let mock = Networking(
        searchPodcasts: { _ in
            Fail<SearchPodcastResult, Failure>(error: Failure())
                .eraseToEffect()
        },
        fetchPodcast: { _ in
            Fail<FetchPodcastResult, Failure>(error: Failure())
                .eraseToEffect()
        },
        downloadEpisode: { _ in
            Fail<URL, Failure>(error: Failure())
                .eraseToEffect()
        }
    )
}
