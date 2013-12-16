//
//  PWCGoogleDriveService.m
//  Bacon
//
//  Created by Ravi on 11/12/2013.
//  Copyright (c) 2013 PWC. All rights reserved.
//

#import "PWCGoogleDriveService.h"
#import "PWCUser.h"
#import <Mixpanel/Mixpanel.h>

static NSString * const kSpreadsheetURL =
@"https://docs.google.com/forms/d/1ctrAHWmIz-j_47LjRdWPnzHE8ELHjE_MW1X984p3csw/formResponse";

@interface PWCGoogleDriveService()


@end

@implementation PWCGoogleDriveService

- (id)init
{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

#pragma mark - GDataAPI
    
    // spreadsheet cells
# define EST_UUID       @"entry.1641994124"
# define MAJOR          @"entry.857825636"
# define MINOR          @"entry.1767879955"
# define RSSI           @"entry.1246457524"
# define ENTRY_TIME     @"entry.2007394417"
# define EXIT_TIME      @"entry.33654778"
# define DWELL_TIME     @"entry.437064902"
# define FB_ID          @"entry.678980662"
# define FB_FULL_NAME   @"entry.1448375634"
# define FB_GENDER      @"entry.1424146187"
# define FB_EMAIL       @"entry.2006994834"
    
    
- (void)postToSpreadsheet:(CLBeacon *)nearestBeacon
            withEntryTime:(NSDate *)entryTime
           regionExitTime:(NSDate *)exitTime

{
    NSURL *url = [[NSURL alloc] initWithString:kSpreadsheetURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    PWCUser *user = [PWCUser getUser];
    
    // Track stats with Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    // register user properties once
    [mixpanel registerSuperProperties:@{@"fb_id": user.Id,
                                            @"fb_ame": user.fullName,
                                            @"gender": user.gender,
                                            @"email": user.email }];
    
//    [mixpanel createAlias:user.email forDistinctID:mixpanel.distinctId];
    [mixpanel identify:mixpanel.distinctId];
    [mixpanel.people set:@{@"fb_id": user.Id,
                           @"fb_ame": user.fullName,
                           @"gender": user.gender,
                           @"email": user.email}];
    
    // post beacon info each time
    [mixpanel track:@"Beacon" properties:@{@"est_uuid": nearestBeacon.proximityUUID.UUIDString,
                                           @"major": nearestBeacon.major.stringValue,
                                           @"minor": [self beaconColor:nearestBeacon],
                                           @"entry_time": [self dateStringWithDSTOffset:entryTime],
                                           @"exit_time": [self dateStringWithDSTOffset:exitTime],
                                           @"dwell_time": [NSString stringWithFormat:@"%.2f", [[NSDate date] timeIntervalSinceDate:entryTime]] }];

//    NSLog(@"%@ User in gDrive region", user.description);
    
    NSString *params = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
                        EST_UUID, nearestBeacon.proximityUUID.UUIDString,
                        MAJOR, nearestBeacon.major.stringValue,
                        MINOR, [self beaconColor:nearestBeacon], //nearestBeacon.minor.stringValue,
                        RSSI, [self proxmityString:nearestBeacon.proximity],
                        ENTRY_TIME, [self dateStringWithDSTOffset:entryTime],
                        EXIT_TIME, [self dateStringWithDSTOffset:exitTime],
                        DWELL_TIME, [NSString stringWithFormat:@"%.2f", [[NSDate date] timeIntervalSinceDate:entryTime]],
                        FB_ID, user.Id,
                        FB_FULL_NAME, user.fullName,
                        FB_GENDER, user.gender,
                        FB_EMAIL, user.email];
    
    NSData *paramsData = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:paramsData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
         if (data.length > 0 && connectionError == nil) {
             NSLog(@"== Successfully posted data ==");
             
         } else if (data.length == 0 && connectionError == nil) {
             NSLog(@"No data");
             
         } else if (connectionError != nil) {
             NSLog(@"Connection Error %@", connectionError);
         }
     }];
    
}

    
// offset date if daylight saving is on
- (NSString *)dateStringWithDSTOffset:(NSDate *)date
{
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    return [df stringFromDate:date];
}

// relative distance string value to beacon
- (NSString *)proxmityString:(CLProximity)proximity
{
    NSString *proximityString;
    
    switch (proximity) {
        case CLProximityNear:
            proximityString = @"Near";
            break;
        case CLProximityImmediate:
            proximityString = @"Immediate";
            break;
        case CLProximityFar:
            proximityString = @"Far";
            break;
        case CLProximityUnknown:
        default:
            proximityString = @"Unknown";
            break;
    }
    
    return proximityString;
}

- (NSString *)beaconColor:(CLBeacon *)beacon
{
    NSString *beaconColour;
    
    if ([beacon.minor isEqualToNumber:@58605]) {
        beaconColour = @"Blue iBeacon";
        
    } else if ([beacon.minor isEqualToNumber:@18108]) {
        beaconColour = @"Green iBeacon";
        
    } else if ([beacon.minor isEqualToNumber:@57466]) {
        beaconColour = @"Purple iBeacon";
        
    }
    
    return beaconColour;
}


@end
