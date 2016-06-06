import Swift
import Foundation

/*:

Swift 2.2 面向对象设计原则
==================================

基于 Xcode 7.3 Playground 的一个简短备忘 ([OOD-Principles-In-Swift.playground.zip](https://raw.githubusercontent.com/ochococo/OOD-Principles-In-Swift/master/OOD-Principles-In-Swift.playground.zip)).

👷 项目由[@nsmeme](http://twitter.com/nsmeme) (Oktawian Chojnacki)维护

S.O.L.I.D.
==========

* [单一功能原则 (The Single Responsibility Principle)](#-🔐-单一功能原则)
* [开放-封闭原则 (The Open Closed Principle)](#-✋-开放-封闭原则)
* [里氏替换原则 (The Liskov Substitution Principle)](#-👥-里氏替换原则)
* [接口分离原则 (The Interface Segregation Principle)](#-🍴-接口分离原则)
* [依赖倒置原则 (The Dependency Inversion Principle)](#-依赖倒置原则)

*/
/*:
# 🔐 单一功能原则

有且仅有一个原因可以使得一个类需要调整。([read more](https://docs.google.com/open?id=0ByOwmqah_nuGNHEtcU5OekdDMkk))

举例:
*/

protocol CanBeOpened {
    func open()
}

protocol CanBeClosed {
    func close()
}

// PodBayDoor类有一个封闭的状态，可以通过方法来改变这个状态。 
final class PodBayDoor: CanBeOpened, CanBeClosed {

    private enum State {
        case Open
        case Closed
    }

    private var state: State = .Closed

    func open() {
        state = .Open
    }

    func close() {
        state = .Closed
    }
}

// DoorOpener类仅仅负责打开，并不知道门内有什么以及怎样关闭。
class DoorOpener {
    let door: CanBeOpened

    init(door: CanBeOpened) {
        self.door = door
    }

    func execute() {
        door.open()
    }
}

// DoorCloser类仅负责关闭，并不清楚门内有什么以及怎样打开。 
class DoorCloser {
    let door: CanBeClosed

    init(door: CanBeClosed) {
        self.door = door
    }

    func execute() {
        door.close()
    }
}

let door = PodBayDoor()

/*: 
> ⚠ 仅有DoorOpener负责将门打开。 
*/

let doorOpener = DoorOpener(door: door)
doorOpener.execute()

/*: 
> ⚠ 如果有其他的操作来关闭门，比如打开报警器，你将不需要改变DoorOpener类。
*/

let doorCloser = DoorCloser(door: door)
doorCloser.execute()

/*:
# ✋ 开放-封闭原则

你将能够扩展一个类的行为，而不必修改这个类本身。 ([read more](http://docs.google.com/a/cleancoder.com/viewer?a=v&pid=explorer&chrome=true&srcid=0BwhCYaYDn8EgN2M5MTkwM2EtNWFkZC00ZTI3LWFjZTUtNTFhZGZiYmUzODc1&hl=en))

举例:
 */

protocol CanShoot {
    func shoot() -> String
}

// 激光束，可以射击。 (I'm a laser beam. I can shoot.)
final class LaserBeam: CanShoot {
    func shoot() -> String {
        return "Ziiiiiip!"
    }
}

// 要你命3000，拥有各种武器并可以依次完成拥有的所有武器的射击。 
final class WeaponsComposite {

    let weapons: [CanShoot]

    init(weapons: [CanShoot]) {
        self.weapons = weapons
    }

    func shoot() -> [String] {
        return weapons.map { $0.shoot() }
    }
}

let laser = LaserBeam()
var weapons = WeaponsComposite(weapons: [laser])

weapons.shoot()

/*: 
火箭发射车，可以射出火箭。 
> ⚠️ 为了增加火箭发射车类，并不需要改变既有的任何类。 
*/

final class RocketLauncher: CanShoot {
    func shoot() -> String {
        return "Whoosh!"
    }
}

let rocket = RocketLauncher()

weapons = WeaponsComposite(weapons: [laser, rocket])
weapons.shoot()

/*:
# 👥 里氏替换原则

派生类必须能够替代他们的基类。 ([read more](http://docs.google.com/a/cleancoder.com/viewer?a=v&pid=explorer&chrome=true&srcid=0BwhCYaYDn8EgNzAzZjA5ZmItNjU3NS00MzQ5LTkwYjMtMDJhNDU5ZTM0MTlh&hl=en))

举例:
*/

let requestKey: NSString = "NSURLRequestKey"

// RequestError是NSError的子类，提供额外的功能，但不会跟父类中的功能相混淆。 
class RequestError: NSError {

