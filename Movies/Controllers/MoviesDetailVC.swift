import UIKit

class MoviesDetailVC: UIViewController {
    
    var movie: Movie?
    let posterImage = UIImageView()
    let titleLabel = UILabel()
    let favouriteButton = UIButton(type: .system)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setup()
        configure()
        updateButtonTitle()
    }
    
    
    func setup(){
        posterImage.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        favouriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        posterImage.contentMode = .scaleAspectFit
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center
        
        favouriteButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        
        view.addSubview(posterImage)
        view.addSubview(titleLabel)
        view.addSubview(favouriteButton)
        
        NSLayoutConstraint.activate([
            posterImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            posterImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            posterImage.widthAnchor.constraint(equalToConstant: 200),
            posterImage.heightAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: posterImage.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            favouriteButton.topAnchor.constraint(equalTo: posterImage.bottomAnchor, constant: 20),
            favouriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func configure(){
        guard let movies = movie else {return}
        titleLabel.text = movies.title
        if let imageurl = movies.image,
           let url = URL(string: imageurl){
            URLSession.shared.dataTask(with: url){data,_,_ in
                if let data = data{
                    DispatchQueue.main.async{
                        self.posterImage.image = UIImage(data: data)
                    }
                }
                
            }.resume()
            
        }
    }
    
    @objc func addTapped(){
        guard let movie = movie else{return}
        CoreDataManager.shared.toggle(movie)
        updateButtonTitle()
    }
    func updateButtonTitle(){
        guard let movie = movie else {return}
        let isFav = CoreDataManager.shared.isFavourites(id: movie.id)
        favouriteButton.setTitle(isFav ? "Remove Favourites" : "Add Favourites", for: .normal)
        
    }
}
