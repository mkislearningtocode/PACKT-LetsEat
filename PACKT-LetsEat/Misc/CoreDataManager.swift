//
//  CoreDataManager.swift
//  PACKT-LetsEat
//
//  Created by Warba on 03/07/2023.
//

import Foundation
import CoreData
import OSLog

struct CoreDataManager {

    let logger = Logger(subsystem: "samplemkdev.PACKT-LetsEat", category: "CoreDataManager")
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "LetsEatModel")
        container.loadPersistentStores { storeDesc, error in
            error.map { print($0) }
        } // loadPersistentStores
    } // init()

    //MARK: - CRUD
    func addReview(_ reviewItem: ReviewItem) {
        let review = Review(context: container.viewContext)
        review.date = Date()

        if let reviewItemRating = reviewItem.rating {
            review.rating = reviewItemRating
        }
        review.title = reviewItem.title
        review.name = reviewItem.name
        review.customerReview = reviewItem.customerReview

        if let reviewItemRestID = reviewItem.restaurantID {
            review.restaurantID = reviewItemRestID
        }

        review.uuid = reviewItem.uuid
        save()
    }

    func addPhoto(_ restPhotoItem: RestaurantPhotoItem) {
        let restPhoto = RestaurantPhoto(context: container.viewContext)
        restPhoto.date = Date()
        restPhoto.photo = restPhotoItem.photoData
        if let restPhotoID = restPhotoItem.restaurantID {
            restPhoto.restaurantID = restPhotoID
        }
        restPhoto.uuid = restPhotoItem.uuid
        save()
    }

    func fetchRestaurantRating(by identifier: Int) -> Double {
        let reviewItems = fetchReviews(by: identifier)
        let sum = reviewItems.reduce(0, {$0 + ($1.rating ?? 0)})
        return sum / Double(reviewItems.count)
    }

    func fetchReviews(by identifier: Int) -> [ReviewItem] {
        let moc = container.viewContext
        let request = Review.fetchRequest()
        let predicate = NSPredicate(format: "restaurantID = %i", identifier)
        var reviewItems: [ReviewItem] = []

        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.predicate = predicate

        do {
            for review in try moc.fetch(request) {
                reviewItems.append(ReviewItem(review: review))
            }
            return reviewItems
        } catch {fatalError("Failed to fetch reviews⬇\n\(error.localizedDescription)")}
    }

    func fetchRestPhotos(by identifier: Int) -> [RestaurantPhotoItem] {
        let moc = container.viewContext
        let request = RestaurantPhoto.fetchRequest()
        let predicate = NSPredicate(format: "restaurantID = %i", identifier)
        var restPhotoItems: [RestaurantPhotoItem] = []

        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.predicate = predicate

        do {
            for restPhoto in try moc.fetch(request) {
                restPhotoItems.append(RestaurantPhotoItem(restaurantPhoto: restPhoto))
            }
            return restPhotoItems
        } catch {fatalError("Failed to fetch Photo⬇\n\(error.localizedDescription)")}
    }

    //MARK: Save
    private func save() {
        do {
            if container.viewContext.hasChanges {
                try container.viewContext.save()
            }

        } catch let error {
            logger.error("""
        Error saving viewContext ⬇\n\(error.localizedDescription)\n
        """)
        }
    }
}

//MARK: - Extension
extension CoreDataManager {
    static var shared = CoreDataManager()
}
