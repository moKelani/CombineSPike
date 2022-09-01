//
//  ViewController.swift
//  CombineIntro
//
//  Created by Mohamed Kelany on 01/09/2022.
//

import UIKit
import Combine

class MyCustomTableCell: UITableViewCell {
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemPink
        button.setTitle("Button", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    let action = PassthroughSubject<String, Never>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(didTappedButton), for: .touchUpInside )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(origin: CGPoint(x: 10, y: 3), size: CGSize(width: contentView.frame.width-20, height: contentView.frame.height-6))
    }
    
    @objc func didTappedButton() {
        action.send("Cool button was Tapped!")
    }
}

class ViewController: UIViewController {

    private let tableView: UITableView = {
       let table = UITableView()
        table.register(MyCustomTableCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    private var models = [String]()
    var observers: [AnyCancellable] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
       // tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        APICaller.shared.fetchCompanies()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Finished")
            case .failure(let error):
                print("Ended with \(error)")
            }
        }, receiveValue: { [weak self] value in
            self?.models = value
            self?.tableView.reloadData()
        }).store(in: &observers)
    }


}
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MyCustomTableCell else {
            fatalError("cell can't dequeue")
        }
        cell.action.sink { string in
            print(string)
        }.store(in: &observers)
        return cell
    }
    
    
}

