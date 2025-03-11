import Testing
import Vapor
@testable import steam

@Test
func testMockMiddleware() async throws {
    let app = try await Application.make(.testing)

    // Get an eventLoop for manual request creation
    let eventLoop = app.eventLoopGroup.next()

    // Define mock routes
    let mockRoutes = [
        MockRoute(
            httpMethod: .GET,
            path: "/api/users",
            response: Response(status: .ok, body: .init(string: """
            [{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]
            """))
        ),
        MockRoute(
            httpMethod: .POST,
            path: "/api/login",
            response: Response(status: .unauthorized)
        )
    ]

    // Attach the MockMiddleware
    let mockMiddleware = MockMiddleware(routes: mockRoutes)
    app.middleware.use(mockMiddleware)

    // ✅ Fix: Use `collect()` to get the response body
    let getUsersRequest = Request(application: app, method: .GET, url: URI(path: "/api/users"), on: eventLoop)
    let getUsersResponse = app.responder.respond(to: getUsersRequest)
    let collectedUsersResponse = try await getUsersResponse.get()
    let getUsersResponseBody = collectedUsersResponse.body.string!

    #expect(collectedUsersResponse.status == .ok)
    #expect(getUsersResponseBody == """
    [{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]
    """)

    let postLoginRequest = Request(application: app, method: .POST, url: URI(path: "/api/login"), on: eventLoop)
    let postLoginResponse = app.responder.respond(to: postLoginRequest)
    let collectedPostLoginResponse = try await postLoginResponse.get()
    #expect(collectedPostLoginResponse.status == .unauthorized)

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
