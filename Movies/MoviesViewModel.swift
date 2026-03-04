import Foundation
class MoviesViewModel{
    private let network = NetworkManager()
    var filteredMovies:[Movie] = []
    private(set) var movies:[Movie] = []
    
    var state: ((ViewState) -> Void)?
    var onDataUpload : (() -> Void)?
    
    private var currentpage = 1
    private var isLoading = false
    private var hasmoreData = true
    
    func fetchMovies(isNewLoad : Bool = true){
        if isLoading || !hasmoreData{return}
        
        if isNewLoad{
            currentpage = 1
            movies.removeAll()
            filteredMovies.removeAll()
            hasmoreData = true
        }
        isLoading = true
        state?(.loading)
        network.fetchMovies(page: currentpage){[weak self] result in
            guard let self = self else{return}
            DispatchQueue.main.async{
                
                self.isLoading = false
                
                switch result{
                case .success(let movie):
                    if movie.isEmpty{
                        self.hasmoreData = false
                        self.state?(.empty)
                        return
                    }
                    if self.currentpage == 1{
                        CoreDataManager.shared.clearCachedMovies()
                    }
                    CoreDataManager.shared.saveMovies(movie)
                    
                    self.movies.append(contentsOf: movie)
                    self.filteredMovies = self.movies
                    self.currentpage += 1
                    
                    self.state?(.success)
                    self.onDataUpload?()
                    
                    
                case .failure:
                    let cached = CoreDataManager.shared.fetchCachedMovies()
                    
                    if cached.isEmpty{
                        self.state?(.error("No Internet and cached data"))
                    }
                    self.movies = cached
                    self.filteredMovies = cached
                    self.state?(.success)
                    self.onDataUpload?()
                }
            }
        }
    }
    
    
    func filterMovies(query: String) {
        if query.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies = movies.filter {
                $0.title.lowercased().contains(query.lowercased())
            }
        }
        onDataUpload?()
    }
    
    
    func movie(at index: Int) -> Movie {
        guard index >= 0, index < filteredMovies.count else{
            fatalError("Index\(index) out of range for filteredMovies.count\(filteredMovies.count)")
        }
            return filteredMovies[index]
        }

    var count: Int {
            return filteredMovies.count
        }
    
    func refreshMovies(){
        filteredMovies.removeAll()
        movies.removeAll()
        fetchMovies()
    }
    
}
enum ViewState{
    case loading
    case error(String)
    case success
    case empty
}
