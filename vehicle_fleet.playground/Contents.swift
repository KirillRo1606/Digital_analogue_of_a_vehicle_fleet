//
// Transport for trucking
protocol CargoTransport {
    var bodyType: BodyType { get }
    var bodyVolume: Int { get }
    var loadCapacity: Int { get }
    var availableVolume: Int { get }
    var availableLoad: Int { get }
    var cargoOrders: [CargoOrder] { get set }
    
    func sealBody()
    mutating func load(cargoOrder: CargoOrder)
    mutating func unload(cargoOrder: CargoOrder)
    mutating func isSiutableForCargoOrder(cargoOrder: CargoOrder) -> Bool
}

enum BodyType {
    case tentBody
    case refrigeratorBody
    case tankBody
}
//
// Transport for passenger transportation
protocol PassengerTransport {
    var passengerCapacity: Int { get }
    var availableSeats: Int { get }
    var passengerOrders: [PassengerOrder] { get set }
    
    func disinfectCabin()
    mutating func board(passengerOrder: PassengerOrder)
    mutating func unboard(passengerOrder: PassengerOrder)
    mutating func isSiutableForPassengerOrder(passengerOrder: PassengerOrder) -> Bool
}

class Car {
    var productionYear: Int
    var brand: String
    var model: String
    var fuel: String
    var fuelConsumption: Int
    
    init(productionYear: Int, brand: String, model: String, fuel: String, fuelConsumption: Int) {
        self.productionYear = productionYear
        self.brand = brand
        self.model = model
        self.fuel = fuel
        self.fuelConsumption = fuelConsumption
    }

    func repairCar() {
        print("\(model) by \(brand) repaired")
    }

    func refuelCar() {
        print("\(model) by \(brand) refueled")
    }

    func printAvailableSpace() {}
    func printOrders() {}
    func go() {}
}

class CargoCar: Car, CargoTransport {
    var bodyType: BodyType
    var bodyVolume: Int
    var loadCapacity: Int
    var availableVolume: Int
    var availableLoad: Int
    var cargoOrders: [CargoOrder] = []
    
    init(productionYear: Int, brand: String, model: String, fuel: String, fuelConsumption: Int, bodyVolume: Int, loadCapacity: Int, bodyType: BodyType) {
        self.bodyType = bodyType
        self.bodyVolume = bodyVolume
        self.loadCapacity = loadCapacity
        self.availableVolume = bodyVolume
        self.availableLoad = loadCapacity
        super.init(productionYear: productionYear, brand: brand, model: model, fuel: fuel, fuelConsumption: fuelConsumption)
    }

    func sealBody() {
        print("\(model) by \(brand) sealed")
    }
    //
    // Method to load cargo order
    func load(cargoOrder: CargoOrder) {
        if availableLoad >= cargoOrder.cargoWeight || availableVolume >= cargoOrder.cargoVolume {
            let isCarEmpty = cargoOrders.count == 0
            if isCarEmpty {
                repairCar()
                refuelCar()
            }
            cargoOrders.append(cargoOrder)
            availableLoad -= cargoOrder.cargoWeight
            availableVolume -= cargoOrder.cargoVolume
        } else {
            print("order is out of this car capacity")
        }
    }
    //
    // Method to unload cargo order
    func unload(cargoOrder: CargoOrder) {
        if cargoOrders.contains(where: { $0 === cargoOrder }) {
            cargoOrders = cargoOrders.filter { $0 !== cargoOrder }
            availableLoad += cargoOrder.cargoWeight
            availableVolume += cargoOrder.cargoVolume
        } else {
            print("there is no such cargo order in this car")
        }
    }
    //
    // Method to check is car suitable for cargo order
    func isSiutableForCargoOrder(cargoOrder: CargoOrder) -> Bool {
        var isSuitableForCargoType = false
        switch cargoOrder.cargoType {
            case .manufacturedGoods:
                isSuitableForCargoType = self.bodyType == .tentBody || self.bodyType == .refrigeratorBody
            case .perishableGoods:
                isSuitableForCargoType = self.bodyType == .refrigeratorBody
            case .liquidGoods:
                isSuitableForCargoType = self.bodyType == .tankBody
        }
        
        return self.availableLoad >= cargoOrder.cargoWeight && self.availableVolume >= cargoOrder.cargoVolume && isSuitableForCargoType
    }
    //
    // Method that print available load and volume for car
    override func printAvailableSpace() {
        print("Available load - \(self.availableLoad)")
        print("Available volume - \(self.availableVolume)")
    }
    //
    // Method that print all loaded cargo
    override func printOrders() {
        for cargoOrder in cargoOrders {
            cargoOrder.printOrderInformation()
        }
    }
    //
    //Method to deliver cargo
    override func go() {
        if cargoOrders.count == 0 {
            print("no cargo in car - delivery is cancelled")
            return
        }
        
        printOrders()
        sealBody()
        print("\(model) by \(brand) left \(cargoOrders[0].startPoint)")
        print("\(model) by \(brand) came to \(cargoOrders[0].finishPoint)")
        for cargoOrder in cargoOrders {
            unload(cargoOrder: cargoOrder)
        }
    }
}

