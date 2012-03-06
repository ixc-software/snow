//
//  InfoViewController.h
//  snow
//
//  Created by Alex Vinogradov on 01.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "TwitterAuthorizationController.h"
#import "CompanyAndUserConfiguration.h"
//#import "PDColoredProgressView.h"
//#import "SA_OAuthTwitterController.h"

@class TwitterAuthorizationController;

@interface InfoViewController : UIViewController <MFMailComposeViewControllerDelegate>
//,SA_OAuthTwitterControllerDelegate>
{
@private
    UITextView *readme;
    IBOutlet UILabel *operation;
    //CompanyAndUserConfiguration *companyInfoAndConfig;
    UINavigationController *companyInfoAndConfig;
    //SA_OAuthTwitterEngine *_engine;
    IBOutlet UIButton *imgButton;
    

}

@property (nonatomic, retain)  IBOutlet UITextView *readme;
@property (nonatomic, retain)  IBOutlet UIButton *imgButton;
@property (nonatomic, retain)  IBOutlet UILabel *operation;
@property (nonatomic, retain)  IBOutlet UIProgressView *operationProgress;

//@property (nonatomic, retain) SA_OAuthTwitterEngine *_engine;




@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UINavigationController *companyInfoAndConfig;
@property (nonatomic, retain) TwitterAuthorizationController *tw;

-(IBAction)updateTwitter:(id)sender; 

@end
