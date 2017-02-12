import Vapor
import VaporMySQL


let drop = Droplet(
    preparations: [Acronym.self, Employee.self],
    providers: [VaporMySQL.Provider.self]
)

// get options
drop.get ("options") { request in
    return try JSON(node: [
        "message" : "options",
        "owner" : "ruslan"
        ])
}


// add new employee
drop.post ("employee", "new") { request in
    guard let name = request.data["name"]?.string else {
        return try JSON(node: [
            "error":"name"
            ])
    }
    guard let age = request.data["age"]?.int else {
        return try JSON(node: [
            "error":"age"
            ])
    }
    var employee = Employee(name: name, age: age)
    try employee.save()
    return try employee.makeResponse()
}

// get all employees
drop.get ("employee", "all") { request in
    guard let name = request.data["name"]?.string else {
        return try JSON(node: Employee.query().all().makeNode())
    }
    return try JSON(node: Employee.query().filter("name", name).all().makeNode())
}

// update
drop.post("employee", "update") { request in
    guard let ID = request.data["id"]?.int, let newName = request.data["name"]?.string, var first = try Employee.query().filter("id", ID).first() else {
        return try JSON(node: [
            "error":"user with ID is missing "
            ])
    }
    first.name = newName
    try first.save()
    return try first.makeResponse()
}


drop.run()
