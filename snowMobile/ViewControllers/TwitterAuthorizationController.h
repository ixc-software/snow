//
//  TwitterAuthController.h
//  snow
//
//  Created by Oleksii Vynogradov on 24.08.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "InfoViewController.h"
#import "TwitterUpdateDataController.h"

@class InfoViewController;
@interface TwitterAuthorizationController : UIViewController <UIWebViewDelegate,UITextFieldDelegate> {
    
    
}

@property (nonatomic,retain) IBOutlet UISegmentedControl *authorize;
@property (nonatomic,retain) IBOutlet UISegmentedControl *back;
@property (nonatomic,retain) IBOutlet UITextField *pin;
@property (nonatomic,retain) IBOutlet UIWebView *webView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activity;
@property (readwrite) NSUInteger countTremorAnimation;

@property (nonatomic,retain) UINavigationController *infoController;

@property (nonatomic,retain) TwitterUpdateDataController *twitterController;
@property (nonatomic,retain) InfoViewController *infoViewController;


@property (readwrite) BOOL isAuthorizationProcessed;
//@property (readwrite) BOOL isAuthorized;

-(BOOL)isAuthorized;
-(void) sendUpdate:(NSString *)text;

@end
