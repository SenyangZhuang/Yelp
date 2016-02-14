//
//  MapViewController.swift
//  Yelp
//
//  Created by Senyang Zhuang on 2/13/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var businesses = [Business]()
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //print(businesses)
        let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
        goToLocation(centerLocation)
        addAnnotationForEachBusiness()
    }
    
    func addAnnotationForEachBusiness(){
        for business in businesses{
            if business.latitude != nil && business.longitude != nil{
                let location = CLLocationCoordinate2D(latitude: business.latitude!, longitude: business.longitude!)
                addAnnotationAtCoordinate(location, name: business.name!)
            }
        
        }
    }
    
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.03, 0.03)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "customAnnotationView"
        // custom pin annotation
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        if (annotationView == nil) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            let buttonType = UIButtonType.InfoDark
            annotationView!.rightCalloutAccessoryView = UIButton(type: buttonType)
        }
        else {
            annotationView!.annotation = annotation
        }
        if #available(iOS 9.0, *) {
            annotationView!.pinTintColor = UIColor.redColor()
        } else {
            // Fallback on earlier versions
        }
        
        return annotationView
        
        
        
    }
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, name: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = name
        mapView.addAnnotation(annotation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
