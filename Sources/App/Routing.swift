import PromiseKit

public typealias RouteHandler = (Request) throws -> Response
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
			do {
				let resp = try handler(request)
				return Promise.init(value: resp)
			} catch {
				return Promise.init(error: error)
			}
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
		handler: @escaping (Request) throws -> String
	){
		self.init(
			method: method,
			url: url,
			handler: {
				request -> PromiseKit.Promise<String> in
				do {
					let resp = try handler(request)
					return PromiseKit.Promise.init(value: resp)
				} catch {
					return PromiseKit.Promise.init(error: error)
				}
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
	public var errorHandler: (Request, Error) -> PromiseKit.Promise<Response> = {
		request, error in
		let resp = Response.text("500 Server Error").setStatus(500)
		return PromiseKit.Promise.init(value: resp)
	}

	public init(_ routes: Route...){
		self.routes = routes
	}

	public func withPrefix(_ prefix: String, _ routes: Route...) -> Self{
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

	public func setNotFoundHandler(_ handler: @escaping RouteHandlerDeferred) -> Self{
		self.notFound = {
			(request: Request) in
			return handler(request)
			.then{
				(resp: Response) -> Response in
				resp.status = 404
				return resp
			}
		}

		return self
	}

	public func setNotFoundHandler(_ handler: @escaping RouteHandler) -> Self{
		return self.setNotFoundHandler({
			request -> PromiseKit.Promise<Response> in
			do {
				let resp = try handler(request)
				return PromiseKit.Promise.init(value: resp)
			} catch {
				return PromiseKit.Promise.init(error: error)
			}
		})
	}

	public func setErrorHandler(
		_ handler: @escaping (Request, Error) -> PromiseKit.Promise<Response>
	) -> Self{
		self.errorHandler = handler

		return self
	}

	public func setErrorHandler(
		_ handler: @escaping (Request, Error) -> Response
	) -> Self{
		return self.setErrorHandler({
			(request, error) -> PromiseKit.Promise<Response> in
			let resp = handler(request, error)
			return Promise.init(value: resp)
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