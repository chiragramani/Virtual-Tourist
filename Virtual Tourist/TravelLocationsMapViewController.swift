//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Chirag Ramani on 17/06/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController,MKMapViewDelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet var gestureRecognizerOutlet: UILongPressGestureRecognizer!
    var coordinate:CLLocationCoordinate2D?
    var selectedPin:Pins?
    var pins=[Pins]()
    var editingMode:Bool?
    
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var editButtonOutlet: UIBarButtonItem!
   
    
    @IBOutlet weak var pinsDeleteOutlet: UILabel!
    
    @IBAction func gestureRecognizer(sender: UIGestureRecognizer) {
        if gestureRecognizerOutlet.state == .Began
        {
            let locationWhereUserTouchedInView = gestureRecognizerOutlet.locationInView(myMapView)
            let coordinateOfLocationInMap:CLLocationCoordinate2D = myMapView.convertPoint(locationWhereUserTouchedInView, toCoordinateFromView: myMapView)
            
            let annotationForCoordinateInMap = MKPointAnnotation()
            annotationForCoordinateInMap.coordinate = coordinateOfLocationInMap
            myMapView.addAnnotation(annotationForCoordinateInMap)
            addPinToTheDatabase(annotationForCoordinateInMap)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editingMode=false
        pinsDeleteOutlet.hidden=true
        myMapView.delegate=self
        gestureRecognizerOutlet.delegate=self
        gestureRecognizerOutlet.minimumPressDuration=0.75
        gestureRecognizerOutlet.numberOfTouchesRequired=1
        myMapView.addGestureRecognizer(gestureRecognizerOutlet)
        if NSUserDefaults.standardUserDefaults().objectForKey("MapLatitude") != nil
        {
            setMapRegion()
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.latitude, forKey: "MapLatitude")
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.longitude, forKey: "MapLongitude")
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: "MapLatitudeDelta")
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: "MapLongitudeDelta")
    }
    
    func setMapRegion()->Void
    {
        
        let latitude:CLLocationDegrees = NSUserDefaults.standardUserDefaults().doubleForKey("MapLatitude")
        let longitude:CLLocationDegrees = NSUserDefaults.standardUserDefaults().doubleForKey("MapLongitude")
        let coordinate:CLLocationCoordinate2D=CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let latDelta:CLLocationDegrees=NSUserDefaults.standardUserDefaults().doubleForKey("MapLatitudeDelta")
        let longDelta:CLLocationDegrees=NSUserDefaults.standardUserDefaults().doubleForKey("MapLongitudeDelta")
        let span=MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let region:MKCoordinateRegion=MKCoordinateRegion(center: coordinate, span: span)
        myMapView.setRegion(region, animated: true)
        fetchPreviousPinsFromDatabase()
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        self.coordinate=mapView.selectedAnnotations.first?.coordinate
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        
        for pin in pins
        {
            if (pin.latitude == self.coordinate?.latitude) && (pin.longitude == self.coordinate?.longitude)
            {
                self.selectedPin = pin
            }
        }
        
        if !editingMode!
        {
             mapView.deselectAnnotation(view.annotation, animated: true)
            if self.selectedPin?.photos?.count==0
            {
                FlickrClient.sharedInstance.fetchPhotosForLocationFromFlickr(true, pin: self.selectedPin!)
                {
                    (success,error) in
                    performUIUpdatesOnMain{
                        if success
                        {
                            print("entered")
                            self.performSegueWithIdentifier("photoAlbumSegue", sender: self)
                        }
                        else
                        {
                            let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                        
                    }
                }
                
            }
            else
            {
                self.performSegueWithIdentifier("photoAlbumSegue", sender: self)
            }

        }
        else
        {
            let index=pins.indexOf(self.selectedPin!)
            pins.removeAtIndex(index!)
             myMapView.removeAnnotation((mapView.selectedAnnotations.first)!)
        stack.context.deleteObject(self.selectedPin!)
       
            do{
            try stack.context.save()
            }catch
            {
            print("Error in updating parent ")
            }
        
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let photoAlbumViewController=segue.destinationViewController as! PhotoAlbumViewController
        photoAlbumViewController.selectedPin=self.selectedPin
    }
    
    func addPinToTheDatabase(pin:MKPointAnnotation)->Void
    {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        let pinToAdd = Pins(annotation: pin, context: stack.context)
        pins.append(pinToAdd)
        do{try  stack.saveContext()
        }catch
        {
            print("Can't add pin to the database")
        } }
    
    func fetchPreviousPinsFromDatabase()->Void
    {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        let moc = stack.context
        let pinsFetch = NSFetchRequest(entityName: "Pins")
        
        do {
            let fetchedPins = try moc.executeFetchRequest(pinsFetch) as! [Pins]
            for pin in fetchedPins
            {
                
                let annotationForCoordinateInMap = MKPointAnnotation()
                annotationForCoordinateInMap.coordinate = CLLocationCoordinate2D(latitude: pin.latitude as! Double, longitude: pin.longitude as! Double)
                self.pins.append(pin)
                
                myMapView.addAnnotation(annotationForCoordinateInMap)
            }
        } catch {
            fatalError("Failed to fetch pins: \(error)")
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin") as MKPinAnnotationView
        annotationView.canShowCallout = false
        return annotationView
    }
    
    @IBAction func editButtonPressed(sender: UIBarButtonItem) {
    if sender.title=="Edit"
    {
        pinsDeleteOutlet.hidden=false
        editButtonOutlet.title="Done"
        editingMode=true
        }
    else
    {
        pinsDeleteOutlet.hidden=true
        editButtonOutlet.title="Edit"
        editingMode=false
        }
    }
    
}