class PassengerCar: Car, PassengerTransport {
    var passengerCapacity: Int
    var availableSeats: Int
    var passengerOrders: [PassengerOrder] = []
    
    init(productionYear: Int, brand: String, model: String, fuel: String, fuelConsumption: Int, passengerCapacity: Int) {
        self.passengerCapacity = passengerCapacity
        self.availableSeats = passengerCapacity
        super.init(productionYear: productionYear, brand: brand, model: model, fuel: fuel, fuelConsumption: fuelConsumption)
    }
    //
    // Method to disinfect car
    func disinfectCabin() {
        print("\(model) by \(brand) disinfected")
    }
    //
    // Method to board passengers into car
    func board(passengerOrder: PassengerOrder) {
        if availableSeats >= passengerOrder.passengersAmount {
            let isCarEmpty = passengerOrders.count == 0
            if isCarEmpty {
                repairCar()
                refuelCar()
                disinfectCabin()
            }
            passengerOrders.append(passengerOrder)
            availableSeats -= passengerOrder.passengersAmount
        } else {
            print("not enought free seats in car for this order")
        }
    }
    //
    // Method to unboard passengers fron car
    func unboard(passengerOrder: PassengerOrder) {
        if passengerOrders.contains(where: { $0 === passengerOrder }) {
            passengerOrders = passengerOrders.filter { $0 !== passengerOrder }
            availableSeats += passengerOrder.passengersAmount
        } else {
            print("there is no such passengers order in this car")
        }
    }
    //
    // Method to check is car suitable for passenger order
    func isSiutableForPassengerOrder(passengerOrder: PassengerOrder) -> Bool {
        return self.availableSeats >= passengerOrder.passengersAmount
    }
    //
    // Method that print available number of seats
    override func printAvailableSpace() {
        print("Available seats: \(self.availableSeats)")
    }
    //
    // Method that print all boarded passengers
    override func printOrders() {
        for passengerOrder in passengerOrders {
            passengerOrder.printOrderInformation()
        }
    }
    //
    //Method to deliver passengers
    override func go() {
        if passengerOrders.count == 0 {
            print("no passengers in car - delivery is cancelled")
            return
        }
        
        printOrders()
        print("\(model) by \(brand) left \(passengerOrders[0].startPoint)")
        print("\(model) by \(brand) came to \(passengerOrders[0].finishPoint)")
        for passengerOrder in passengerOrders {
            unboard(passengerOrder: passengerOrder)
        }
    }
}

class CargoPassengerCar: Car, CargoTransport, PassengerTransport {
    var bodyVolume: Int
    var loadCapacity: Int
    var bodyType: BodyType
    var availableVolume: Int
    var availableLoad: Int
    var passengerCapacity: Int
    var availableSeats: Int
    var passengerOrders: [PassengerOrder] = []
    var cargoOrders: [CargoOrder] = []
    
