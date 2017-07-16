import Stencil
import PathKit

public class Renderer{
	private let environment: Environment
	init(_ paths: [Path] = ["views/"]){
		self.environment = Environment(loader: FileSystemLoader(paths: paths))
	}

	public func render(_ templateName: String, _ context: [String: Any]? = nil) -> String{
		let rendered = try! self.environment.renderTemplate(name: "post.html", context: context)
		return rendered
	}
}