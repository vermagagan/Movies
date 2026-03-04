import UIKit
class MoviesVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate{
    
    let searchbar = UISearchBar()
    let tableView = UITableView()
    let viewmodel = MoviesViewModel()
    let loader = UIActivityIndicatorView(style: .large)
    let messageLabel = UILabel()
    let retryButton = UIButton()
    let errorLabel =  UILabel()
    let refreshControl = UIRefreshControl()
    
    var searchWorkItem : DispatchWorkItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchbar.placeholder = "Search Movies"
        searchbar.delegate = self
        navigationItem.titleView = searchbar
        
        setupTable()
        setupRetryButton()
        setupErrorLabel()
        setupStateUI()
        
        bindViewModel()
        bindState()
        
        view.bringSubviewToFront(retryButton)
        view.bringSubviewToFront(errorLabel)

        fetchMovies()
        tableView.keyboardDismissMode = .onDrag
        
        NetworkMonitor.shared.onStatusChanged = {[weak self] connected in
            guard let self else {return}
            if connected{
                self.fetchMovies()
            }else {
                self.tableView.isHidden = true
                self.errorLabel.isHidden = false
                self.retryButton.isHidden = false
            }
        }
    }
    func setupErrorLabel(){
        errorLabel.textAlignment = .center
        errorLabel.textColor = .red
        errorLabel.text = "Internet not connected"
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
                    errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    func setupRetryButton(){
        retryButton.setTitle("Retry", for: .normal)
            retryButton.backgroundColor = .systemPink
            retryButton.layer.cornerRadius = 8
            retryButton.isHidden = true
            retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

            retryButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(retryButton)

            NSLayoutConstraint.activate([
                retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                retryButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                retryButton.widthAnchor.constraint(equalToConstant: 120),
                retryButton.heightAnchor.constraint(equalToConstant: 44)
            ])
    }
    func setupStateUI(){
        loader.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        loader.center = view.center
        loader.color = .red
        view.addSubview(loader)
        view.addSubview(messageLabel)
        NSLayoutConstraint.activate([
                loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),

                messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.frame = view.bounds
        messageLabel.isHidden = true
        
    }
    func bindState(){
        viewmodel.state = {[weak self] state in
            guard let self else{return}
            switch state{
            case .loading:
                self.loader.startAnimating()
                self.messageLabel.isHidden = true
            case .empty:
                self.loader.stopAnimating()
                self.refreshControl.endRefreshing()
                self.messageLabel.isHidden = false
                self.messageLabel.text = "Empty"
            case .error(let error):
                self.loader.stopAnimating()
                self.refreshControl.endRefreshing()
                self.messageLabel.text = error
                self.messageLabel.isHidden = false
            case .success:
                self.loader.stopAnimating()
                self.refreshControl.endRefreshing()
                self.messageLabel.isHidden = true
            }
        }
    }
    func bindViewModel(){
        viewmodel.onDataUpload = {[weak self] in
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.rowHeight = 110
        tableView.separatorStyle = .none
        return viewmodel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        guard indexPath.row < viewmodel.filteredMovies.count else {
                return cell
            }
        
        let movie = viewmodel.filteredMovies[indexPath.row]
        cell.configure(with: movie)
        cell.actionButton.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < viewmodel.filteredMovies.count else { return }
        
        let vc = MoviesDetailVC()
        vc.movie = viewmodel.filteredMovies[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    func fetchMovies(){
        if NetworkMonitor.shared.isConnected{
            errorLabel.isHidden = true
            retryButton.isHidden = true
            tableView.isHidden = false
            viewmodel.fetchMovies(isNewLoad: true)
        }
        else{
            tableView.isHidden = true
            errorLabel.isHidden = false
            retryButton.isHidden = false
        }
    }
    func setupTable(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
        
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        view.addSubview(tableView)
        
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        
        let workItem = DispatchWorkItem{ [weak self ] in
            self?.viewmodel.filterMovies(query: searchText)
        }
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: workItem)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let frameHeight = scrollView.frame.size.height

            if position > contentHeight - frameHeight - 100 {
                viewmodel.fetchMovies(isNewLoad: false)
            }
    }
    @objc func retryTapped(){
        errorLabel.isHidden = true
        retryButton.isHidden = true
        loader.startAnimating()
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.fetchMovies()
        }
    }
    @objc func refreshPulled(){
        viewmodel.refreshMovies()
    }
}
