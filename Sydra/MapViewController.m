//
//  MapViewController.m
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"

@interface MapViewController ()
@property (nonatomic,strong) NSArray* searchResultArray;
@property (nonatomic,strong) NSDictionary* selectedDictionary;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
   /* CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        //Error checking
        self.searchResultArray = placemarks;
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        MKCoordinateRegion region;
        region.center.latitude = placemark.location.coordinate.latitude;
        region.center.longitude = placemark.location.coordinate.longitude;
        MKCoordinateSpan span;
        double radius = placemark.region.radius / 1000; // convert to km
        
        NSLog(@"[searchBarSearchButtonClicked] Radius is %f", radius);
        span.latitudeDelta = radius / 112.0;
        
        region.span = span;
        [self.view endEditing:YES];
        [self.mapView setRegion:region animated:YES];
        [self.locTable reloadData];
    
    }];*/
    
    //[[AppDelegate getAppDelegate] showActivityIndicator:YES];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //sessionConfiguration.HTTPAdditionalHeaders = @{@"Authorization": authValue};
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&key=AIzaSyBoHXr7mYzxaFD8Vj2r6azSjyjXheuF-5o",searchBar.text];
    
    //Replace Spaces with a '+' character.
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
    //Create NSURL string from a formate URL string.
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
   
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //[[AppDelegate getAppDelegate] showActivityIndicator:NO];
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200){
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"response - %@",response);
                self.searchResultArray = [jsonData objectForKey:@"results"];
                [self.locTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                //Process the data
            }else{
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                NSLog(@"response - %@",jsonData);
            }
        }
        
    }];
    [task resume];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchResultArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MapTable" forIndexPath:indexPath];
    NSDictionary* dict = [self.searchResultArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"formatted_address"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   NSDictionary* dict = [self.searchResultArray objectAtIndex:indexPath.row];
    MKCoordinateRegion region;
    region.center.latitude  = [[[[dict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] floatValue];
    region.center.longitude = [[[[dict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] floatValue];
    self.selectedDictionary = @{@"lat":[[[dict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"],@"lng":[[[dict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"],@"formattedAddress":[dict objectForKey:@"formatted_address"]};
    //Set Zoom level using Span
    MKCoordinateSpan span;
    span.latitudeDelta  = .005;
    span.longitudeDelta = .005;
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
}

-(IBAction)selectLocation:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        self.controller.locationDictionary = self.selectedDictionary;
        [self.controller fillLocationDetails];
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(IBAction)closeLocation:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
