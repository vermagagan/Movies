import UIKit
class imageLoader{
    static let shared = imageLoader()
    private let cache = imageCache.shared
    private init(){}
    
    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void){
        if let image = cache.getImage(for: url){
            DispatchQueue.main.async {
                completion(image)
            }
            return
        }
        
        guard let imageUrl = URL(string: url) else{
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: imageUrl),
                  let image = UIImage(data: data) else{
                      DispatchQueue.main.async {
                          completion(nil)
                      }
                      return
                  }
            self.cache.setImage(image, for: url)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
    }
}
