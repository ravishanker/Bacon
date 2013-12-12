//
//  PWCViewController.m
//  Bacon
//
//  Created by Ravi on 9/12/2013.
//  Copyright (c) 2013 PWC. All rights reserved.
//

#import "PWCViewController.h"
#import "PWCFacebookService.h"
#import "PWCGoogleDriveService.h"
#import "PWCBeaconService.h"

@interface PWCViewController ()

@property (nonatomic, strong) PWCFacebookService *fbService;
@property (nonatomic, strong) PWCGoogleDriveService *gDriveService;
@property (nonatomic, strong) PWCBeaconService *beaconService;

@end

@implementation PWCViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _fbService = [[PWCFacebookService alloc] init];
    [_fbService authenticateWithFacebook];
    
    _beaconService = [[PWCBeaconService alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setProductOffer:)
                                                 name:@"beacon"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setLatestOffer:)
                                                 name:@"offer"
                                               object:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.offerImage.image = [UIImage imageNamed:@"iconBeacon"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (void)setProductOffer:(NSNumber *)minor
- (void)setProductOffer:(NSNotification *)note
{
    CLBeacon *beacon = [note object];
    
    if ([beacon.minor isEqualToNumber:@58605]) {
        self.offerImage.image = [UIImage imageNamed:@"blue_medium"];
        
    } else if ([beacon.minor isEqualToNumber:@18108]) {
        self.offerImage.image = [UIImage imageNamed:@"green_small"];
        
    } else if ([beacon.minor isEqualToNumber:@57466]) {
        self.offerImage.image = [UIImage imageNamed:@"purple_large"];
        
    } else {
        self.offerImage.image = [UIImage imageNamed:@"iconBeacon"];
    }
    
}

- (void)setLatestOffer:(NSNotification *)note
{
    self.offerImage.image = [UIImage imageNamed:@"big_red_sale.jpg"];
}


@end
