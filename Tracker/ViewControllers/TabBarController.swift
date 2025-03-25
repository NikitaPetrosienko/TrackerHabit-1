
import UIKit

final class TabBarController: UITabBarController {
    
    let trackerNavigationController = TrackersViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController()
        
    }
    
    func tabBarController() {
        let trackers = UINavigationController(rootViewController: trackerNavigationController)
        
        let trackerText: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        trackers.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "Trackers"),
            selectedImage: nil
        )
        trackers.tabBarItem.setTitleTextAttributes(trackerText as [NSAttributedString.Key : Any], for: .normal)
        
        let statistic = UIViewController()
        statistic.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "Statistic"),
            selectedImage: nil
        )
        statistic.tabBarItem.setTitleTextAttributes(trackerText as [NSAttributedString.Key : Any], for: .normal)
        
        viewControllers = [trackers, statistic]
        
        tabBar.tintColor = UIColor(named: "tabBarTintColor")
        tabBar.backgroundColor = .white
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.lightGray.cgColor
    }
}
