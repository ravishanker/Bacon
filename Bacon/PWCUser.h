//
//  PWCUser.h
//  Bacon
//
//  Created by Ravi on 11/12/2013.
//  Copyright (c) 2013 PWC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/Facebook.h>
//#import "PWCFacebookService.h"


@interface PWCUser : NSObject <NSCoding>

@property (strong, nonatomic) NSString * Id;
@property (strong, nonatomic) NSString * fullName;
@property (strong, nonatomic) NSString * gender;
@property (strong, nonatomic) NSString * email;


- (id)initWithFBGraphUser;

+ (NSString *)getPathToArchive;
+ (void)saveUser:(PWCUser *)aUser;
+ (PWCUser *)getUser;

@end
