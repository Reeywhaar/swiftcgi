enum Controllers{}

extension Controllers{
	class PostController{
		class func index(request: Request) -> Response{
			let context = [
				"post": Post(
					title: "Great Dinotopia By James Gourney",
					body: "Sample text"
				)
			]
			let renderer = ServiceLocator.get("Renderer") as! Renderer;
			return .html(renderer.render("post.html", context))
		}
	}
}