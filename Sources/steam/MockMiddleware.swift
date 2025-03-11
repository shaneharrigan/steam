//
//  MockMiddleware.swift
//  steam
//
//  Created by Shane Harrigan on 10/03/2025.
//

import Vapor
import NIOConcurrencyHelpers


public final class MockMiddleware: Middleware, @unchecked Sendable {
    public var mockRoutes: [MockRoute]
    private let lock = NIOLock()
    init(routes: [MockRoute]) {
        self.mockRoutes = routes
    }
    
    public func respond(to request: Vapor.Request, chainingTo next: any Vapor.Responder) -> NIOCore.EventLoopFuture<Vapor.Response> {
        lock.withLock {
            if let mockRoute = mockRoutes.first(where: {
                $0.httpMethod == request.method
                && $0.path == request.url.path }) {
                return request.eventLoop.makeSucceededFuture(mockRoute.response)
            }
            return next.respond(to: request)
        }
    }
    
    public func addMockRoute(_ route: MockRoute) {
        lock.withLock {
            self.mockRoutes.append(route)
        }
    }
}
