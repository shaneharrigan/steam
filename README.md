# steam 🚀
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-green)](https://github.com/shaneharrigan/steam)
[![Vapor](https://img.shields.io/badge/Vapor-4.0-blue)](https://vapor.codes)
[![License](https://img.shields.io/github/license/shaneharrigan/steam)](https://github.com/shaneharrigan/steam/blob/main/LICENSE)

**steam** is a **powerful API mocking library for Vapor Swift**. It allows developers to **mock API routes**, **simulate network conditions**, and **test requests without hitting a real backend**.

## 🚀 Features
✅ **Mock API Responses** – Define API endpoints and return custom responses.  
✅ **Modify Mocks at Runtime** – Change mock responses dynamically during testing.  
✅ **Simulate Network Latency** – Add delays to responses for testing slow connections.  
✅ **File-Based Mocks** – Load mock responses from JSON files.  
✅ **Seamless Integration** – Works with **XCTVapor**, **Swift Testing**, and **Vapor 4**.  

---

## 📦 Installation
steam is available via **Swift Package Manager (SPM)**.

### **1. Add to `Package.swift`**
```swift
dependencies: [
    .package(url: "https://github.com/shaneharrigan/steam.git", from: "1.0.0")
]
```

### **2. Import and Use in Your Vapor Project**
```swift
import Vapor
import steam

func configure(_ app: Application) throws {
    let mockMiddleware = MockMiddleware(routes: [
        MockRoute(httpMethod: .GET, path: "/api/users", response: Response(status: .ok, body: .init(string: "[{"id":1,"name":"Alice"}]")))
    ])
    app.middleware.use(mockMiddleware)
}
```

---

## 📖 Usage
### **🛠 Define Mock API Responses**
```swift
let mockRoutes = [
    MockRoute(
        httpMethod: .GET,
        path: "/api/users",
        response: Response(status: .ok, body: .init(string: "[{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]"))
    ),
    MockRoute(
        httpMethod: .POST,
        path: "/api/login",
        response: Response(status: .unauthorized)
    )
]
let mockMiddleware = MockMiddleware(routes: mockRoutes)
app.middleware.use(mockMiddleware)
```

---

### **🔄 Modify Mocks at Runtime**
Need to **change a mock response** dynamically? No problem.
```swift
mockMiddleware.updateMockRoute(MockRoute(
    httpMethod: .GET,
    path: "/api/users",
    response: Response(status: .ok, body: .init(string: "[{"id":3,"name":"Charlie"}]"))
))
```

---

### **⏳ Simulate Slow API Responses**
```swift
MockRoute(
    httpMethod: .GET,
    path: "/api/slow-response",
    response: Response(status: .ok, body: .init(string: "Delayed response")),
    delay: .seconds(3) // Simulate a 3-second delay
)
```

---

### **📂 Load Mock Routes from JSON**
Instead of hardcoding, use a **JSON file** for better maintainability.

📄 **mockRoutes.json**
```json
[
    {
        "httpMethod": "GET",
        "path": "/api/users",
        "response": {
            "status": 200,
            "body": [
                { "id": 1, "name": "Alice" },
                { "id": 2, "name": "Bob" }
            ]
        }
    }
]
```

📄 **Load it in your Vapor app**
```swift
let mockRoutes = try MockRouteLoader.load(from: "mockRoutes.json", in: app)
let mockMiddleware = MockMiddleware(routes: mockRoutes)
app.middleware.use(mockMiddleware)
```

---

## 🛠 Usage Example
### **Basic Vapor Application with steam Mocking**
Here’s how you can set up **steam** in a Vapor application:

```swift
import Vapor
import steam

let app = Application()

let mockRoutes = [
    MockRoute(
        httpMethod: .GET,
        path: "/mocked-endpoint",
        response: Response(status: .ok, body: .init(string: "{"message": "This is a mocked response"}"))
    )
]

app.middleware.use(MockMiddleware(routes: mockRoutes))

app.get("mocked-endpoint") { req in
    return Response(status: .ok, body: .init(string: "This won't be reached due to the mock."))
}

try app.run()
```

When you send a `GET` request to `http://localhost:8080/mocked-endpoint`, steam will **intercept the request** and return:
```json
{
  "message": "This is a mocked response"
}
```

---

## 🛠️ Testing with steam
steam integrates **seamlessly** with `XCTVapor` and Swift Testing.

### **✅ Example Test Case**
```swift
import Testing
import Vapor
@testable import steam

@Test
func testMockMiddleware() async throws {
    let app = try await Application.make(.testing)
    defer { try? await app.asyncShutdown() }

    let mockMiddleware = MockMiddleware(routes: [
        MockRoute(
            httpMethod: .GET,
            path: "/api/test",
            response: Response(status: .ok, body: .init(string: "{"message": "mocked"}"))
        )
    ])
    app.middleware.use(mockMiddleware)

    let request = Request(application: app, method: .GET, url: URI(path: "/api/test"), on: app.eventLoopGroup.next())
    let response = try await app.responder.respond(to: request)
    let collectedResponse = try await response.collect()
    let responseBody = collectedResponse.body.getString(at: 0, length: collectedResponse.body?.readableBytes ?? 0)

    #expect(response.status == .ok)
    #expect(responseBody == "{"message": "mocked"}")
}
```

---

## 🛠 Contributing
We welcome contributions! To get started:

1. Fork the repo.
2. Create a feature branch: `git checkout -b new-feature`
3. Commit your changes: `git commit -m "Added new feature"`
4. Push to your branch: `git push origin new-feature`
5. Open a **Pull Request** 🎉

---

## 📢 Community & Support
💬 **Join the discussion on the official Vapor Discord:** [Vapor Discord](https://discord.com/invite/vapor)  
📣 **Submit issues & feature requests:** [GitHub Issues](https://github.com/shaneharrigan/steam/issues)  

---

## ⚖️ License
**steam** is open-source under the [MIT License](https://github.com/shaneharrigan/steam/blob/main/LICENSE).

---

### 🚀 **Happy Coding with steam!** 🚀
