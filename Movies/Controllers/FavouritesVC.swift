import UIKit

class FavouritesVC: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    let tableView = UITableView()
    var favourites: [FavouriteMovie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setup()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favourites = CoreDataManager.shared.fetchMovies()
        tableView.reloadData()
    }
    func setup(){
        tableView.frame = view.bounds
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favourites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = favourites[indexPath.row].title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVc = MoviesDetailVC()
        let favmovie = favourites[indexPath.row]
        let movie = Movie(
            id: Int(favmovie.id),
            title: favmovie.title ?? " ",
            image: favmovie.image,
            link: favmovie.link ?? " "
        )
        detailVc.movie = movie
        navigationController?.pushViewController(detailVc, animated: true)
    }
    
}
