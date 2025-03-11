//
//  MockRoute.swift
//  steam
//
//  Created by Shane Harrigan on 10/03/2025.
//
import Vapor

public struct MockRoute {
    let httpMethod: HTTPMethod
    let path: String
    let response: Response
}
