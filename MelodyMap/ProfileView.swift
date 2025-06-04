//
//  ProfileView.swift
//  MelodyMap
//
//  Created by Anant Dhokia on 6/3/25.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Your profile settings 🧑‍🎤")
                    .font(.title2)
                    .padding()

                Spacer()
            }
            .navigationTitle("Profile")
        }
    }
}
