import UIKit

class TabBarVC: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let moviesVC = MoviesVC()
        moviesVC.title = "Movies"
        
        let favVC = FavouritesVC()
        favVC.title = "Favourites"
        
        let nav1 = UINavigationController(rootViewController: moviesVC)
        let nav2 = UINavigationController(rootViewController: favVC)
        
        nav1.tabBarItem = UITabBarItem(title: "Movies",
                                       image: (UIImage(systemName: "film")),
                                       tag: 0)
        
        nav2.tabBarItem = UITabBarItem(title: "Favourites",
                                       image: (UIImage(systemName: "star.fill")),
                                       tag: 1)
        viewControllers = [nav1 , nav2]
    }
    

}
