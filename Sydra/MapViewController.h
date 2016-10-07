//
//  MapViewController.h
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NewTaskViewController.h"

@interface MapViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (nonatomic,weak) IBOutlet MKMapView* mapView;
@property (nonatomic,weak) IBOutlet UITableView* locTable;
@property (nonatomic,strong) NewTaskViewController* controller;
@end
