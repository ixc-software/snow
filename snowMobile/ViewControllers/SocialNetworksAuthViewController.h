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
#import "LinkedinUpdateDataController.h"
#import "LinkedinGroupsTableViewCell.h"

@class InfoViewController;
@interface SocialNetworksAuthViewController : UIViewController <UIWebViewDelegate,UITextFieldDelegate> {
    
    IBOutlet LinkedinGroupsTableViewCell *cellInfo;

}

@property (nonatomic,retain) IBOutlet UISegmentedControl *authorize;
@property (nonatomic,retain) IBOutlet UISegmentedControl *back;
@property (nonatomic,retain) IBOutlet UITextField *pin;
@property (nonatomic,retain) IBOutlet UIWebView *webView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activity;
@property (readwrite) NSUInteger countTremorAnimation;

@property (nonatomic,retain) UINavigationController *infoController;

@property (nonatomic,retain) TwitterUpdateDataController *twitterController;
@property (nonatomic,retain) LinkedinUpdateDataController *linkedinController;
@property (nonatomic,retain) InfoViewController *infoViewController;

@property (retain, nonatomic) IBOutlet UIImageView *authorizedDoneLogo;
@property (retain, nonatomic) IBOutlet UILabel *authorizedDoneTitle;

@property (readwrite) BOOL isAuthorizationProcessed;
//@property (readwrite) BOOL isAuthorized;
@property (retain, nonatomic) IBOutlet UIButton *reloadButton;

-(BOOL)isTwitterAuthorized;
-(void) sendTwitterUpdate:(NSString *)text;
@property (retain, nonatomic) IBOutlet UISegmentedControl *changeAuthorizationType;

// linkedin groups view
@property (retain, nonatomic) IBOutlet UITableView *groupsList;
@property (retain, nonatomic) IBOutlet UISegmentedControl *groupsBack;
@property (retain, nonatomic) IBOutlet UIView *groupsView;
@property (nonatomic, retain) LinkedinGroupsTableViewCell *cellInfo;
@property (nonatomic,retain) NSMutableArray *groupListObjects;
@property (retain, nonatomic) IBOutlet UIImageView *twitterEnabled;
@property (retain, nonatomic) IBOutlet UIImageView *linkedinEnabled;
@property (retain, nonatomic) IBOutlet UIImageView *facebookEnabled;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *groupsActivity;
@property (readwrite) BOOL isGroupToPostSelected;
@property (retain, nonatomic) IBOutlet UISegmentedControl *groupsToMessage;
@property (retain, nonatomic) IBOutlet UISegmentedControl *saveChanges;

-(void)linkedinGroupsList:(NSDictionary *)parsedGroups withLatestGroups:(NSNumber *)isLatestGroup;


@end
