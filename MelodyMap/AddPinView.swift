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
    @Environment(\.presentationMode) var presentationMode

    @State private var query = ""
    @State private var results: [DeezerSong] = []
    @State private var selectedSong: DeezerSong?
    @State private var note = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search for a song", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.top)
                    .onSubmit {
                        searchDeezer()
                    }

                if isLoading {
                    ProgressView()
                        .padding()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(results) { song in
                        HStack {
                            AsyncImage(url: URL(string: song.album.cover_medium)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(4)

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
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedSong = song
                        }
                    }
                }

                Divider().padding(.vertical, 8)

                TextField("Add a note (optional)", text: $note)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("Save MelodyPin") {
                    if let song = selectedSong {
                        let pin = MelodyPin(song: song, coordinate: coordinate, note: note.isEmpty ? nil : note)
                        onSave(pin)
                    }
                }
                .disabled(selectedSong == nil)
                .padding()

                Spacer()
            }
            .navigationTitle("Add MelodyPin")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func searchDeezer() {
        guard !query.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        let formattedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.deezer.com/search?q=\(formattedQuery)"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid search URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Search failed: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    errorMessage = "No data received"
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(DeezerSearchResponse.self, from: data)
                    self.results = decoded.data.filter { song in
                        if let urlString = song.preview,
                           !urlString.isEmpty,
                           URL(string: urlString) != nil {
                            return true
                        }
                        return false
                    }
                    if self.results.isEmpty {
                        errorMessage = "No songs found"
                    }
                } catch {
                    errorMessage = "Failed to decode results"
                }
            }
        }.resume()
    }
}


