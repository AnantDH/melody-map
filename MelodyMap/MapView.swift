//
//  MapView.swift
//  MelodyMap
//
//  Created by Anant Dhokia on 6/3/25.
//

import SwiftUI
import MapKit


struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @State private var pins: [MelodyPin] = PinStorageService.shared.loadPins()
    @State private var showingAddPin = false
    @State private var newPinLocation: CLLocationCoordinate2D?

    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region, annotationItems: pins) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    VStack {
                        Image(systemName: "music.note")
                            .padding(6)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                        Text(pin.song.title)
                            .font(.caption)
                    }
                }
            }
            .gesture(
                LongPressGesture(minimumDuration: 1.0)
                    .sequenced(before: DragGesture(minimumDistance: 0))
                    .onEnded { value in
                        if case .second(true, let drag?) = value {
                            let location = drag.location
                            let coordinate = convertToCoordinate(location: location, region: region)
                            newPinLocation = coordinate
                            showingAddPin = true
                        }
                    }
            )
            .navigationTitle("Map")
            .sheet(isPresented: $showingAddPin) {
                if let coordinate = newPinLocation {
                    AddPinView(coordinate: coordinate) { newPin in
                        pins.append(newPin)
                        PinStorageService.shared.savePins(pins)
                        showingAddPin = false
                    }
                }
            }
        }
    }

    // Converts screen tap to coordinates
    func convertToCoordinate(location: CGPoint, region: MKCoordinateRegion) -> CLLocationCoordinate2D {
        // This is a placeholder – we'll replace this with precise coordinate conversion later.
        region.center // fallback to center of map
    }
}

