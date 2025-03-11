//
//  File.swift
//  steam
//
//  Created by Shane Harrigan on 10/03/2025.
//
import Vapor
public extension Application {
    func useSteam(routes: [MockRoute]) {
        self.middleware.use(MockMiddleware(routes: routes))
    }
}
