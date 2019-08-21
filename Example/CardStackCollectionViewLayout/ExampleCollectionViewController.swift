//
//  ExampleCollectionViewController.swift
//  CardStackCollectionViewLayout
//
//  Created by Chris Stamper on 8/20/19.
//  Copyright © 2019 Chris Stamper. All rights reserved.
//
//  ExampleCollectionViewController is a very simple implementation of a
//  CardStackCollectionViewLayout. It's really as simple as setting the layout anf delegate,
//  and remembering to call -performBatchUpdates before changing the state (expanded or collapsed).

import UIKit
import CardStackCollectionViewLayout

class ExampleCollectionViewController: UICollectionViewController, CardStackLayoutDelegate {
    
    var currentState: CardStackLayoutState = .collapsed
    var count = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()

        (self.collectionView?.collectionViewLayout as? CardStackCollectionViewLayout)?.delegate = self
    }
    
    @IBAction func toggle() {
//        collectionView?.performBatchUpdates({
            currentState = currentState == .collapsed ? .expanded : .collapsed
            collectionView?.reloadData()
//        }) { (success) in
//            print("changed state")
//        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "example", for: indexPath) as! ExampleCollectionViewCell
        cell.label.text = "Row \(indexPath.row)"
        return cell
    }
}

class ExampleCollectionViewCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
}
