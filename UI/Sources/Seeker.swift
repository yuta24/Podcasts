//
//  Seeker.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/30.
//

import SwiftUI

struct Seeker: View {
    @Binding var position: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                ZStack {
                    Rectangle().frame(width: proxy.size.width, height: 4)
                        .background(Color(.secondarySystemBackground))
                        .opacity(0.8)

                    Circle().frame(width: 4, height: 4)
                }
            }
            .frame(height: 4)

            HStack {
                Text("\(range.first!)")
                    .font(.caption)

                Spacer()

                Text("\(range.last!)")
                    .font(.caption)
            }
        }
        .background(Color(.systemBackground))
    }
}

struct Seeker_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            VStack {
                Seeker(position: .constant(10), range: 0...20)
            }
            .previewLayout(.fixed(width: 375, height: 200))
        }
    }
}
