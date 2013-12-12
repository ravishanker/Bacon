//
//  PWCFacebookService.m
//  Bacon
//
//  Created by Ravi on 11/12/2013.
//  Copyright (c) 2013 PWC. All rights reserved.
//

#import "PWCFacebookService.h"
#import "PWCUser.h"

@interface PWCFacebookService()

@property (strong, nonatomic) PWCUser *user;

@end

@implementation PWCFacebookService

- (id)init
{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

- (void)authenticateWithFacebook;
{
    // Login or get user data from Facebook
    NSArray *permissions = @[@"basic_info", @"email"];
//    NSLog(@"%@", self.session.isOpen ? @"YES" : @"NO");
    
    if (self.session.isOpen) {
        
        if (!_user) {
            _user = [PWCUser getUser];
            NSLog(@"%@ User in session open", _user.fullName);
        }
        
    } else {
        //Login with Facebook native login diaglog
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          
                                          if (!error) {
                                              NSLog(@"== Login Success %@ session, %d status", session, status);
                                              self.session = session;

                                          } else {
                                              NSLog(@"%@ error!", error);
                                          }
                                      }];
        
    }
    
}


//- (void)fetchFacebookUserInfo
//{
//    //    [FBSettings setLoggingBehavior:[NSSet setWithObjects:
//    //                                    FBLoggingBehaviorFBRequests, nil]];
//    
//    // Fetch user data
//    [FBRequestConnection
//     startForMeWithCompletionHandler:^(FBRequestConnection *connection,
//                                       id<FBGraphUser> user,
//                                       NSError *error) {
//         if (!error) {
//             _user = [[PWCUser alloc] initWithFBGraphUser:user];
//             NSLog(@"%@ User in fetchFBInfo", _user.description);
//
//         }
//     }];
//    
//}



@end
