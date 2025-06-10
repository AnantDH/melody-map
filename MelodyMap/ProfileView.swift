//
//  ProfileView.swift
//  MelodyMap
//
//  Created by Anant Dhokia on 6/3/25.
//

import Foundation
import SwiftUI

/// User profile view that now also lets the user choose between System, Light,
/// or Dark appearance for the app.
struct ProfileView: View {
    // Access the global theme object so we can read & write the current selection.
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var pins: [MelodyPin] = []
    @State private var playlists: [Playlist] = []
    @State private var userName: String = UserDefaultsService.shared.userName

    // Computed statistics
    private var totalPins: Int { pins.count }
    private var totalPlaylists: Int { playlists.count }
    private var uniqueArtists: Int { Set(pins.map { $0.song.artist.name }).count }
    private var firstPinDate: Date? { pins.min(by: { $0.timestamp < $1.timestamp })?.timestamp }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)

                        Text("Welcome back!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            
                        TextField("Enter your name", text: $userName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .onChange(of: userName) { _, newValue in
                                UserDefaultsService.shared.userName = newValue
                            }
                    }

                    Divider()

                    // Statistics grid
                    VStack(spacing: 12) {
                        StatRow(title: "Pins Dropped", value: "\(totalPins)")
                        StatRow(title: "Playlists Created", value: "\(totalPlaylists)")
                        StatRow(title: "Unique Artists", value: "\(uniqueArtists)")
                        if let date = firstPinDate {
                            StatRow(title: "First Pin", value: date.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Appearance settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Appearance")
                            .font(.headline)

                        Picker("Appearance", selection: $themeManager.selectedTheme) {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                Text(theme.displayName).tag(theme)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Settings Button
                    Button(action: {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }) {
                        HStack {
                            Image(systemName: "gear")
                                .foregroundColor(.blue)
                            Text("Open Settings")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .onAppear {
                pins = PinStorageService.shared.loadPins()
                playlists = PlaylistStorageService.shared.loadPlaylists()
                userName = UserDefaultsService.shared.userName
            }
        }
    }

    // MARK: - Subviews
    @ViewBuilder
    private func StatRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.body)
    }
}
