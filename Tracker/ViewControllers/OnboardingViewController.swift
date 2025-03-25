
import UIKit

final class OnboardingViewController: UIViewController {
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        guard let image = UIImage(named: "onboardingScreen1") else {
            print("\(#file):\(#line)] Ошибка загрузки изображения onboardingScreen1")
            return imageView
        }
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let wowTechnologyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.backgroundColor = .blackYPBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(wowTechnologyButton)
        
        wowTechnologyButton.addTarget(self, action: #selector(wowTechnologyButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            wowTechnologyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            wowTechnologyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            wowTechnologyButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 668),
            wowTechnologyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func wowTechnologyButtonTapped() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
}
