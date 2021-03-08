//
//  ChooseModelViewController.swift
//  PlaceOnTheWall
//
//  Created by Olena Stepaniuk on 08.03.2021.
//

import UIKit

class ChooseModelViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Choose model"
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "SinglePictureCell", bundle: nil), forCellReuseIdentifier: "SinglePictureCell")
    }
}

extension ChooseModelViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SinglePictureCell", for: indexPath) as! SinglePictureCell
        if let safeImage = UIImage(named: "painting\(indexPath.row)") {
            cell.picture.image = safeImage
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "ARViewController") as? ARViewController else {
            return
        }
        vc.paintingNumber = indexPath.row
        navigationController?.pushViewController(vc, animated: true)
    }
}
