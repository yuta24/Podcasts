//
//  Seeker.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/30.
//

import SwiftUI

extension Component {
    struct Seeker: View {
        @Binding var position: Int
        let range: ClosedRange<Int>

        var body: some View {
            VStack {
                GeometryReader { proxy in
                    ZStack {
                        Rectangle().frame(width: proxy.size.width, height: 2)

                        Circle().frame(width: 4, height: 4)
                    }
                }

                HStack {
                    Text("\(range.first!)")
                        .font(.caption)

                    Spacer()

                    Text("\(range.last!)")
                        .font(.caption)
                }
            }
        }
    }
}

struct ComponentSeeker_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            Component.Seeker(position: .constant(10), range: 0...20)
        }
    }
}
