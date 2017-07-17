import Foundation
import PMKAlamofire
import PromiseKit

func getRouter() -> Router{
	let router = Router().withPrefix(
		"/swiftapp",
		Route(
			method: .GET,
			url: "/",
			handler: {
				request -> String in
				return "Hello!"
			}
		),
		Route(
			method: .GET,
			url: "/randomnumber",
			handler: {
				request -> String in
				return "\(random(10))"
			}
		),
		Route(
			method: .GET,
			url: "/samplejson",
			handler: {
				request -> Response in
				let file = try! String(contentsOfFile: "./data/data.json")
				return Response.json(file)
			}
		),
		Route(
			method: .GET,
			url: "/samplecontroller",
			handler: Controllers.PostController.index
		),
		Route(
			method: .GET,
			url: "/swapi",
			handler: {
				request -> Promise<Response> in
				return PMKAlamofire.request("http://swapi.co/api/people/")
				.responseString()
				.then { .json($0) }
			}
		),
		Route(
			method: .GET,
			url: "/error",
			handler: {
				request -> Promise<Response> in
				return PromiseKit.Promise.init(value: true)
				.then {
					(value: Bool) in
					switch random(3){
						case 0:
							throw RequestError.notFound
						case 1:
							throw RequestError.serverError
						default:
							throw RequestError.unknownError
					}
				}
				.recover {
					(error) throws -> Response in
					guard error is RequestError else { throw error }
					switch error as! RequestError{
						case .unknownError:
							return Response.text("There was unknown error").setStatus(500)
						default:
							throw error
					}
				}
			}
		)
	).setNotFoundHandler({
		request -> Response in
		return .json("{\"error\":404}")
	})

	return router
}

func spawnServer(_ router: Router, _ getRequest: (() -> Request), _ timeout: Double = 180){
	let server = Server(router: router)
	server.serve(getRequest())
	.then {
		exit(EXIT_SUCCESS)
	}
	.catch {
		error in
		exit(EXIT_SUCCESS)
	}
	Foundation.RunLoop.main.run(until: Date(timeIntervalSinceNow: timeout))
}

func main(){
	ServiceLocator.set(name: "Renderer", service: Renderer.init())
	spawnServer(getRouter(), { Request() })
}

main()