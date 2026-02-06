import UIKit
class MoviesVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate{
    

    @IBOutlet var tableView: UITableView!
    
    let network = NetworkManager()
    let searchbar = UISearchBar()
    var movies:[Movie] = []
    var filteredMovies:[Movie] = []
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchbar.placeholder = "Search Movies"
        searchbar.delegate = self
        navigationItem.titleView = searchbar
        setupTable()
        network.fetchMovies{ result in
            DispatchQueue.main.async{
                switch result{
                case .success(let movies):
                    self.movies = movies
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
        tableView.keyboardDismissMode = .onDrag
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredMovies.count : movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = isSearching ? filteredMovies[indexPath.row] : movies[indexPath.row]
        cell.configure(with: movie)
        
        cell.actionButton.tag = indexPath.row
        cell.actionButton.addTarget(self, action: #selector(playTapped(_:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MoviesDetailVC()
        vc.movie = isSearching ? filteredMovies[indexPath.row] : movies[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupTable(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
    }
    
    @objc func playTapped(_ sender : UIButton){
        let index = sender.tag
        print("Play: ", movies[index].title)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            isSearching = false
            filteredMovies.removeAll()
        }
        else{
            isSearching = true
            filteredMovies = movies.filter{
                $0.title.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}
