//
//  TrackerCategoryViewController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 03.02.2024.
//

import UIKit

final class TrackerNewCategoryViewController: UIViewController {
    
    private let controllerType: ControllerType
    
    private let buttonDone = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: ColorNames.black)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(UIColor(named: ColorNames.white), for: .normal)
        button.layer.cornerRadius = 16.0
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название категории"
        field.backgroundColor = UIColor(named: ColorNames.background)
        field.layer.cornerRadius = 16
        field.clearButtonMode = .whileEditing
        field.setLeftPadding(16)
        
        return field
    }()
    
    let previousTitle: String
    weak var viewModel: TrackerViewModelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        setupUI()
    }
    
    init(viewModel: TrackerViewModelProtocol? = nil, controllerType: ControllerType = .create, previousTitle: String = "" ) {
        
        self.viewModel = viewModel
        self.controllerType = controllerType
        self.previousTitle = previousTitle
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        
        view.backgroundColor = UIColor(named: ColorNames.white)
        
        titleLabel.text = controllerType == .create ? "Новая категория" : "Редактирование категории"
        if controllerType == .edit {
            textField.text = previousTitle
        }
        
        [buttonDone, titleLabel, textField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            buttonDone.heightAnchor.constraint(equalToConstant: 60),
            buttonDone.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            buttonDone.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonDone.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        buttonDone.addTarget(self, action: #selector(addOrEditCategory), for: .touchUpInside)
        buttonDoneState(isEnabled: false)
    }
    
    @objc
    private func addOrEditCategory(){
        
        guard let titleText = textField.text, !titleText.isEmpty else {
            return
        }
        if controllerType == .create {
            viewModel?.createCategory(titledWith: titleText)
        } else {
            viewModel?.updateCategory(fromOld: previousTitle, toNew: titleText)
        }
        dismiss(animated: true)
    }
    
    func buttonDoneState(isEnabled: Bool){
        
        buttonDone.backgroundColor = UIColor(named: isEnabled ? ColorNames.black : ColorNames.gray)
        buttonDone.isEnabled = isEnabled
    }
}

extension TrackerNewCategoryViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if let text = textField.text, text.isEmpty {
            buttonDoneState(isEnabled: false)
        } else {
            buttonDoneState(isEnabled: true)
        }
    }
}
