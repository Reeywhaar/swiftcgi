import Foundation

enum RequestError: Error{
	case notFound
	case serverError
	case unknownError
}

public enum RequestMethod: String{
	case GET = "GET"
	case POST = "POST"
	case PUT = "PUT"
	case DELETE = "DELETE"
}

public struct Request{
	let url: URL = ({
		let scheme = ProcessInfo.processInfo.environment["REQUEST_SCHEME"]!
		let host = ProcessInfo.processInfo.environment["HTTP_HOST"]!
		let port = ProcessInfo.processInfo.environment["SERVER_PORT"]!
		let url = ProcessInfo.processInfo.environment["REQUEST_URI"]!
		return URL(string: "\(scheme)://\(host):\(port)\(url)")!
	})()
	let method = RequestMethod(rawValue: ProcessInfo.processInfo.environment["REQUEST_METHOD"]!)!
	let body = Request.Body()
	let headers: [String: String] = ({
		var out: [String: String] = [:]
		for (key, value) in ProcessInfo.processInfo.environment{
			if key.hasPrefix("HTTP_"){
				out[key] = value
			}
		}
		return out
	})()
}

public extension Request{
	struct Body: CustomStringConvertible{
		let value = ({
			() -> String? in
			var out: [String] = []
			var line = readLine()
			while(line != nil){
				out.append(line!)
				line = readLine()
			}
			return out.count == 0 ? nil : out.joined(separator: "\n")
		})()

		public var description: String {
			get {
				return self.value ?? ""
			}
		}
	}
}