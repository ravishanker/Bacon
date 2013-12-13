//
//  PWCBeaconService.m
//  Bacon
//
//  Created by Ravi on 11/12/2013.
//  Copyright (c) 2013 PWC. All rights reserved.
//

#import "PWCBeaconService.h"

static NSString * const kUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
static NSString * const kRegionIdentifier = @"au.com.pwc.Bacon";

//Blue      beacon Major:394    Minor:58605
//Green     beacon Major:40836  Minor:18108
//Purple    beacon Major:29836  Minor:57466

@interface PWCBeaconService ()

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CLRegion *locationRegion;

@property (nonatomic, strong) CLBeacon *nearestBeacon;
@property (nonatomic, strong) CLBeacon *currentBeacon;

@property (nonatomic, strong) NSDate * regionEntryTime;
@property (nonatomic, strong) NSDate * regionExitTime;
@property NSTimeInterval timeInterval;


@property (nonatomic, strong) PWCUser *user;
@property (nonatomic, strong) PWCGoogleDriveService *gDriveService;

@end

@implementation PWCBeaconService

- (id)init
{
    self = [super init];
    
    if (self) {
                
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        //    _locationManager.distanceFilter = 2.0; // two meters
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        
        NSUUID *estimoteUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
        
        // Blue Estimote
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:estimoteUUID
                                                           identifier:kRegionIdentifier];
        
        // launch app when display is turned on and inside region
        _beaconRegion.notifyEntryStateOnDisplay = YES;
        
        if ([CLLocationManager isMonitoringAvailableForClass:[CLRegion class]]) {
                        
            //To prevent redundant notifications from being delivered to the user
            //            _beaconRegion.notifyOnEntry = NO;
            //            _beaconRegion.notifyOnExit = YES;
            
            // launch app when display is turned on and inside region
            [_locationManager startMonitoringForRegion:_beaconRegion];
            
            // get status update right away for UI
            [_locationManager requestStateForRegion:_beaconRegion];
            
            // Start ranging for beacons
            [_locationManager startRangingBeaconsInRegion:_beaconRegion];
            
        } else {
            NSLog(@"This device does not support monitoring beacon regions");
        }
        
        NSLog(@"Monitored Regions %@", _locationManager.monitoredRegions);
    }
    
    return self;
}



#pragma mark - CLLocationManagerDelegate methods

//- (void)locationManager:(CLLocationManager *)manager
//	  didDetermineState:(CLRegionState)state
//              forRegion:(CLBeaconRegion *)region
//{
//    NSLog(@"Region %@ identifier", region.identifier );
//
//    if (CLRegionStateInside == state) {
////        [self setProductOffer:region.minor];
////        NSLog(@"%@ User in region", _user.fullName);
//
//    }
//
//}

#define FIVE_SECONDS 5.0
#define TEN_SECONDS 10.0

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLRegion *)region
{
    
    if (beacons.count > 0) {
        NSLog(@"Found beacons! %@", beacons);
        
        _nearestBeacon = [beacons firstObject];
        
        NSLog(@"%@, %@ • %ld %.2fm • %li",
              _nearestBeacon.major.stringValue,
              _nearestBeacon.minor.stringValue,
              (long)_nearestBeacon.proximity,
              _nearestBeacon.accuracy,
              (long)_nearestBeacon.rssi);
        
        
        // Moving between beacons
        if (CLProximityImmediate == _nearestBeacon.proximity ||
            CLProximityNear == _nearestBeacon.proximity) {
        
            // update UI with offer
            [[NSNotificationCenter defaultCenter] postNotificationName:@"beacon" object:_nearestBeacon];
            
            if ([_currentBeacon.minor isEqualToNumber:_nearestBeacon.minor]) {
                // still at the same beacon
                _timeInterval = [[NSDate date] timeIntervalSinceDate:_regionEntryTime];
                
                if (_timeInterval > TEN_SECONDS) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"offer" object:_nearestBeacon];

                }

            } else {
                // when moved to another beacon
                if (_timeInterval > FIVE_SECONDS) {
                    // if more than 5 seconds at the beacon post data to spreadsheet
                    _regionExitTime = [NSDate date];
                    
                    [_gDriveService postToSpreadsheet:_nearestBeacon
                                        withEntryTime:_regionEntryTime
                                       regionExitTime:_regionExitTime];
                }
                _regionEntryTime = [NSDate date];
                _currentBeacon = _nearestBeacon;
                
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"beacon" object:nil];
            }
            
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"beacon" object:nil];
            
            // when moved to no immediate or near beacon region
            if (_timeInterval > FIVE_SECONDS) {
                // if more than 5 seconds at the beacon post data to spreadsheet
                _regionExitTime = [NSDate date];
                
                [_gDriveService postToSpreadsheet:_nearestBeacon
                                    withEntryTime:_regionEntryTime
                                   regionExitTime:_regionExitTime];
            }

        }
        
    } else {
        NSLog(@"No beacons found!");
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLBeaconRegion *)region
{
    NSLog(@"Inside Region %@", region.identifier);
    
    _regionEntryTime = [NSDate date];
    
    PWCUser *user = [[PWCUser alloc] initWithFBGraphUser];
    NSLog(@"User in %@", user.description);
    
    if (!_gDriveService) {
        _gDriveService = [[PWCGoogleDriveService alloc] init];
    }

    // A user can transition in or out of a region while the application is not running.
    // When this happens CoreLocation will launch the application momentarily, call this delegate method
    // and we will let the user know via a local notification.
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertBody = [NSString stringWithFormat:@"Hi Welcome to Holden.  We've great offers for you"];
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    [_locationManager startRangingBeaconsInRegion:region];

    
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLBeaconRegion *)region
{
    NSLog(@"Outside Region %@", region.identifier);
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"beacon" object:nil];
    
    _regionExitTime = [NSDate date];
    
    notification.alertBody = [NSString stringWithFormat:@"Thank you for visiting Holden"];
    
    NSLog(@"%@ User in exit region", [PWCUser getUser].description);
    
//    if (!_gDriveService) {
//        _gDriveService = [[PWCGoogleDriveService alloc] init];
//    }
//    
//    [_gDriveService postToSpreadsheet:_nearestBeacon
//                        withEntryTime:_regionEntryTime
//                       regionExitTime:_regionExitTime];
    
    [_locationManager stopRangingBeaconsInRegion:region];
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
}


@end
