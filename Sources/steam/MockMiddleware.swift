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
    
    public init(routes: [MockRoute]) {  // ✅ Make initializer public
        self.mockRoutes = routes
    }
    
    public func respond(to request: Vapor.Request, chainingTo next: any Vapor.Responder) -> NIOCore.EventLoopFuture<Vapor.Response> {
        lock.withLock {
            if let mockRoute = mockRoutes.first(where: {
                $0.httpMethod == request.method && $0.path == request.url.path
            }) {
                let response = createResponse(from: mockRoute.response, for: request)
                
                if let delaySeconds = mockRoute.response.delaySeconds {
                    return request.eventLoop.scheduleTask(in: .milliseconds(Int64(delaySeconds*1000))) {
                        response
                    }.futureResult
                }  else {
                    return request.eventLoop.makeSucceededFuture(response)
                }
                
            }
            return next.respond(to: request)
        }
    }
    
    public func addMockRoute(_ route: MockRoute) {
        lock.withLock {
            self.mockRoutes.append(route)
        }
    }
    
    /// ✅ Converts `MockRoute.MockResponse` to a Vapor `Response`
    private func createResponse(from mockResponse: MockRoute.MockResponse, for request: Request) -> Response {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .contentType, value: "application/json")

        let body: Response.Body
        if let responseBody = mockResponse.body {
            body = .init(string: responseBody)
        } else {
            body = .empty
        }
        
        return Response(status: mockResponse.status, headers: headers, body: body)
    }
}
