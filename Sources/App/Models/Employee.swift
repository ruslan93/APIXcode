//
//  Employee.swift
//  Hello
//
//  Created by Ruslan on 2/2/17.
//
//

import Foundation
import Vapor
import Fluent

enum Gender {
    case Male, Female
    
    var description : String {
        switch self {
        case .Male: return "Male";
        case .Female: return "Female";
        }
    }
    
    init(id: Int) {
        if id == 0 {
            self = .Male
        } else {
            self = .Female
        }
    }
}

final class Employee: Model {
    
    var exists: Bool = false
    var name: String
    var age: Int
    var gender: Gender
    var time: Int
    var id: Node?
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
        self.gender = .Male
        self.time = Int(Date().timeIntervalSince1970)
        self.id = nil
    }
    
    init(node: Node, in context: Context) throws {
        name = try node.extract("name")
        age = try node.extract("age")
        time = try node.extract("time")
        gender = .Male
        id = try node.extract("id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "name":name,
            "age":age,
            "gender":gender.description,
            "time":time,
            "id":id
            ])
    }
    
    func makeResponse() throws -> JSON {
        return try JSON(node: [
            "name":self.name,
            "age":self.age,
            "time":time,
            "gender":self.gender.description
            ])
    }
}

extension Employee: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("employees") { cars in
            cars.id()
            cars.string("name")
            cars.string("gender")
            cars.int("age")
            cars.int("time")
        }
    }
    
    //This makes sure it gets deleted when reverting the projects database
    static func revert(_ database: Database) throws {
        try database.delete("employees")
    }
}
