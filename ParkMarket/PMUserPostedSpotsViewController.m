//
//  PMUserPostedSpotsViewController.m
//  ParkMarket
//
//  Created by Ariel Scott-Dicker on 9/23/16.
//  Copyright © 2016 Ariel Scott-Dicker. All rights reserved.
//

#import "PMUserPostedSpotsViewController.h"

@interface PMUserPostedSpotsViewController ()

@property (strong, nonatomic) NSMutableDictionary *parkingSpots;
@property (strong, nonatomic) NSMutableArray *parkingSpotMarkers;

@property (strong, nonatomic) GMSMarker *selectedMarker;
@property (strong, nonatomic) GMSMapView *mapView;

@property (strong, nonatomic) UINavigationBar *navigationBar;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@property CGFloat viewHeight;
@property CGFloat viewWidth;

@end

@implementation PMUserPostedSpotsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureLocationManager];
    
    self.viewHeight = self.view.frame.size.height;
    self.viewWidth = self.view.frame.size.width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Did receive memory warning");
}

#pragma mark - UI Layout

-(void)configureMapView {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude
                                                            longitude:self.currentLocation.coordinate.longitude
                                                                 zoom:15];
    
    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.viewWidth, self.viewHeight)
                                     camera:camera];
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
}

- (void)configureNavigationBar {
    self.navigationBar = [UINavigationBar new];
    [self.view addSubview:self.navigationBar];
    
    self.navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.navigationBar.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.navigationBar.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.navigationBar.heightAnchor constraintEqualToAnchor:self.view.heightAnchor
                                                  multiplier:0.1].active = YES;
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"My Posted Spots"];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneButtonTapped)];
    
    navigationItem.rightBarButtonItem = doneButton;
    self.navigationBar.items = @[navigationItem];
}

#pragma mark - Core Location

-(void)configureLocationManager {
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *mostRecentLocation = [locations lastObject];
    NSDate *locationCaptureTime = mostRecentLocation.timestamp;
    NSTimeInterval timeSinceLocationCapture = [locationCaptureTime timeIntervalSinceNow];
    
    if (timeSinceLocationCapture <= 2) {
        self.currentLocation = mostRecentLocation;
        [self.locationManager stopUpdatingLocation];
        
        if (!self.mapView) {
            [self configureMapView];
            [self configureNavigationBar];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([CLLocationManager authorizationStatus] == 4) {
        [self.locationManager startUpdatingLocation];
    }
}
                                   
#pragma mark - Helper Methods
                                   
- (void)doneButtonTapped {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end