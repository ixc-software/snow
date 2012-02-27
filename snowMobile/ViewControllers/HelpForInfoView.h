//
//  HelpForInfoView.h
//  snow
//
//  Created by Oleksii Vynogradov on 07.11.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpForInfoView : UIViewController
@property (retain, nonatomic) IBOutlet UIImageView *upperFinger;
@property (retain, nonatomic) IBOutlet UITextView *helpText;
@property (retain, nonatomic) IBOutlet UIImageView *logo;
@property (retain, nonatomic) IBOutlet UIButton *mainTextButton;
@property (retain, nonatomic) IBOutlet UIImageView *downFinger;
@property (retain, nonatomic) IBOutlet UIImageView *upperPress;
@property (retain, nonatomic) IBOutlet UIImageView *downPress;

@property (assign) id delegate;

@property (readwrite) BOOL isInfoSheet; 
@property (readwrite) BOOL isConfigSheet;
@property (readwrite) BOOL isEventsSheet; 
@property (readwrite) BOOL isAddRoutesSheet; 
@property (readwrite) BOOL isRoutesListSheet; 
@property (readwrite) BOOL isCarriersList; 
@property (readwrite) BOOL isCarriersListFromDestinationsList; 


@property (retain) NSNumber *currentTipNumber;

// out of using:
@property (retain, nonatomic) IBOutlet UIImageView *eventsFinger;
@property (retain, nonatomic) IBOutlet UIImageView *routesFinger;
@property (retain, nonatomic) IBOutlet UIImageView *twitterFinger;
@property (retain, nonatomic) IBOutlet UIImageView *twitterPress;
@property (retain, nonatomic) IBOutlet UIImageView *eventsPress;
@property (retain, nonatomic) IBOutlet UIImageView *routesPress;

-(BOOL)isHelpNecessary;

@end
