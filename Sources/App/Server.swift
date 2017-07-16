import PromiseKit

public class Server{
	let router: Router
	init(router: Router){
		self.router = router
	}

	func serve() -> Promise<Void>{
		return Promise<Void>{
			fulfill, reject in
			let request = Request()
			let response = router.getMatchedResponse(request)
			response
			.then() {
				response in
				if response.headers["Powered-By"] == nil {
					response.headers["Powered-By"] = "VyrtsevSwift"
				}
				response.send()
				fulfill()
			}
			.catch{
				error in
				Response("\(error)").send()
				fulfill()
			}
		}
	}
}