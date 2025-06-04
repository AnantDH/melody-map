//
//  HomeView.swift
//  MelodyMap
//
//  Created by Anant Dhokia on 6/3/25.
//

import SwiftUI

struct HomeView: View {
    @State private var pins: [MelodyPin] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button("Add Sample Pin") {
                    let fakeSong = DeezerSong(
                        id: 12345,
                        title: "Viva La Vida",
                        artist: DeezerArtist(name: "Coldplay"),
                        album: DeezerAlbum(cover_medium: ""),
                        preview: nil
                    )
                    let sample = MelodyPin(song: fakeSong, coordinate: .init(latitude: 47.6, longitude: -122.3), note: "Walking in Seattle")
                    pins.append(sample)
                    PinStorageService.shared.savePins(pins)
                }

                Button("Load Saved Pins") {
                    pins = PinStorageService.shared.loadPins()
                }

                List(pins) { pin in
                    VStack(alignment: .leading) {
                        Text("\(pin.song.title) by \(pin.song.artist.name)")
                            .bold()
                        Text("Note: \(pin.note ?? "None")")
                            .font(.caption)
                    }
                }
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}


