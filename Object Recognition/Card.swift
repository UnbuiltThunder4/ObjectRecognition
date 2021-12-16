//
//  Card.swift
//  Object Recognition
//
//  Created by Eugenio Raja on 14/12/21.
//

import Foundation
import SwiftUI

struct Card: View {
    var label: String
    var certainty: String
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text("Guess:     ")
                    .font(.system(size: 14))
                    .frame(width: 80)
                    .padding()
                Text(label)
                    .font(.system(size: 24))
                    .foregroundColor(Color.blue)
                    .font(.title)
                    .padding()
            }
            .accessibilityElement(children: .combine)
            Divider()
            HStack {
                Text("Certainty:")
                    .font(.system(size: 14))
                    .frame(width: 80)
                    .padding()
                Text("\(certainty)")
                    .font(.system(size: 24))
                    .foregroundColor(Color.blue)
                    .font(.title)
                    .padding()
            }
            .accessibilityElement(children: .combine)
        }
        .background(.thinMaterial)
    }
}