    init(productionYear: Int, brand: String, model: String, fuel: String, fuelConsumption: Int, bodyVolume: Int, loadCapacity: Int, bodyType: BodyType, passengerCapacity: Int) {
        self.bodyVolume = bodyVolume
        self.loadCapacity = loadCapacity
        self.bodyType = bodyType
        self.availableVolume = bodyVolume
        self.availableLoad = loadCapacity
        self.passengerCapacity = passengerCapacity
        self.availableSeats = passengerCapacity
        super.init(productionYear: productionYear, brand: brand, model: model, fuel: fuel, fuelConsumption: fuelConsumption)
    }

    func sealBody() {
        print("\(model) by \(brand) sealed")
    }
    //
    // Method to load cargo order
    func load(cargoOrder: CargoOrder) {
        if availableLoad >= cargoOrder.cargoWeight || availableVolume >= cargoOrder.cargoVolume {
            let isCarEmpty = cargoOrders.count == 0
            if isCarEmpty {
                repairCar()
                refuelCar()
            }
            cargoOrders.append(cargoOrder)
            availableLoad -= cargoOrder.cargoWeight
            availableVolume -= cargoOrder.cargoVolume
        } else {
            print("order is out of this car capacity")
        }
    }
    //
    // Method to unload cargo order
    func unload(cargoOrder: CargoOrder) {
        if cargoOrders.contains(where: { $0 === cargoOrder }) {
            cargoOrders = cargoOrders.filter { $0 !== cargoOrder }
            availableLoad += cargoOrder.cargoWeight
            availableVolume += cargoOrder.cargoVolume
        } else {
            print("there is no such cargo order in this car")
        }
    }
    //
    // Method to check is car suitable for cargo order
    func isSiutableForCargoOrder(cargoOrder: CargoOrder) -> Bool {
        var isSuitableForCargoType = false
        switch cargoOrder.cargoType {
            case .manufacturedGoods:
                isSuitableForCargoType = self.bodyType == .tentBody || self.bodyType == .refrigeratorBody
            case .perishableGoods:
                isSuitableForCargoType = self.bodyType == .refrigeratorBody
            case .liquidGoods:
                isSuitableForCargoType = self.bodyType == .tankBody
        }
        
        return self.availableLoad >= cargoOrder.cargoWeight && self.availableVolume >= cargoOrder.cargoVolume && isSuitableForCargoType
    }
    //
    // Method to check is car suitable for passenger order
    func isSiutableForPassengerOrder(passengerOrder: PassengerOrder) -> Bool {
        return self.availableSeats >= passengerOrder.passengersAmount
    }
    //
    // Method to disinfect car
    func disinfectCabin() {
        print("\(model) by \(brand) disinfected")
    }
    //
    // Method to board passengers into car
    func board(passengerOrder: PassengerOrder) {
        if availableSeats >= passengerOrder.passengersAmount {
            let isCarEmpty = passengerOrders.count == 0
            if isCarEmpty {
                repairCar()
                refuelCar()
                disinfectCabin()
            }
            passengerOrders.append(passengerOrder)
            availableSeats -= passengerOrder.passengersAmount
        } else {
            print("not enought free seats in car for this order")
        }
    }
    //
    // Method to unboard passengers fron car
    func unboard(passengerOrder: PassengerOrder) {
        if passengerOrders.contains(where: { $0 === passengerOrder }) {
            passengerOrders = passengerOrders.filter { $0 !== passengerOrder }
            availableSeats += passengerOrder.passengersAmount
        } else {
            print("there is no such passengers order in this car")
        }
    }
    //
    // Method that print available number of seats
    override func printAvailableSpace() {
        print("Available load: \(self.availableLoad)")
        print("Available volume: \(self.availableVolume)")
        print("Available seats: \(self.availableSeats)")
    }
    //
    // Method that print all loaded cargo and all boarded passengers
    override func printOrders() {
        for passengerOrder in passengerOrders {
            passengerOrder.printOrderInformation()
        }
        for cargoOrder in cargoOrders {
            cargoOrder.printOrderInformation()
        }
    }
    //
    // Method to deliver passengers and cargo
    override func go() {
        let isPassengerOrders = passengerOrders.count > 0
        let isCargoOrders = cargoOrders.count > 0
        if !isPassengerOrders && !isCargoOrders {
            print("no passengers or cargo in car - delivery is cancelled")
            return
        }
        
        printOrders()
        if isCargoOrders {
            sealBody()
        }
        print("\(model) by \(brand) left \(cargoOrders[0].startPoint)")
        print("\(model) by \(brand) came to \(cargoOrders[0].finishPoint)")
        for cargoOrder in cargoOrders {
            unload(cargoOrder: cargoOrder)
        }
        for passengerOrder in passengerOrders {
            unboard(passengerOrder: passengerOrder)
        }
    }
}
//
// Order initialization
protocol Order {
    var startPoint: String { get }
    var finishPoint: String { get }
    var orderType: OrderType { get }
    func printOrderInformation()
}

