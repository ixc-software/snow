//
//  InfoViewController.h
//  snow
//
//  Created by Alex Vinogradov on 01.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SocialNetworksAuthViewController.h"
#import "CompanyAndUserConfiguration.h"

@class SocialNetworksAuthViewController;

@interface InfoViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
@private
    UITextView *readme;
    IBOutlet UILabel *operation;
    UINavigationController *companyInfoAndConfig;
    IBOutlet UIButton *imgButton;
    

}

@property (nonatomic, retain)  IBOutlet UITextView *readme;
@property (nonatomic, retain)  IBOutlet UIButton *imgButton;
@property (nonatomic, retain)  IBOutlet UILabel *operation;
@property (nonatomic, retain)  IBOutlet UIProgressView *operationProgress;

@property (retain, nonatomic) IBOutlet UIToolbar *errorToolBar;


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UINavigationController *companyInfoAndConfig;
@property (nonatomic, retain) SocialNetworksAuthViewController *socialNetworksViewController;

// main page items
@property (retain, nonatomic) IBOutlet UILabel *wellcomeTitle;
@property (retain, nonatomic) IBOutlet UILabel *wellcomeSubTitle;
@property (retain, nonatomic) IBOutlet UILabel *companyName;
@property (retain, nonatomic) IBOutlet UILabel *income;
@property (retain, nonatomic) IBOutlet UILabel *profit;
@property (retain, nonatomic) IBOutlet UILabel *profitability;
@property (retain, nonatomic) IBOutlet UILabel *routesQuantityWeBuy;
@property (retain, nonatomic) IBOutlet UILabel *routesQuantityForSale;
@property (retain, nonatomic) IBOutlet UILabel *routesQuantityPushList;
@property (retain, nonatomic) IBOutlet UILabel *carriersQuantity;
@property (retain, nonatomic) IBOutlet UILabel *routesTitle;


-(IBAction)updateTwitter:(id)sender; 

@end
