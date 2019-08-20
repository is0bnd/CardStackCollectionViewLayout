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

class ExampleCollectionViewController: UICollectionViewController, CardStackLayoutDelegate {
    
    var currentState: CardStackLayoutState = .normal
    var count = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = CardStackCollectionViewLayout()
        layout.delegate = self
        self.collectionView?.collectionViewLayout = layout
    }
    
    @IBAction func toggle() {
        collectionView?.performBatchUpdates({
            currentState = currentState == .normal ? .expanded : .normal
        }) { (success) in
            print("changed state")
        }
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
