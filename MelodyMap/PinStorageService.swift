//
//  PinStorageService.swift
//  MelodyMap
//
//  Created by Anant Dhokia on 6/3/25.
//

import Foundation

class PinStorageService {
    static let shared = PinStorageService()

    private let filename = "melodypins.json"

    private var fileURL: URL {
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docsDir.appendingPathComponent(filename)
    }

    // Save pins to file
    func savePins(_ pins: [MelodyPin]) {
        do {
            let data = try JSONEncoder().encode(pins)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save MelodyPins: \(error)")
        }
    }

    // Load pins from file
    func loadPins() -> [MelodyPin] {
        do {
            let data = try Data(contentsOf: fileURL)
            let pins = try JSONDecoder().decode([MelodyPin].self, from: data)
            return pins
        } catch {
            print("No saved pins found or failed to load: \(error)")
            return []
        }
    }
}
