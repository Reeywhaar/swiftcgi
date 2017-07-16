import PromiseKit

public typealias RouteHandler = (Request) -> Response
public typealias RouteHandlerDeferred = (Request) -> PromiseKit.Promise<Response>

public class Route {
	var method: RequestMethod
	var url: String
	var handler: RouteHandlerDeferred

	init(
		method: RequestMethod,
		url: String,
		handler: @escaping RouteHandlerDeferred
	){
		self.method = method
		self.url = url
		self.handler = handler
	}

	init(
		method: RequestMethod,
		url: String,
		handler: @escaping RouteHandler
	){
		self.method = method
		self.url = url
		self.handler = {
			(request: Request) in
			return Promise.init(value: handler(request))
		}
	}

	init(
		method: RequestMethod,
		url: String,
		handler: @escaping (Request) -> PromiseKit.Promise<String>
	){
		self.method = method
		self.url = url
		self.handler = {
			(request: Request) -> PromiseKit.Promise<Response> in
			return handler(request)
			.then{ Response.text($0) }
		}
	}

	convenience init(
		method: RequestMethod,
		url: String,
		handler: @escaping (Request) -> String
	){
		self.init(
			method: method,
			url: url,
			handler: {
				request -> PromiseKit.Promise<String> in
				return Promise.init(value: handler(request))
			}
		)
	}

	func matches(_ request: Request) -> Bool{
		if request.method != self.method {
			return false
		}
		if request.url.path == self.url{
			return true
		}
		return false
	}
}

public class Router{
	public var routes: [Route] = []
	public var notFound: RouteHandlerDeferred = {
		request in
		var resp = Response.html("404")
		resp.status = 404
		return PromiseKit.Promise.init(value: resp)
	}

	public init(_ routes: Route...){
		self.routes = routes
	}

	public func withPrefix(_ prefix: String, _ routes: Route...) -> Router{
		for route in routes{
			var url = prefix + route.url
			if(url.hasSuffix("/")){
				url = url.substring(
					to: url.index(url.startIndex, offsetBy: url.characters.count - 1)
				);
			}
			route.url = url
			self.routes.append(route)
		}
		return self
	}

	public func setNotFoundHandler(_ handler: @escaping RouteHandlerDeferred){
		self.notFound = {
			(request: Request) in
			return handler(request)
			.then{
				(resp: Response) -> Response in
				resp.status = 404
				return resp
			}
		}
	}

	public func setNotFoundHandler(_ handler: @escaping RouteHandler){
		self.setNotFoundHandler({
			request -> Promise<Response> in
			return PromiseKit.Promise.init(value: handler(request))
		})
	}

	public func getMatchedResponse(_ request: Request) -> PromiseKit.Promise<Response>{
		for route in self.routes{
			if route.matches(request){
				return route.handler(request)
			}
		}
		return self.notFound(request)
	}
}