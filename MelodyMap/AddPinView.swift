//
//  AddPinView.swift
//  MelodyMap
//
//  Created by Anant Dhokia on 6/3/25.
//

import SwiftUI
import CoreLocation

struct AddPinView: View {
    let coordinate: CLLocationCoordinate2D
    var onSave: (MelodyPin) -> Void

    @State private var query = ""
    @State private var results: [DeezerSong] = []
    @State private var selectedSong: DeezerSong?
    @State private var note = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search for a song", text: $query, onCommit: searchDeezer)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.top)

                List(results) { song in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(song.title)
                                .fontWeight(.semibold)
                            Text(song.artist.name)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if song.id == selectedSong?.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle()) // Make full row tappable
                    .onTapGesture {
                        selectedSong = song
                    }
                }

                Divider().padding(.vertical, 8)

                TextField("Add a note (optional)", text: $note)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("Save MelodyPin") {
                    if let song = selectedSong {
                        let pin = MelodyPin(song: song, coordinate: coordinate, note: note)
                        onSave(pin)
                    }
                }
                .disabled(selectedSong == nil)
                .padding()

                Spacer()
            }
            .navigationTitle("Add MelodyPin")
            .navigationBarItems(trailing: Button("Cancel") {
                onSave(MelodyPin(song: DeezerSong(id: -1, title: "", artist: DeezerArtist(name: ""), album: DeezerAlbum(cover_medium: ""), preview: nil), coordinate: coordinate)) // discard
            })
        }
    }

    func searchDeezer() {
        guard !query.isEmpty else { return }

        let formattedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.deezer.com/search?q=\(formattedQuery)"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(DeezerSearchResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.results = decoded.data
                    }
                } catch {
                    print("Decode error: \(error)")
                }
            } else {
                print("Network error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
}


