//
//  DarkView.h
//  snow
//
//  Created by Oleksii Vynogradov on 07.11.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthorizationView : UIViewController <UITextFieldDelegate,UIActionSheetDelegate> 

@property (retain, nonatomic) IBOutlet UITableView *emailAndPassword;
@property (retain, nonatomic) IBOutlet UISegmentedControl *login;
@property (retain, nonatomic) IBOutlet UISegmentedControl *registration;
@property (retain, nonatomic) IBOutlet UIImageView *logo;

//@property (retain, nonatomic) NSMutableString *email;
//@property (retain, nonatomic) NSMutableString *password;
//@property (retain, nonatomic) NSMutableString *company;

@property (readwrite) NSUInteger countTremorAnimation;
@property (retain, nonatomic) IBOutlet UILabel *companyName;
@property (readwrite) BOOL isEmailPasswordBlockMoved;
@property (readwrite) BOOL isJoinStarted;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loginActivity;
@property (retain, nonatomic) IBOutlet UISegmentedControl *errorMessage;

@property (retain, nonatomic) IBOutlet UILabel *firstSocialNetwork;

@property (retain, nonatomic) UITextField *emailLabel;
@property (retain, nonatomic) UITextField *passwordLabel;
@property (retain, nonatomic) UITextField *companyNameLabel;


@end
