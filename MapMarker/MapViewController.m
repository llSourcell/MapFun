//
//  ViewController.m
//  MapMarker
//
//  Created by Siraj Raval on 5/15/15.
//  Copyright (c) 2015 Siraj Raval. All rights reserved.
//

#import "AppConstants.h"
#import "MapViewController.h"
#import "DDPointList.h"
#import "DDPoint+MKAnnotation.h"
#import "DDCalloutView.h"

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet UIView *customNavBar;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) DDPointList *pointList;

@property (assign, nonatomic) BOOL isNeedToTrackLocation;

@end


@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // custom NavigationBar
    self.customNavBar.layer.borderWidth = 0.5;
    self.customNavBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    // CoreLocation manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.pointList = [DDPointList sharedPointList];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadAnnotations];
}


#pragma mark - Button Actions

- (IBAction)btnClearPressed:(id)sender {
    if (CLLocationManager.authorizationStatus != kCLAuthorizationStatusAuthorizedWhenInUse) {
        return;
    }
    for (id<MKAnnotation>annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:MKUserLocation.class]) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, DEF_MAP_SCALE, DEF_MAP_SCALE);
            [self.mapView setRegion:region animated:YES];
        }
    }
}

- (IBAction)btnRefreshPressed:(id)sender {
    if (self.pointList.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert"
                                                                       message:@"placeholder"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self fitAnnotations];
    }
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
        self.isNeedToTrackLocation = YES;
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = locations.lastObject;
    if (self.isNeedToTrackLocation) {
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, DEF_MAP_SCALE, DEF_MAP_SCALE) animated:YES];
        self.isNeedToTrackLocation = NO;
    }
}



#pragma mark - MapView routines

- (void)reloadAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (id<MKAnnotation> annotation in self.pointList.array) {
        [self.mapView addAnnotation:annotation];
    }
}

- (void)fitAnnotations {
    MKMapRect zoomRect = MKMapRectNull;
    for (id<MKAnnotation>annotation in self.mapView.annotations) {
        if (![annotation isKindOfClass:MKUserLocation.class]) {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    double insetW = -zoomRect.size.width * 0.1;
    double insetH = -zoomRect.size.height * 0.1;
    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, insetW, insetH) animated:YES];
}

- (void)selectAnnotation:(id<MKAnnotation>)annotation {
    [self.mapView selectAnnotation:annotation animated:YES];
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:MKUserLocation.class]) {
        return nil;
    }
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:ANNOTATION_ID];
    annotationView.image = [UIImage imageNamed:@"map_marker"];
    annotationView.centerOffset = CGPointMake(0, -1 * annotationView.image.size.height / 2);
    annotationView.canShowCallout = NO;
    CGRect frame = CGRectMake(annotationView.frame.size.width / 2 - CALLUOT_VIEW_WIDTH / 2,
                              - CALLUOT_VIEW_HEIGHT,
                              CALLUOT_VIEW_WIDTH,
                              CALLUOT_VIEW_HEIGHT);
    DDCalloutView *calloutView = [[DDCalloutView alloc] initWithFrame:frame];
    calloutView.titleLabel.text = annotation.title;
    calloutView.subtitleLabel.text = annotation.subtitle;
    calloutView.alpha = 0;
    calloutView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [annotationView addSubview:calloutView];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    id<MKAnnotation>annotation = view.annotation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, DEF_MAP_SCALE, DEF_MAP_SCALE);
    [self.mapView setRegion:region animated:YES];
    UIView *calloutView = view.subviews.firstObject;
    [UIView animateWithDuration:0.4 animations:^{
        calloutView.alpha = .85;
        calloutView.transform = CGAffineTransformIdentity;
    }];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    UIView *calloutView = view.subviews.firstObject;
    [UIView animateWithDuration:0.4 animations:^{
        calloutView.alpha = 0;
        calloutView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    }];
}





#pragma mark - Gesture Recognizer Handler

- (IBAction)longPressHandle:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [sender locationInView:self.mapView];
        CLLocationCoordinate2D touchCoordinate = [self.mapView convertPoint:touchPoint
                                                       toCoordinateFromView:self.mapView];
        CLLocation *touchLocation = [[CLLocation alloc] initWithLatitude:touchCoordinate.latitude
                                                               longitude:touchCoordinate.longitude];
        
        MKPointAnnotation *tmpAnnotation = [[MKPointAnnotation alloc] init];
        tmpAnnotation.coordinate = touchCoordinate;
        [self.mapView addAnnotation:tmpAnnotation];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        [geocoder reverseGeocodeLocation:touchLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"error: %@", error);
                [self.mapView removeAnnotation:tmpAnnotation];
                return;
            }
            NSDictionary *addressDict = ((CLPlacemark *)placemarks.firstObject).addressDictionary;
            NSString *street = addressDict[STREET_KEY];
            street = (street) ?: addressDict[NAME_KEY];
            NSString *city = addressDict[CITY_KEY];
            city = (city) ?: addressDict[COUNTRY_KEY];
            NSString *zipCode = addressDict[ZIP_KEY];
            zipCode = (zipCode) ? [NSString stringWithFormat:@"%@, ", zipCode] : @"";
            NSString *address = [NSString stringWithFormat:@"%@%@, %@", zipCode, city, street];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert"
                                                                           message:address
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"placeholder";
                textField.returnKeyType = UIReturnKeyDone;
                textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            }];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self.mapView removeAnnotation:tmpAnnotation];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Mark it" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                DDPoint *annotation = [DDPoint createObject];
                UITextField *textField = alert.textFields.firstObject;
                annotation.name = ([textField.text isEqualToString:@""]) ? @"name field" : textField.text;
                annotation.address = address;
                annotation.coordinate = touchCoordinate;
                [self.pointList addPoint:annotation];
                [self.mapView removeAnnotation:tmpAnnotation];
                [self.mapView addAnnotation:annotation];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }];

    }
}




@end