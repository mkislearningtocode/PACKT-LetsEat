//
//  RestaurantListVC.swift
//  PACKT-LetsEat
//
//  Created by Warba on 13/06/2023.
//

import UIKit
import OSLog

class RestaurantListVC: UIViewController {

    let logger = Logger()

    private let manager = RestaurantDataManager()

    var selectedRestaurant: RestaurantItem?
    var selectedCity: LocationItem?
    var selectedCuisine: String?

    @IBOutlet var collectionView: UICollectionView!
    
    //MARK: - Life viewcycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                case Segue.showDetail.rawValue:
                    showRestaurantDetail(segue: segue)
                default:
                    logger.error("Segue not added")
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        createData()
        setupTitle()
    } // viewDidAppear

}

//MARK: - Extension

private extension RestaurantListVC {

    func showRestaurantDetail(segue: UIStoryboardSegue) {
        if let viewController = segue.destination as? RestaurantDetailVC,
           let indexPath = collectionView.indexPathsForSelectedItems?.first {
            selectedRestaurant = manager.restaurantItem(at: indexPath.row)
            viewController.selectedRestaurant = selectedRestaurant
        }
    }

    func createData() {
        guard let city = selectedCity?.city,
              let cuisine = selectedCuisine
        else { return }
        manager.fetch(location: city, selectedCuisine: cuisine) { restaurantItems in
            if !restaurantItems.isEmpty {
                collectionView.backgroundView = nil
            } else {
                let view = NoDataView(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: collectionView.frame.width,
                                                    height: collectionView.frame.height))
                view.set(title: "Restaurants", desc: "No restaurants found")
                collectionView.backgroundView = view
            }
            collectionView.reloadData()
        }
    } // createData()

    func setupTitle() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        title = selectedCity?.cityAndState.uppercased()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

extension RestaurantListVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manager.numberOfRestaurantItems()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "restuarantCell", for: indexPath) as! RestaurantCell
        let restaurantItem = manager.restaurantItem(at: indexPath.row)
        logger.debug("restaurantItem -> \(restaurantItem)")
        cell.titleLabel.text = restaurantItem.name
        if let cuisine = restaurantItem.subtitle {
            cell.cuisineLabel.text = cuisine
        }


        if let imageURL = restaurantItem.imageURL {
            Task {

                guard let url = URL(string: imageURL)
                else { return }

                let (imageData, response) = try await URLSession.shared.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else { return }

                guard let cellImage = UIImage(data: imageData)
                else { return }

                cell.restaurantImageView.image = cellImage
            }
        }
        return cell
    }


}