enum OrderType {
    case cargo
    case passenger
}

class CargoOrder: Order {
    var orderType: OrderType = .cargo
    var startPoint: String
    var finishPoint: String
    var cargoType: CargoType
    var cargoWeight: Int
    var cargoVolume: Int
    
    init(startPoint: String, finishPoint: String, cargoType: CargoType, cargoWeight: Int, cargoVolume: Int) {
        self.startPoint = startPoint
        self.finishPoint = finishPoint
        self.cargoType = cargoType
        self.cargoWeight = cargoWeight
        self.cargoVolume = cargoVolume
    }

    // Method that print info about cargo order
    func printOrderInformation() {
        print("Cargo order from \(self.startPoint) to \(self.finishPoint), cargo type: \(self.cargoType), weight: \(self.cargoWeight) volume: \(self.cargoVolume)")
    }
}

enum CargoType {
    case manufacturedGoods
    case perishableGoods
    case liquidGoods
}

class PassengerOrder: Order {
    var orderType: OrderType = .passenger
    var startPoint: String
    var finishPoint: String
    var passengersAmount: Int
    
    init(startPoint: String, finishPoint: String, passengersAmount: Int) {
        self.startPoint = startPoint
        self.finishPoint = finishPoint
        self.passengersAmount = passengersAmount
    }
    //
    // Method that print info about passenger order
    func printOrderInformation() {
        print("Passengers order from \(self.startPoint) to \(self.finishPoint), passengers amount: \(self.passengersAmount)")
    }
}

class RouteWithOrders {
    var startPoint: String
    var finishPoint: String
    var passengerOrders: [PassengerOrder]
    var cargoOrders: [CargoOrder]
    
    init(startPoint: String, finishPoint: String, passengerOrders: [PassengerOrder], cargoOrders: [CargoOrder]) {
        self.startPoint = startPoint
        self.finishPoint = finishPoint
        self.passengerOrders = passengerOrders
        self.cargoOrders = cargoOrders
    }
}
//
// Logistic Center initialization
class LogisticCenter {
    var cargoCars: [CargoCar] = []
    var passengerCars: [PassengerCar] = []
    var cargoPassengerCars: [CargoPassengerCar] = []
    var freeCargoCars: [CargoCar] = []
    var freePassengerCars: [PassengerCar] = []
    var freeCargoPassengerCars: [CargoPassengerCar] = []
    var routesWithOrders: [RouteWithOrders] = []
}
//
//Methods to add all types of cars
extension LogisticCenter {
    func addCargoCar(_ car: CargoCar) {
        cargoCars.append(car)
        freeCargoCars.append(car)
    }
    func addPassengerCar(_ car: PassengerCar) {
        passengerCars.append(car)
        freePassengerCars.append(car)
    }
    func addCargoPassengerCar(_ car: CargoPassengerCar) {
        cargoPassengerCars.append(car)
        freeCargoPassengerCars.append(car)
    }
}

