import UIKit

class MovieCell: UITableViewCell {
    let posterImage = UIImageView()
    let titleLable = UILabel()
    let actionButton = UIButton(type: .system)
    private var link : String?
    var currentImageUrl : String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        posterImage.translatesAutoresizingMaskIntoConstraints = false
        
        posterImage.layer.cornerRadius = 6
        posterImage.contentMode = .scaleAspectFit
        posterImage.clipsToBounds = true
        
        actionButton.setTitle("Play", for: .normal)
        actionButton.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
        
        contentView.addSubview(titleLable)
        contentView.addSubview(actionButton)
        contentView.addSubview(posterImage)
        
        NSLayoutConstraint.activate([
            posterImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            posterImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            posterImage.widthAnchor.constraint(equalToConstant: 60),
            posterImage.heightAnchor.constraint(equalToConstant: 90),
            
            
            
            titleLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 150),
            titleLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func configure(with movie: Movie){
        titleLable.text = movie.title
        link = movie.link
        posterImage.image = nil
        
        
       guard let imageUrl = movie.image, !imageUrl.isEmpty else{
           posterImage.image = UIImage(systemName: "film")
           return
        }
        
        currentImageUrl = imageUrl
        
        imageLoader.shared.loadImage(from: imageUrl){ [weak self] image in
            guard let self = self else{return}
            
            if self.currentImageUrl == imageUrl{
                self.posterImage.image = image
            }
        }
        
        
    }
    
    func loadImage(urlString : String){
        if let cachedImage = imageCache.shared.getImage(for: urlString){
            posterImage.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else {
            posterImage.image = UIImage(systemName: "film")
            return
        }
        
        URLSession.shared.dataTask(with: url){data,_,_ in
            if let data = data, let image = UIImage(data: data){
                DispatchQueue.main.async{
                    self.posterImage.image = image
                }
            }
            else{
                DispatchQueue.main.async{
                    self.posterImage.image = UIImage(systemName: "film")
                }
            }
        }.resume()
    }
    @objc func tapped(_ sender: UIButton){
        guard let movieLink = link,
              let url = URL(string: movieLink)else{return}
        
        UIApplication.shared.open(url)
    }
}
