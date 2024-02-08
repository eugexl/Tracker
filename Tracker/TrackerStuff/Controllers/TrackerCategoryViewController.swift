//
//  TrackerCategoryViewController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 03.02.2024.
//

import UIKit

final class TrackerCategoryViewController: UIViewController {
    
    private static var lastUsedCategory: String = ""
    
    weak var delegate: TrackerCreationViewController?
    weak var viewModel: TrackerViewModelProtocol?
    var rowsInTable: Int = 0
    
    private let buttonAdd = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: ColorNames.black)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        button.tintColor = .orange
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(UIColor(named: ColorNames.white), for: .normal)
        button.layer.cornerRadius = 16.0
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let tableView = {
        let tableView = UITableView()
        tableView.bounces = false
        tableView.isScrollEnabled = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackerCategoryTableCell.self, forCellReuseIdentifier: TrackerCategoryTableCell.reuseIdentifier)
        tableView.reloadData()
        setupUI()
    }
    
    init(delegate: TrackerCreationViewController? = nil, viewModel: TrackerViewModelProtocol? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = delegate
        self.viewModel = viewModel
        
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        
        view.backgroundColor = UIColor(named: ColorNames.white)
        
        [buttonAdd, tableView, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -136),
            buttonAdd.heightAnchor.constraint(equalToConstant: 60),
            buttonAdd.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            buttonAdd.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonAdd.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)
        buttonAdd.addTarget(self, action: #selector(addNewCategory), for: .touchUpInside)
    }
    
    private func setupBindings(){
        viewModel?.updateCategoriesData = tableView.reloadData
    }
    
    @objc
    private func addNewCategory(){
        
        let newCategoryVC = TrackerNewCategoryViewController(viewModel: viewModel)
        present(newCategoryVC, animated: true)
    }
}

extension TrackerCategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? TrackerCategoryTableCell
        cell?.accessoryType = .checkmark
        
        let categoryTitle = cell?.labelText ?? ""
        
        TrackerCategoryViewController.lastUsedCategory = categoryTitle
        
        delegate?.trackerCategory = categoryTitle
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let categoryTitle = viewModel?.categoryTitleFromTotalList(for: indexPath.row) ?? ""
        
        let contextMenu = UIContextMenuConfiguration(actionProvider: { _ in
            return UIMenu(children: [
                UIAction(title: "Редактировать", handler: { [weak self] _ in
                    guard let self = self else { return }
                    let newCategoryVC = TrackerNewCategoryViewController(viewModel: self.viewModel, controllerType: .edit, previousTitle: categoryTitle)
                    self.present(newCategoryVC, animated: true)
                }),
                UIAction(title: "Удалить", attributes: .destructive, handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.viewModel?.deleteCategory(titledWith: categoryTitle)
                })
            ])
        })
        
        return contextMenu
    }
}

extension TrackerCategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let categoriesNumber = viewModel?.numberOfCategoriesTotal() ?? 0
        
        if categoriesNumber == 0 {
            if let plugView = tableView.backgroundView as? NoDataPlugView {
                plugView.fadeIn()
            } else {
                tableView.backgroundView = NoDataPlugView(frame: tableView.bounds, plugMode: .noCategories)
            }
        } else {
            if let plugView = tableView.backgroundView as? NoDataPlugView {
                plugView.fadeOut()
            }
        }
        
        rowsInTable = categoriesNumber
        
        return categoriesNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackerCategoryTableCell.reuseIdentifier) as? TrackerCategoryTableCell ?? TrackerCategoryTableCell()
        
        cell.accessoryType = .none
        
        cell.labelText = viewModel?.categoryTitleFromTotalList(for: indexPath.row)
        
        if let categoryTitle = cell.labelText, categoryTitle == TrackerCategoryViewController.lastUsedCategory {
            cell.accessoryType = .checkmark
        }
        
        cell.backgroundColor = UIColor(named: ColorNames.background)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16.0
        
        if indexPath.row == 0 {
            if rowsInTable == 1 {
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
            }else {
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        } else if indexPath.row == rowsInTable - 1 {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.maskedCorners = []
        }
        
        cell.hidesBottomSeparator = indexPath.row == rowsInTable - 1
        
        return cell
    }
}
