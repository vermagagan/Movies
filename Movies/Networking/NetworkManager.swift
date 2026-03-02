import Foundation
class NetworkManager{
    func fetchMovies(page: Int,completion: @escaping (Result<[Movie],Error>) -> Void){
        let url = URL(string : "https://dummyjson.com/c/7124-c599-4440-8ff2")!
        
        URLSession.shared.dataTask(with: url){data, _, error in

            if let error = error{
                completion(.failure(error))
                return
            }
            
            guard let data = data else{
                return
            }
            
            do{
                let decoded = try JSONDecoder().decode([Movie].self, from: data)
                completion(.success(decoded))
            }catch{
                completion(.failure(error))
            }
            
        }.resume()
    }
}
