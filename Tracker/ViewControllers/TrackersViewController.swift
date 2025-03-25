
import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    
    let layoutParams = LayoutParams()
    var filteredCategories: [TrackerCategory] = []
    var categories: [TrackerCategory] = []
    var currentDate: Date = Date()
    var completedTrackers: Set<CompletedTrackerID> = []
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        formatter.locale = Locale(identifier: "ru")
        return formatter
    }()
    
    struct LayoutParams {
        let columnCount: Int = 2
        let interItemSpacing: CGFloat = 9
        let leftInset: CGFloat = 16
        let rightInset: CGFloat = 16
        
        var totalInsetWidth: CGFloat {
            leftInset + rightInset + interItemSpacing * (CGFloat(columnCount) - 1)
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plusButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        searchBar.tintColor = .black
        return searchBar
    }()
    
    private lazy var placeholderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        return stack
    } ()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "trackerPlaceholder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .label
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar.firstWeekday = 2
        picker.widthAnchor.constraint(equalToConstant: 120).isActive = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        picker.tintColor = .blue
        
        if let textLabel = picker.subviews.first?.subviews.first as? UILabel {
            textLabel.font = .systemFont(ofSize: 17)
        }
        return picker
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        collectionView.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "footer"
        )
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setupPlaceholder()
        setupCollectionView()
        updatePlaceholderVisibility()
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        placeholderStack.addArrangedSubview(placeholderImageView)
        placeholderStack.addArrangedSubview(placeholderLabel)
        view.addSubview(placeholderStack)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        let addButton = UIButton(frame: CGRect(x: 6, y: 0, width: 42, height: 42))
        addButton.setImage(UIImage(named: "plusButton"), for: .normal)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        let addBarButton = UIBarButtonItem(customView: addButton)
        let dateBarButton = UIBarButtonItem(customView: datePicker)
        navigationItem.leftBarButtonItem = addBarButton
        navigationItem.rightBarButtonItem = dateBarButton
    }
    
    private func setupPlaceholder() {
        placeholderStack.isHidden = false
        
        NSLayoutConstraint.activate([
            placeholderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupCollectionView() {
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func filterTrackersByDate(_ date: Date) -> [TrackerCategory] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let adjustedWeekday = WeekDay(rawValue: weekday == 1 ? 7 : weekday - 1) ?? .monday
        print("\(#file):\(#line)] \(#function) Фильтрация для даты: \(date), день недели: \(adjustedWeekday.shortName)")
        
        let filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let isIrregularEvent = tracker.scheldue.count == 1 && tracker.creationDate != nil
                if isIrregularEvent {
                    let isCompletedInAnyDay = completedTrackers.contains { completedID in
                        completedID.id == tracker.id
                    }
                    if isCompletedInAnyDay {
                        let isCompletedOnThisDay = completedTrackers.contains { completedID in
                            completedID.id == tracker.id && calendar.isDate(completedID.date, inSameDayAs: date)
                        }
                        print("\(#file):\(#line)] \(#function) Нерегулярное событие '\(tracker.title)' выполнено, отображается: \(isCompletedOnThisDay)")
                        return isCompletedOnThisDay
                    } else {
                        print("\(#file):\(#line)] \(#function) Нерегулярное событие '\(tracker.title)' не выполнено, отображается")
                        return true
                    }
                } else {
                    let isScheduledForToday = tracker.scheldue.contains(adjustedWeekday)
                    print("\(#file):\(#line)] \(#function) Регулярная привычка '\(tracker.title)': запланирована на \(adjustedWeekday.shortName), показывать: \(isScheduledForToday)")
                    return isScheduledForToday
                }
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        print("\(#file):\(#line)] \(#function) Найдено после фильтрации: категорий - \(filteredCategories.count), трекеров - \(filteredCategories.reduce(0) { $0 + $1.trackers.count })")
        return filteredCategories
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        let newTrackerController = NewTrackerController()
        newTrackerController.delegate = self
        let navigationController = UINavigationController(rootViewController: newTrackerController)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        let formattedDate = dateFormatter.string(from: sender.date)
        print("\(#file):\(#line)] \(#function) Выбрана дата: \(formattedDate)")
        
        filteredCategories = filterTrackersByDate(currentDate)
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    // MARK: - Private Methods
    
    private func updatePlaceholderVisibility() {
        let hasVisibleTrackers = !filteredCategories.isEmpty
        
        placeholderStack.isHidden = hasVisibleTrackers
        collectionView.isHidden = !hasVisibleTrackers
        print("\(#file):\(#line)] \(#function) Всего трекеров: \(categories.count), Видимых трекеров: \(filteredCategories.count)")
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let checkDate = calendar.startOfDay(for: date)
        return checkDate > today
    }
    
    private func setupDatePickerFormat() {
        datePicker.locale = Locale(identifier: "ru_RU")
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru_RU")
        datePicker.calendar = calendar
    }
    
    func showCategoryList(selectedCategory: String? = nil) {
        let categoryListController = CategoryListController(selectedCategory: selectedCategory)
        categoryListController.delegate = self
        let navigationController = UINavigationController(rootViewController: categoryListController)
        present(navigationController, animated: true)
        print("\(#file):\(#line)] \(#function) Открыт список категорий с категорией: \(String(describing: selectedCategory))")
    }
    
    func handleCategorySelection(_ category: String) {
        print("Выбрана категория: \(category)")
    }
    
    // MARK: - TrackerManagement
    
    func isTrackerCompleted(_ tracker: Tracker, date: Date) -> Bool {
        let completedID = CompletedTrackerID(id: tracker.id, date: date)
        return completedTrackers.contains(completedID)
    }
    
    func addTrackerRecord(_ tracker: Tracker, date: Date) {
        let completedID = CompletedTrackerID(id: tracker.id, date: date)
        completedTrackers.insert(completedID)
        print("\(#file):\(#line)] \(#function) Добавлен трекер: \(tracker.title) на дату: \(date)")
        collectionView.reloadData()
    }
    
    func removeTrackerRecord(_ tracker: Tracker, date: Date) {
        let completedID = CompletedTrackerID(id: tracker.id, date: date)
        completedTrackers.remove(completedID)
        print("\(#file):\(#line)] \(#function) Удален трекер: \(tracker.title) с даты: \(date)")
        collectionView.reloadData()
    }
    
    func countCompletedDays(for tracker: Tracker) -> Int {
        completedTrackers.filter { $0.id == tracker.id }.count
    }
    
    func createCategory(withTitle title: String) {
        let newCategory = TrackerCategory(title: title, trackers: [])
        categories.append(newCategory)
        filteredCategories = filterTrackersByDate(currentDate)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updatePlaceholderVisibility()
            print("\(#file):\(#line)] \(#function) Добавлена новая категория: \(title)")
        }
    }
    
    struct CompletedTrackerID: Hashable {
        let id: UUID
        let date: Date
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(Calendar.current.startOfDay(for: date))
        }
        
        static func == (lhs: CompletedTrackerID, rhs: CompletedTrackerID) -> Bool {
            return lhs.id == rhs.id &&
            Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(#file):\(#line)] \(#function) Выделена ячейка: \(indexPath.item)")
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] suggestedActions in
            let pinAction = UIAction(title: "Закрепить", image: UIImage(systemName: "pin")) { [weak self] _ in
                print("\(#file):\(#line)] \(#function) Закрепить трекер")
            }
            
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { [weak self] _ in
                print("\(#file):\(#line)] \(#function) Редактировать трекер")
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                guard let self = self else { return }
                let alert = UIAlertController(
                    title: "Удалить трекер?",
                    message: "Эта операция не может быть отменена",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
                alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                    self?.deleteTracker(at: indexPath)
                })
                self.present(alert, animated: true)
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("\(#file):\(#line)] \(#function) Снято выделение с ячейки: \(indexPath.item)")
    }
}

// MARK: - NewHabitControllerDelegate

extension TrackersViewController: NewHabitControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, category: String) {
        var newCategories = categories
        
        if let index = categories.firstIndex(where: { $0.title == category }) {
            let existingCategory = categories[index]
            let newTrackers = existingCategory.trackers + [tracker]
            let updatedCategory = TrackerCategory(title: category, trackers: newTrackers)
            newCategories[index] = updatedCategory
        } else {
            let newCategory = TrackerCategory(title: category, trackers: [tracker])
            newCategories.append(newCategory)
        }
        categories = newCategories
        filteredCategories = filterTrackersByDate(currentDate)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updatePlaceholderVisibility()
            print("\(#file):\(#line)] \(#function) Трекер добавлен в новый массив категорий. Всего категорий: \(self.categories.count)")
            
        }
    }
}

