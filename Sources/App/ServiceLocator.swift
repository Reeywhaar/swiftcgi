public class ServiceLocator{
	public static var services: [String:Any] = [:]
	public class func set(name: String, service: Any){
		self.services[name] = service
	}
	public class func get(_ name: String) -> Any{
		return self.services[name]!
	}
}