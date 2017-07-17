import PromiseKit

public class Server{
	let router: Router
	init(router: Router){
		self.router = router
	}

	func serve(_ request: Request) -> Promise<Void>{
		return self.router.getMatchedResponse(request).recover{
			error -> Promise<Response> in
			if error is RequestError{
				switch error as! RequestError{
					case .notFound:
						return self.router.notFound(request);
					default:
						return self.router.errorHandler(request, error);
				}
			} else {
				return self.router.errorHandler(request, error);
			}
		}
		.then() {
			response -> Void in
			if response.headers["Powered-By"] == nil {
				response.headers["Powered-By"] = "VyrtsevSwift"
			}
			response.send()
		}
	}
}