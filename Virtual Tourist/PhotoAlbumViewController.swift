//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Chirag Ramani on 18/06/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var bottomBarButton: UIBarButtonItem!
    
    var selectedPhotos=[Photos]()
    
    private var blockOperations: [NSBlockOperation] = []
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var selectedPin:Pins?
    
    var fetchedResultsController : NSFetchedResultsController?{
        didSet{
           fetchedResultsController?.delegate = self
            executeSearch()
            myCollectionView.reloadData()
        }
    }
    
    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapRegion()
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.allowsMultipleSelection=true
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        adjustFlowLayout(self.view.frame.size)
        let fr = NSFetchRequest(entityName: "Photos")
        fr.sortDescriptors = [NSSortDescriptor(key: "filePath", ascending: false)]
        let predicate=NSPredicate(format: "location = %@", argumentArray: [selectedPin!])
        fr.predicate=predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate=self
        
        
    }
    
    func setMapRegion()->Void
    {
        let span=MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let centre=CLLocationCoordinate2D(latitude: selectedPin!.latitude as! Double, longitude:selectedPin!.longitude as! Double)
        let region:MKCoordinateRegion=MKCoordinateRegion(center: centre, span: span)
        myMapView.setRegion(region, animated: true)
        let annotationForCoordinateInMap = MKPointAnnotation()
        annotationForCoordinateInMap.coordinate = centre
        myMapView.addAnnotation(annotationForCoordinateInMap)
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController{
            print("number of items \(fc.sections![section].numberOfObjects)")
            return fc.sections![section].numberOfObjects
        }else{
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        print("Entered cellforitematindex")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellIdentifier", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        cell.photoImage.image=UIImage(named: "placeHolder")
        cell.activityIndicator.hidden=false
        cell.activityIndicator.startAnimating()
        
        let photo = fetchedResultsController!.objectAtIndexPath(indexPath) as! Photos
        
        FlickrClient.sharedInstance.downloadImage(photo)
        { (success,error) in
            if success
            {
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.hidden=true
                cell.photoImage.image=UIImage(data: photo.photo!)
            }
            else
            {
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.hidden=true
            }
        }
        return cell
    }
    
    func adjustFlowLayout(size: CGSize) {
        let space: CGFloat = 1.5
        let dimension:CGFloat = size.width >= size.height ? (size.width - (5 * space)) / 6.0 :  (size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        adjustFlowLayout(size)
    }
    
    deinit {
        blockOperations.forEach { $0.cancel() }
        blockOperations.removeAll(keepCapacity: false)
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        blockOperations.removeAll(keepCapacity: false)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            print("Entered into insert")
            guard let newIndexPath = newIndexPath else { return }
            let op = NSBlockOperation { [weak self] in self?.myCollectionView.insertItemsAtIndexPaths([newIndexPath]) }
            blockOperations.append(op)
            
        case .Update:
            print("It is an update")
            guard let newIndexPath = newIndexPath else { return }
            let op = NSBlockOperation { [weak self] in self?.myCollectionView.reloadItemsAtIndexPaths([newIndexPath]) }
            blockOperations.append(op)
            
        case .Delete:
            guard let indexPath = indexPath else { return }
            let op = NSBlockOperation { [weak self] in self?.myCollectionView.deleteItemsAtIndexPaths([indexPath]) }
            blockOperations.append(op)
            
        default:
            return
            
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        myCollectionView.performBatchUpdates({
            self.blockOperations.forEach { $0.start() }
            }, completion: { finished in
                self.blockOperations.removeAll(keepCapacity: false)
        })
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        do{
            try stack.saveContext()
        }catch
        {
            print("Error saving changes")
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        bottomBarButton.title="Remove Selected Items"
        let cell = self.myCollectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        cell.alpha=0.2
        selectedPhotos.append((fetchedResultsController?.objectAtIndexPath(indexPath))! as! Photos)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.myCollectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        cell.alpha=1
        if selectedPhotos .contains((fetchedResultsController?.objectAtIndexPath(indexPath))! as! Photos)
        {
            let index=selectedPhotos.indexOf((fetchedResultsController?.objectAtIndexPath(indexPath))! as! Photos)
            selectedPhotos.removeAtIndex(index!)
        }
        if selectedPhotos.count==0
        {
            bottomBarButton.title="New Collections"
        }
    }
    
    
    @IBAction func bottomBarButtonPressed(sender: UIBarButtonItem) {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        if sender.title=="Remove Selected Items"
        {
        for photo in selectedPhotos
        {
            stack.context.deleteObject(photo)
            }
        }
        else
        {
        
           for photo in  (fetchedResultsController?.fetchedObjects as! [Photos])
           {
           
            stack.context.deleteObject(photo)
            
            }
            FlickrClient.sharedInstance.fetchPhotosForLocationFromFlickr(false, pin: self.selectedPin!)
            {
            (success,error) in
                
            if !success
            {
                performUIUpdatesOnMain(){
             let alertController=UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
             alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
                }
                }
            }
        
        do{
        try stack.saveContext()
        }catch
        {
        print("Cannot remove photos")
        }
        sender.title="New Collections"
    }

}
}