    var request: NSURLRequest? {
        return self.userInfo[requestKey] as? NSURLRequest
    }
}

// 获取数据失败后返回RequestError的实例对象。 
func fetchData(request: NSURLRequest) -> (data: NSData?, error: RequestError?) {

    let userInfo: [NSObject:AnyObject] = [ requestKey : request ]

    return (nil, RequestError(domain:"DOMAIN", code:0, userInfo: userInfo))
}

// 这里并不清楚RequestError是什么，在请求失败时返回一个NSError实例对象。
func willReturnObjectOrError() -> (object: AnyObject?, error: NSError?) {

    let request = NSURLRequest()
    let result = fetchData(request)

    return (result.data, result.error)
}

let result = willReturnObjectOrError()

// 以我的观点，这是一个完美的NSError实例。 
let error: Int? = result.error?.code

// 但是这里它也是一个RequestError实例，一切都非常完美！ 
if let requestError = result.error as? RequestError {
    requestError.request
}

/*:
# 🍴 接口分离原则

提供给使用者指定粒度的接口。  ([read more](http://docs.google.com/a/cleancoder.com/viewer?a=v&pid=explorer&chrome=true&srcid=0BwhCYaYDn8EgOTViYjJhYzMtMzYxMC00MzFjLWJjMzYtOGJiMDc5N2JkYmJi&hl=en))

举例:
 */

// 拥有一个着陆地点。
protocol LandingSiteHaving {
    var landingSite: String { get }
}

// 拥有着陆能力，可以着陆在着陆地点对象上。
protocol Landing {
    func landOn(on: LandingSiteHaving) -> String
}

// 载有有效载荷。
protocol PayloadHaving {
    var payload: String { get }
}

// 国际空间站类，可以通过装置，比如加拿大臂(空间站上用的机械装置)，取到有效载荷。
final class InternationalSpaceStation {

/*: 
> ⚠ 空间站并不知道SpaceX CRS8的着陆能力。
*/

    func fetchPayload(vehicle: PayloadHaving) -> String {
        return "Deployed \(vehicle.payload) at April 10, 2016, 11:23 UTC"
    }
}

// 海洋着陆平台，有一个着陆地点。
final class OfCourseIStillLoveYouBarge: LandingSiteHaving {
    let landingSite = "a barge on the Atlantic Ocean"
}

// SpaceX CRS8类，携带有效载荷，可以着陆在有着陆地点的地方。 
// SpaceX CRS8是有个非常有限的太空运输工具，下面的BEAM是比奇洛公司的充气空间站舱段。最近有新闻。 
final class SpaceXCRS8: Landing, PayloadHaving {

    let payload = "BEAM and some Cube Sats"

/*: 
> ⚠ CRS8仅仅知道着陆位置信息。 
*/

    func landOn(on: LandingSiteHaving) -> String {
        return "Landed on \(on.landingSite) at April 8, 2016 20:52 UTC"
    }
}

let crs8 = SpaceXCRS8()
let barge = OfCourseIStillLoveYouBarge()
let spaceStation = InternationalSpaceStation()

spaceStation.fetchPayload(crs8)
crs8.landOn(barge)

/*:
# 🔩 依赖倒置原则

依赖抽象，而非具象。 ([read more](http://docs.google.com/a/cleancoder.com/viewer?a=v&pid=explorer&chrome=true&srcid=0BwhCYaYDn8EgMjdlMWIzNGUtZTQ0NC00ZjQ5LTkwYzQtZjRhMDRlNTQ3ZGMz&hl=en))

举例:
*/

protocol TimeTraveling {
    func travelInTime(time: NSTimeInterval) -> String
}
// DeLorean是科幻电影《回到未来》中的那辆车的名字。
final class DeLorean: TimeTraveling {
	func travelInTime(time: NSTimeInterval) -> String {
		return "Used Flux Capacitor and travelled in time by: \(time)s"
	}
}
// Emmett Brown就是埃米特*布朗博士，电影主角之一。
final class EmmettBrown {
	private let timeMachine: TimeTraveling

/*: 
> ⚠ 是Emmet Brown给了DeLorean的TimeTraveling功能，而非DeLorean本身。 
*/

	init(timeMachine: TimeTraveling) {
		self.timeMachine = timeMachine
	}

	func travelInTime(time: NSTimeInterval) -> String {
		return timeMachine.travelInTime(time)
	}
}

let timeMachine = DeLorean()

let mastermind = EmmettBrown(timeMachine: timeMachine)
mastermind.travelInTime(-3600 * 8760)

/*:

Info
====

📖 摘自: [The Principles of OOD by Uncle Bob](http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod)

*/
