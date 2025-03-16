//
//  MockRouteLoaderTests.swift
//  steam
//
//  Created by Shane Harrigan on 16/03/2025.
//

import Testing
import Vapor
@testable import steam

@Test
func testMockRouteLoader() async throws {
    let app = try await Application.make(.testing)

    // Get an eventLoop for manual request creation
    let eventLoop = app.eventLoopGroup.next()

    // ✅ Load mock routes from a test JSON file
    let testJSON = """
    [
        {
            "httpMethod": "GET",
            "path": "/api/users",
            "response": {
                "status": 200,
                "body": "[{\\"id\\":1,\\"name\\":\\"Alice\\"},{\\"id\\":2,\\"name\\":\\"Bob\\"}]"
            }
        },
        {
            "httpMethod": "POST",
            "path": "/api/login",
            "response": {
                "status": 401
            }
        }
    ]
    """.data(using: .utf8)!

    let decoder = JSONDecoder()
    let mockRoutes = try decoder.decode([MockRoute].self, from: testJSON)

    // Attach the MockMiddleware
    let mockMiddleware = MockMiddleware(routes: mockRoutes)
    app.middleware.use(mockMiddleware)

    // ✅ Test GET /api/users
    let getUsersRequest = Request(application: app, method: .GET, url: URI(path: "/api/users"), on: eventLoop)
    let getUsersResponse = app.responder.respond(to: getUsersRequest)
    let collectedUsersResponse = try await getUsersResponse.get()
    let getUsersResponseBody = collectedUsersResponse.body.string!

    #expect(collectedUsersResponse.status == .ok)
    #expect(getUsersResponseBody == """
    [{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]
    """)

    // ✅ Test POST /api/login (Should return 401 Unauthorized)
    let postLoginRequest = Request(application: app, method: .POST, url: URI(path: "/api/login"), on: eventLoop)
    let postLoginResponse = app.responder.respond(to: postLoginRequest)
    let collectedPostLoginResponse = try await postLoginResponse.get()
    #expect(collectedPostLoginResponse.status == .unauthorized)

    // ✅ Test unknown route (Should return 404 Not Found)
    let unknownRouteRequest = Request(application: app, method: .GET, url: URI(path: "/unknown"), on: eventLoop)
    let unknownRouteResponse = app.responder.respond(to: unknownRouteRequest)
    let collectedUnknownRouteResponse = try await unknownRouteResponse.get()
    #expect(collectedUnknownRouteResponse.status == .notFound)

    try await app.asyncShutdown()
}

/// ✅ Helper function to convert `ByteBuffer?` to `String`
func getString(from body: ByteBuffer?) -> String {
    guard let buffer = body else { return "" }
    return buffer.getString(at: 0, length: buffer.readableBytes) ?? ""
}
