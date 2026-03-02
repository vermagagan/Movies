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
        network.fetchMovies(page: currentpage){result in
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                
                self.isLoading = false
                
                switch result{
                case .success(let movie):
                    if movie.isEmpty{
                        self.hasmoreData = false
                        self.state?(.empty)
                        return
                    }
                    self.movies.append(contentsOf: movie)
                    self.filteredMovies = self.movies
                    self.currentpage = +1
                    
                    self.state?(.success)
                    self.onDataUpload?()
                    
                    
                case .failure(let error):
                    self.state?(.error(error.localizedDescription))
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
