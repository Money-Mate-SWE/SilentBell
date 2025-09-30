//
//  UserModel.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/29/25.
//
struct User: Codable {
    let user_id: Int
    let name: String
    let email: String
    let created_at: String
    let last_login: String
    let last_name: String
}
