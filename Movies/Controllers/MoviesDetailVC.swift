import UIKit

class MoviesDetailVC: UIViewController {
    
    let posterImage = UIImageView()
    let titleLabel = UILabel()
    
    var movie : Movie?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setup()
        configure()
    }
    
    
    func setup(){
        posterImage.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        posterImage.contentMode = .scaleAspectFit
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center
        
        view.addSubview(posterImage)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            posterImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            posterImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            posterImage.widthAnchor.constraint(equalToConstant: 200),
            posterImage.heightAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: posterImage.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
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
}
