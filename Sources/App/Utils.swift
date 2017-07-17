import Darwin

func random(_ max: Int) -> Int{
	return Int(arc4random_uniform(UInt32(max)))
}