extension LogisticCenter {
    //
    // Metod to add cargo order
    func addCargoOrder(_ cargoOrder: CargoOrder) {
        var isDestinationExist: Bool = false
        if routesWithOrders.count > 0 {
            for i in 0...(routesWithOrders.count - 1) {
                if routesWithOrders[i].startPoint == cargoOrder.startPoint && routesWithOrders[i].finishPoint == cargoOrder.finishPoint {
                    routesWithOrders[i].cargoOrders.append(cargoOrder)
                    isDestinationExist = true
                    break
                }
            }
        }
        
        if !isDestinationExist {
            var newRoute = RouteWithOrders(startPoint: cargoOrder.startPoint, finishPoint: cargoOrder.finishPoint, passengerOrders: [], cargoOrders: [cargoOrder])
            routesWithOrders.append(newRoute)
        }
    }
    //
    // Method to add passengers order
    func addPassengerOrder(_ passengerOrder: PassengerOrder) {
        var isDestinationExist: Bool = false
        if routesWithOrders.count > 0 {
            for i in 0...(routesWithOrders.count - 1) {
                if routesWithOrders[i].startPoint == passengerOrder.startPoint && routesWithOrders[i].finishPoint == passengerOrder.finishPoint {
                    routesWithOrders[i].passengerOrders.append(passengerOrder)
                    isDestinationExist = true
                    break
                }
            }
        }
        if !isDestinationExist {
            var newRoute = RouteWithOrders(startPoint: passengerOrder.startPoint, finishPoint: passengerOrder.finishPoint, passengerOrders: [passengerOrder], cargoOrders: [])
            routesWithOrders.append(newRoute)
        }
    }
}
//
// Method to deliver all orders
extension LogisticCenter {
    func deliverAllOrders() {
        for route in routesWithOrders {
            //
            // load all cargo orders
            for order in route.cargoOrders {
                let availableCargoCars = freeCargoCars.filter { $0.isSiutableForCargoOrder(cargoOrder: order) }
                let availableCargoPassengesCars = freeCargoPassengerCars.filter { $0.isSiutableForCargoOrder(cargoOrder: order) }
                if availableCargoCars.count != 0 {
                    availableCargoCars[0].load(cargoOrder: order)
                } else if availableCargoPassengesCars.count != 0 {
                    availableCargoPassengesCars[0].load(cargoOrder: order)
                } else {
                    print("no available cars for order: \(order.printOrderInformation())")
                }
            }
            //
            // board all passenger orders
            for order in route.passengerOrders {
                let availablePassengerCars = freePassengerCars.filter { $0.isSiutableForPassengerOrder(passengerOrder: order) }
                let availableCargoPassengerCars = freeCargoPassengerCars.filter { $0.isSiutableForPassengerOrder(passengerOrder: order) }
                if availablePassengerCars.count != 0 {
                    availablePassengerCars[0].board(passengerOrder: order)
                } else if availableCargoPassengerCars.count != 0 {
                    availableCargoPassengerCars[0].board(passengerOrder: order)
                } else {
                    print("no available cars for order: \(order.printOrderInformation())")
                }
            }
            //
            // send all boarded passenger cars
            for passengerCar in freePassengerCars {
                if passengerCar.passengerOrders.count > 0 {
                    passengerCar.go()
                    freePassengerCars = freePassengerCars.filter { $0 !== passengerCar }
                }
            }
            //
            // send all loaded cargo cars
            for cargoCar in freeCargoCars {
                if cargoCar.cargoOrders.count > 0 {
                    cargoCar.go()
                    freeCargoCars = freeCargoCars.filter { $0 !== cargoCar }
                }
            }
            //
            // send all boarded or loaded cargo-passenger cars
            for cargoPassengerCar in freeCargoPassengerCars {
                if cargoPassengerCar.passengerOrders.count > 0 || cargoPassengerCar.cargoOrders.count > 0 {
                    cargoPassengerCar.go()
                    freeCargoPassengerCars = freeCargoPassengerCars.filter { $0 !== cargoPassengerCar }
                }
            }
        }
    }
}
//
// Create instance of Logisitc Center Class
let mainLogisticCener = LogisticCenter()
//
// Create cars
let maz2110CT = CargoCar(productionYear: 2012, brand: "Maz", model: "2110CT", fuel: "Diesel", fuelConsumption: 30, bodyVolume: 100, loadCapacity: 1000, bodyType: .tentBody)
let maz2110CR = CargoCar(productionYear: 2012, brand: "Maz", model: "2110CR", fuel: "Diesel", fuelConsumption: 35, bodyVolume: 70, loadCapacity: 700, bodyType: .refrigeratorBody)
let maz2110CTa = CargoCar(productionYear: 2011, brand: "Maz", model: "2110CTa", fuel: "Diezel", fuelConsumption: 30, bodyVolume: 80, loadCapacity: 1000, bodyType: .tankBody)
let maz3110P = PassengerCar(productionYear: 2019, brand: "Maz", model: "3110B", fuel: "Petrol", fuelConsumption: 31, passengerCapacity: 60)
let mercedesSprinterP = PassengerCar(productionYear: 2019, brand: "Mercedes", model: "Sprinter Passenger", fuel: "Diesel", fuelConsumption: 15, passengerCapacity: 20)
let maz2050CP = CargoPassengerCar(productionYear: 2018, brand: "Maz", model: "2050CP", fuel: "Diezel", fuelConsumption: 27, bodyVolume: 50, loadCapacity: 600, bodyType: .tentBody, passengerCapacity: 20)
let mercedesSprinterCRP = CargoPassengerCar(productionYear: 2020, brand: "Mercedes", model: "Sprinter Passenger-Refrigerator", fuel: "Diezel", fuelConsumption: 19, bodyVolume: 10, loadCapacity: 300, bodyType: .refrigeratorBody, passengerCapacity: 8)
//
// Add cars to main logistic center
mainLogisticCener.addCargoCar(maz2110CT)
mainLogisticCener.addCargoCar(maz2110CR)
mainLogisticCener.addCargoCar(maz2110CTa)
mainLogisticCener.addPassengerCar(maz3110P)
mainLogisticCener.addPassengerCar(mercedesSprinterP)
mainLogisticCener.addCargoPassengerCar(maz2050CP)
mainLogisticCener.addCargoPassengerCar(mercedesSprinterCRP)
//
//Create orders
let minskGrodnoCargo = CargoOrder(startPoint: "Minsk", finishPoint: "Grodno", cargoType: .liquidGoods, cargoWeight: 800, cargoVolume: 60)
let minskGrodnoPassenger = PassengerOrder(startPoint: "Minsk", finishPoint: "Grodno", passengersAmount: 8)
let minskGrodnoCargoSmall = CargoOrder(startPoint: "Minsk", finishPoint: "Grodno", cargoType: .manufacturedGoods, cargoWeight: 100, cargoVolume: 3)
let minskBrestCargo = CargoOrder(startPoint: "Minsk", finishPoint: "Brest", cargoType: .manufacturedGoods, cargoWeight: 100, cargoVolume: 10)
let minskGrodnoCargoLarge = CargoOrder(startPoint: "Minsk", finishPoint: "Grodno", cargoType: .perishableGoods, cargoWeight: 1, cargoVolume: 1)
let minskPinskPassengerSmall = PassengerOrder(startPoint: "Minsk", finishPoint: "Pinsk", passengersAmount: 2)
let minskPinskCargoSmall = CargoOrder(startPoint: "Minsk", finishPoint: "Pinsk", cargoType: .perishableGoods, cargoWeight: 10, cargoVolume: 1)
//
// Add orders to main logistic center
mainLogisticCener.addCargoOrder(minskGrodnoCargo)
mainLogisticCener.addCargoOrder(minskGrodnoCargoSmall)
mainLogisticCener.addCargoOrder(minskBrestCargo)
mainLogisticCener.addCargoOrder(minskGrodnoCargoLarge)
mainLogisticCener.addPassengerOrder(minskGrodnoPassenger)
mainLogisticCener.addPassengerOrder(minskPinskPassengerSmall)
mainLogisticCener.addCargoOrder(minskPinskCargoSmall)
//
// Implement all added orders
mainLogisticCener.deliverAllOrders()