extension TrackersViewController {
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        var newCategories = categories
        if let categoryIndex = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let existingCategory = categories[categoryIndex]
            let newTrackers = existingCategory.trackers + [tracker]
            let updatedCategory = TrackerCategory(title: categoryTitle, trackers: newTrackers)
            newCategories[categoryIndex] = updatedCategory
            print("\(#file):\(#line)] \(#function) Добавлен трекер \(tracker.title) в категорию \(categoryTitle)")
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            newCategories.append(newCategory)
            print("\(#file):\(#line)] \(#function) Создана новая категория \(categoryTitle) с трекером \(tracker.title)")
        }
        categories = newCategories
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        guard indexPath.section < filteredCategories.count else {
            print("\(#file):\(#line)] \(#function) Ошибка: индекс секции \(indexPath.section) выходит за пределы \(filteredCategories.count)")
            return
        }
        
        let filteredCategory = filteredCategories[indexPath.section]
        guard indexPath.item < filteredCategory.trackers.count else {
            print("\(#file):\(#line)] \(#function) Ошибка: индекс трекера \(indexPath.item) выходит за пределы \(filteredCategory.trackers.count)")
            return
        }
        let trackerToDelete = filteredCategory.trackers[indexPath.item]
        guard let categoryIndex = categories.firstIndex(where: { $0.title == filteredCategory.title }) else {
            print("\(#file):\(#line)] \(#function) Ошибка: категория не найдена \(filteredCategory.title)")
            return
        }
        var updatedTrackers = categories[categoryIndex].trackers
        if let trackerIndex = updatedTrackers.firstIndex(where: { $0.id == trackerToDelete.id }) {
            updatedTrackers.remove(at: trackerIndex)
            completedTrackers = completedTrackers.filter { $0.id != trackerToDelete.id }
            
            if updatedTrackers.isEmpty {
                categories.remove(at: categoryIndex)
                print("\(#file):\(#line)] \(#function) Категория удалена: \(filteredCategory.title)")
            } else {
                categories[categoryIndex] = TrackerCategory(title: filteredCategory.title, trackers: updatedTrackers)
            }
            filteredCategories = filterTrackersByDate(currentDate)
            print("\(#file):\(#line)] \(#function) Трекер успешно удален: \(trackerToDelete.title)")
            collectionView.reloadData()
            updatePlaceholderVisibility()
        } else {
            print("\(#file):\(#line)] \(#function) Ошибка: трекер не найден в категории")
        }
    }
}

extension TrackersViewController: CategoryListControllerDelegate {
    func didSelectCategory(_ category: String) {
        if !categories.contains(where: { $0.title == category }) {
            createCategory(withTitle: category)
        }
    }
    
    func didUpdateCategories(_ categories: [String]) {
        collectionView.reloadData()
        print("\(#file):\(#line)] \(#function) Обновлены категории: \(categories)")
    }
}
