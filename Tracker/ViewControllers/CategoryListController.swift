
import UIKit

final class CategoryListController: UIViewController {
    
    var categories: [String] = ["Важное"] // Пока добавим только одну категорию для примера
    private var hasCategories: Bool = true
    weak var delegate: CategoryListControllerDelegate?
    private var selectedCategory: String?
    
    // MARK: - UI Elements
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "trackerPlaceholder")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor(named: "backgroundGray")
        table.layer.cornerRadius = 16
        table.separatorStyle = .none
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        updateUI()
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let numberOfRows = categories.count
        let rowHeight: CGFloat = 75
        let totalHeight = CGFloat(numberOfRows) * rowHeight
        tableView.frame.size.height = totalHeight
    }
    
    init(selectedCategory: String?) {
        self.selectedCategory = selectedCategory
        super.init(nibName: nil, bundle: nil)
        print("\(#file):\(#line)] \(#function) Инициализирован с категорией: \(String(describing: selectedCategory))")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(addCategoryButton)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            // Констрейнты для tableView
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Констрейнты для placeholderImageView
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Констрейнты для placeholderLabel
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Констрейнты для addCategoryButton
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        let numberOfRows = categories.count
        let rowHeight: CGFloat = 75
        let totalHeight = CGFloat(numberOfRows) * rowHeight
        tableView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
    }
    
    private func updateUI() {
        hasCategories = !categories.isEmpty
        placeholderImageView.isHidden = hasCategories
        placeholderLabel.isHidden = hasCategories
        tableView.isHidden = !hasCategories
        
        if categories.count >= 2 {
            tableView.separatorStyle = .singleLine
        } else {
            tableView.separatorStyle = .none
        }
    }
    
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Категория"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        navigationItem.titleView = containerView
        
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()
            
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
        }
    }
    
    // MARK: - Actions
    
    @objc private func addCategoryButtonTapped() {
        let categoryNameController = CategoryNameController()
        let navigationController = UINavigationController(rootViewController: categoryNameController)
        navigationController.modalPresentationStyle = .automatic
        print("\(#file):\(#line)] \(#function) Переход к экрану создания новой категории")
        present(navigationController, animated: true)
    }
}

extension CategoryListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row]
        
        cell.textLabel?.text = category
        if let textLabel = cell.textLabel {
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                textLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                textLabel.trailingAnchor.constraint(lessThanOrEqualTo: cell.contentView.trailingAnchor, constant: -40)
            ])
        }
        
        cell.backgroundColor = .white
        cell.contentView.backgroundColor = UIColor(named: "backgroundGray")
        cell.selectionStyle = .none
        
        guard let checkmarkImage = UIImage(systemName: "checkmark") else {
            return cell
        }
        
        let checkmark: UIImageView
        if let existingCheckmark = cell.contentView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            checkmark = existingCheckmark
        } else {
            checkmark = UIImageView(image: checkmarkImage)
            checkmark.tintColor = .blue
            checkmark.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(checkmark)
            
            NSLayoutConstraint.activate([
                checkmark.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                checkmark.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
            ])
        }
        
        checkmark.isHidden = category != selectedCategory
        
        let heightConstraint = cell.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 75)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        
        if indexPath.row == categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row]
        self.selectedCategory = selectedCategory
        tableView.reloadData()
        delegate?.didSelectCategory(selectedCategory)
        delegate?.didUpdateCategories(categories)
        print("\(#file):\(#line)] \(#function) Выбрана категория: \(selectedCategory)")
        dismiss(animated: true)
    }
}

