//
//  PWCFacebookService.h
//  Bacon
//
//  Created by Ravi on 11/12/2013.
//  Copyright (c) 2013 PWC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/Facebook.h>


@interface PWCFacebookService : NSObject

@property (strong, nonatomic) FBSession *session;


- (void)authenticateWithFacebook;

//- (void)fetchFacebookUserInfo;

@end
