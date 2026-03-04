import CoreData
import UIKit
class CoreDataManager{
    static let shared = CoreDataManager()
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    private init(){}
    func savefavourites(movie: Movie){
        let fav = FavouriteMovie(context: context)
        fav.id = Int64(movie.id)
        fav.title = movie.title
        fav.image = movie.image
        fav.link = movie.link
        
        savecontext()
    }
    
    func fetchMovies() -> [FavouriteMovie] {
        let request: NSFetchRequest<FavouriteMovie> = FavouriteMovie.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }

    func fetchFavourites() -> [FavouriteMovie]{
        let request : NSFetchRequest<FavouriteMovie> = FavouriteMovie.fetchRequest()
        return (try?context.fetch(request)) ?? []
    }
    func deleteFavourites(id: Int){
        let request : NSFetchRequest<FavouriteMovie> = FavouriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d",id)
        
        if let result = try? context.fetch(request).first{
            context.delete(result)
            savecontext()        }
    }
    func isFavourites(id: Int)-> Bool{
        let request : NSFetchRequest<FavouriteMovie> = FavouriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        return((try? context.count(for: request)) ?? 0) > 0
    }
    private func savecontext(){
        if context.hasChanges{
            try? context.save()
        }
    }
    func toggle(_ movie: Movie){
        if isFavourites(id: movie.id){
            deleteFavourites(id: movie.id)
        }
        else{
            savefavourites(movie: movie)
        }
        
    }
    
    func saveMovies(_ movies: [Movie]){
       for movie in movies{
           let entity = MovieEntity(context: context)
            entity.id = Int64(movie.id)
            entity.title = movie.title
            entity.image = movie.image
            entity.link = movie.link
        }
        savecontext()
    }
    
    func fetchCachedMovies() -> [Movie]{
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        let entities = (try? context.fetch(request)) ?? []
        
        return entities.map{
            Movie(id: Int($0.id),
                  title: $0.title ?? " ",
                  image: $0.image,
                  link: $0.link ?? " "
            )
        }
    }
    
    func clearCachedMovies(){
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        let result = (try? context.fetch(request)) ?? []
        result.forEach{context.delete($0)}
        savecontext()
    }
    
}
