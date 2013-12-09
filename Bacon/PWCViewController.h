//
//  PWCViewController.h
//  Bacon
//
//  Created by Ravi on 9/12/2013.
//  Copyright (c) 2013 PWC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/Facebook.h>

@interface PWCViewController : UIViewController

@property (strong, nonatomic) FBSession *session;

@property (weak, nonatomic) IBOutlet UIImageView *offerImage;

@end
