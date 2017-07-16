public class Response {
	var status: Int = 200
	var body: String?
	var headers: [String: String] = [:]
	var contentType: ContentType = .text

	init(){
		self.status = 200
		self.body = nil
		self.headers = [:]
		self.contentType = .text
	}

	init(_ body: String?, _ contentType: ContentType = .text){
		self.status = 200
		self.body = body
		self.headers = [:]
		self.contentType = contentType
	}

	class func empty() -> Response {
		return Response()
	}

	class func text(_ text: String) -> Response {
		return Response(text, .text)
	}

	class func html(_ text: String) -> Response {
		return Response(text, .html)
	}

	class func json(_ text: String) -> Response {
		return Response(text, .json)
	}

	class func xml(_ text: String) -> Response {
		return Response(text, .xml)
	}

	func setStatus(_ status: Int) -> Self {
		self.status = status
		return self
	}

	func send(){
		print("Status: \(self.status)")
		print("Content-Type: \(self.contentType.toString())")
		for (key, value) in self.headers{
			print("\(key): \(value)")
		}
		print()
		if let body = self.body {
			print(body, terminator:"")
		}
	}
}

public enum ContentType{
	case text
	case html
	case json
	case xml
	case custom(String)

	func toString() -> String {
		switch self {
			case .text:
				return "text/plain"
			case .html:
				return "text/html"
			case .json:
				return "application/json"
			case .xml:
				return "application/xml"
			case .custom(let value):
				return value
		}
	}
}