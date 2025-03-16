//
//  MockRoute.swift
//  steam
//
//  Created by Shane Harrigan on 10/03/2025.
//
import Vapor

public struct MockRoute: Codable {
    let httpMethod: HTTPMethod
    let path: String
    let response: MockResponse

    public struct MockResponse: Codable {
        let status: HTTPResponseStatus
        let body: String?

        enum CodingKeys: String, CodingKey {
            case status
            case body
        }

        init(status: HTTPResponseStatus, body: String? = nil) {
            self.status = status
            self.body = body
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let statusCode = try container.decode(Int.self, forKey: .status)
            self.status = HTTPResponseStatus(statusCode: statusCode)
            self.body = try container.decodeIfPresent(String.self, forKey: .body)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(status.code, forKey: .status)
            try container.encodeIfPresent(body, forKey: .body)
        }
    }

    enum CodingKeys: String, CodingKey {
        case httpMethod
        case path
        case response
    }

    init(httpMethod: HTTPMethod, path: String, response: MockResponse) {
        self.httpMethod = httpMethod
        self.path = path
        self.response = response
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let methodString = try container.decode(String.self, forKey: .httpMethod)
        self.httpMethod = HTTPMethod(rawValue: methodString)
        self.path = try container.decode(String.self, forKey: .path)
        self.response = try container.decode(MockResponse.self, forKey: .response)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(httpMethod.rawValue, forKey: .httpMethod)
        try container.encode(path, forKey: .path)
        try container.encode(response, forKey: .response)
    }
}
