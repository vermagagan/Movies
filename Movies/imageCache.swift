
import Foundation
import UIKit

class imageCache{
    static let shared = imageCache()
    private init (){}
    
    private let cache = NSCache<NSString, UIImage>()
    
    func getImage(for key: String) -> UIImage?{
        return cache.object(forKey: key as NSString)
    }
    func setImage(_ image: UIImage,for key: String){
        return cache.setObject(image, forKey: key as NSString)
    }
}
