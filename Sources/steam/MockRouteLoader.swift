//
//  MockRouteLoader.swift
//  steam
//
//  Created by Shane Harrigan on 16/03/2025.
//

import Vapor

struct MockRouteLoader {
    static func load(from filename: String, in app: Application) throws -> [MockRoute] {
        let fileURL = app.directory.workingDirectory + filename
        let data = try Data(contentsOf: URL(fileURLWithPath: fileURL))
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode([MockRoute].self, from: data)
    }
}
