//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate, UIScrollViewDelegate{

    @IBOutlet weak var tableView: UITableView!
   
    var businesses: [Business]!
    var filteredBusinesses = [Business]()
    var searchBar: UISearchBar?
    var isMoreDataLoading = false
    var offset: Int = 0
    var limit: Int = 20
    var filteredCategories = [String]()
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar = UISearchBar()
        searchBar?.sizeToFit()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar?.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        searchBar?.placeholder = "Enter something you like"
//        let leftNavBarButton = UIBarButtonItem(customView:(searchBar?)!)
        self.navigationItem.titleView = searchBar
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        Business.searchWithTerm("Restaurant", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.filteredBusinesses = businesses
            self.offset += businesses.count
            self.tableView.reloadData()
      })
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Handle scroll behavior here
        if (!isMoreDataLoading) {
            
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                loadMoreData()
                
            }
            
        }
        
    }
    
    func loadMoreData(){
        Business.searchWithTerm("Restaurants", offset: self.offset, limit: self.limit, sort: nil, categories: filteredCategories, deals: nil){ (businesses: [Business]!, error: NSError!) -> Void in
            self.filteredBusinesses += businesses
            self.offset += businesses.count
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
            self.tableView.reloadData()
        }
    
    }
    

    

    
    @IBAction func onTap(sender: AnyObject) {
        self.searchBar?.endEditing(true)
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredBusinesses = businesses
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredBusinesses = businesses.filter({(dataItem: Business) -> Bool in
                // If dataItem matches the searchText, return true to include it
                var title = dataItem.name! as String
                if title.rangeOfString(searchText) != nil {
                    return true
                } else {
                    return false
                }
            })
            
        }
        self.tableView.reloadData()
    }
    
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredBusinesses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        cell.business = filteredBusinesses[indexPath.row]
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FilterControllerSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            filtersViewController.delegate = self
        }else if segue.identifier == "MapControllerSegue"{
            let navigationController = segue.destinationViewController as! UINavigationController
            let mapViewController = navigationController.topViewController as! MapViewController
            mapViewController.businesses = self.filteredBusinesses
            
        }
        
        
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        if let filteredCategories = filters["categories"] as? [String]{
            self.filteredCategories = filteredCategories
            Business.searchWithTerm("Restaurants",  sort: nil, categories: filteredCategories, deals: nil){ (businesses: [Business]!, error: NSError!) -> Void in
                if businesses != nil{
                    self.filteredBusinesses = businesses
                }
                else{
                    self.filteredBusinesses = []
                }
            self.tableView.reloadData()
            }
            }
        }
    
        
    }
    


