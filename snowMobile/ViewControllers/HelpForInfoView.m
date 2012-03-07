//
//  HelpForInfoView.m
//  snow
//
//  Created by Oleksii Vynogradov on 07.11.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//
#import "mobileAppDelegate.h"
#import "HelpForInfoView.h"
#import <QuartzCore/QuartzCore.h>

@implementation HelpForInfoView
@synthesize upperFinger;
@synthesize helpText;
@synthesize logo;
@synthesize mainTextButton;
@synthesize downFinger;
@synthesize eventsFinger;
@synthesize routesFinger;
@synthesize twitterFinger;
@synthesize upperPress;
@synthesize twitterPress;
@synthesize eventsPress;
@synthesize routesPress;
@synthesize downPress;

@synthesize isInfoSheet,isConfigSheet,isEventsSheet,isAddRoutesSheet,isRoutesListSheet,isCarriersList,isCarriersListFromDestinationsList,isSocialNetworkAuthViewTwitter,isSocialNetworkAuthViewLinkedin,isSocialNetworkAuthViewLinkedinMessage;

@synthesize delegate;

@synthesize currentTipNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) prepareTextAndImagesForNextTip;
{
//    NSUInteger correctXForIpad = 0;
//    NSUInteger correctYForIpad = 0;
    mobileAppDelegate *delegateMain = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL isPad = [delegateMain isPad];
    
//    if ([delegateMain isPad]) { 
//        correctXForIpad = 200;
//        correctYForIpad = 550;
//    }
    
    if (isInfoSheet) {
        switch ([currentTipNumber unsignedIntegerValue]) {
            case 0:
                self.helpText.text = @"You are here, in this tab your can change configuration and read info about social network rules";
                self.downPress.hidden = NO;
                self.downFinger.hidden = NO;
                if (isPad) {
                    self.view.frame = CGRectMake(self.view.frame.origin.x + 180, self.view.frame.origin.y + 600, self.view.frame.size.width, self.view.frame.size.height);
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x , self.downPress.frame.origin.y - 50 , self.downPress.frame.size.width, self.downPress.frame.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x  , self.downFinger.frame.origin.y - 50, self.downFinger.frame.size.width, self.downFinger.frame.size.height); 

                } else {
                    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                    
                }
                
                //                self.view.frame = CGRectMake(self.downFinger.frame.origin.x + correctXForIpad, self.downFinger.frame.origin.y + correctYForIpad, self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                
                break;
            case 1:
                self.helpText.text = @"From this menu, you can check next events in countries and add to pushlist destinations from events list.";
                self.downPress.hidden = NO;
                self.downFinger.hidden = NO;
                
                if (isPad) {
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 115 , self.downPress.frame.origin.y , self.downPress.frame.size.width, self.downPress.frame.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 115 , self.downFinger.frame.origin.y , self.downFinger.frame.size.width, self.downFinger.frame.size.height); 
                } else {
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 82 , self.downPress.frame.origin.y , self.downPress.frame.size.width, self.downPress.frame.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 82 , self.downFinger.frame.origin.y , self.downFinger.frame.size.width, self.downFinger.frame.size.height); 
                }
                
                //[self.downPress setNeedsDisplay];
                break;
            case 2:
                self.helpText.text = @"From routes menu you can add routes to push list, change ACD, ASR, Volume, price.";
                
                if (isPad) {
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 110 , self.downPress.frame.origin.y , self.downPress.frame.size.width, self.downPress.bounds.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 110 , self.downFinger.frame.origin.y , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                } else {
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 78 , self.downPress.frame.origin.y , self.downPress.frame.size.width, self.downPress.bounds.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 78 , self.downFinger.frame.origin.y , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                }
                self.downPress.hidden = NO;
                self.downFinger.hidden = NO;
                break;
            case 3:
                self.helpText.text = @"From this block you can add/remove/rename carriers from list.";
                
                if (isPad) {
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 110 , self.downPress.frame.origin.y , self.downPress.frame.size.width, self.downPress.bounds.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 110 , self.downFinger.frame.origin.y , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                } else {
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 80 , self.downPress.frame.origin.y , self.downPress.frame.size.width, self.downPress.bounds.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 80 , self.downFinger.frame.origin.y , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                }
                self.downPress.hidden = NO;
                self.downFinger.hidden = NO;
                break;

            case 4:
                self.helpText.text = @"In configuration menu you can change you first and last name, email and pasword, change your company name, join to another companies. Also you can approve user's registrations there.";
                self.upperPress.hidden = NO;
                self.upperFinger.hidden = NO;
                if (isPad) {
                    self.view.frame = CGRectMake(self.view.frame.origin.x + 30, self.view.frame.origin.y - 600, self.view.frame.size.width, self.view.frame.size.height);
                }
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
            case 5:
                self.helpText.text = @"In twitter menu you can authorize application to using with twitter account. After you will make authorization, application will automatically post to twitter all routes requirements.";
                self.upperPress.hidden = NO;
                self.upperFinger.hidden = NO;

                if (isPad) {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 320 , self.upperPress.frame.origin.y , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 320 , self.upperFinger.frame.origin.y , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 80 , self.upperPress.frame.origin.y , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 80 , self.upperFinger.frame.origin.y , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                }
                
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
            case 6:
            {
                NSMutableDictionary *help = [[NSUserDefaults standardUserDefaults] objectForKey:@"help"];
                NSMutableDictionary *helpMutable = [NSMutableDictionary dictionaryWithDictionary:help];
                [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isInfoSheet"];
                [[NSUserDefaults standardUserDefaults] setObject:helpMutable forKey:@"help"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.view removeFromSuperview];
                [delegate performSelectorOnMainThread:@selector(helpShowingDidFinish) withObject:nil waitUntilDone:NO];
            }
                break;
                

                
            default:
                break;
        }
    }
    
    if (isConfigSheet) {
        switch ([currentTipNumber unsignedIntegerValue]) {
            case 0:
                if (isPad) {
                    
                    self.view.frame = CGRectMake(self.view.frame.origin.x + 100, self.view.frame.origin.y + 20, self.view.frame.size.width, self.view.frame.size.height);
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 280 , self.upperPress.frame.origin.y + 60 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 280 , self.upperFinger.frame.origin.y + 60 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 20, self.view.frame.size.width, self.view.frame.size.height);
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 180 , self.upperPress.frame.origin.y + 30 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 180 , self.upperFinger.frame.origin.y + 30 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                    
                }
                self.helpText.text = @"In that block you can change your own data, first and last name, email and password. To start registration your have to change default email as well";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = NO;
                
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
            case 1:
                self.helpText.text = @"This block is showing you company name (company where u working now). If u will select this row, you will see companies menu, where you can add new company, change company name or join to current company, which registered by other user.";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = NO;
                
                if (isPad) {
                    
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x , self.upperPress.frame.origin.y + 240 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x , self.upperFinger.frame.origin.y + 240 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x , self.upperPress.frame.origin.y + 240 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x , self.upperFinger.frame.origin.y + 240 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                    
                }
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
//            case 2:
//                self.helpText.text = @"From this block you can add/remove/rename carriers from list. Please register before add any carriers. To start editing just press Edit button, and then, when u finish, press Save button.";
//                self.upperPress.hidden = YES;
//                self.upperFinger.hidden = YES;
//                self.downPress.hidden = YES;
//                self.downFinger.hidden = NO;
//                if (isPad) {
//                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x - 100 , self.downFinger.frame.origin.y , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
//                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x - 100 , self.downPress.frame.origin.y , self.downPress.frame.size.width, self.downPress.bounds.size.height);
//
//                } else {
//                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x , self.downFinger.frame.origin.y - 20 , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
//                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x , self.downPress.frame.origin.y - 20, self.downPress.frame.size.width, self.downPress.bounds.size.height);
//
//                }
//                break;
            case 2:
                self.helpText.text = @"Bellow carriers block you will see user's registration, which u receive if you are company admin and somebody like to join to your company.";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = YES;
                self.downPress.hidden = YES;
                self.downFinger.hidden = NO;
                if (isPad) {
                    
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 200 , self.downFinger.frame.origin.y + 30 , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 200 , self.downPress.frame.origin.y + 50, self.downPress.frame.size.width, self.downPress.bounds.size.height);

                } else {
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 200 , self.downFinger.frame.origin.y   - 10, self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 200 , self.downPress.frame.origin.y, self.downPress.frame.size.width, self.downPress.bounds.size.height);

                    
                }
                break;
//            case 3:
//                self.helpText.text = @"After you change default email and your contact information, just press this button to register on server.";
//                self.upperPress.hidden = YES;
//                self.upperFinger.hidden = YES;
//                self.downPress.hidden = NO;
//                self.downFinger.hidden = NO;
//                if (isPad) {
//                    
//                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 360 , self.downFinger.frame.origin.y  - 170, self.downFinger.frame.size.width, self.downFinger.frame.size.height);
//                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 360 , self.downPress.frame.origin.y - 170, self.downPress.frame.size.width, self.downPress.bounds.size.height);
//
//                } else {
//                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x  , self.downFinger.frame.origin.y - 60 , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
//                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x , self.downPress.frame.origin.y - 60, self.downPress.frame.size.width, self.downPress.bounds.size.height);
//
//                    
//                }
//                break;

            case 3:
            {
                NSMutableDictionary *help = [[NSUserDefaults standardUserDefaults] objectForKey:@"help"];
                NSMutableDictionary *helpMutable = [NSMutableDictionary dictionaryWithDictionary:help];
                [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isConfigSheet"];
                [[NSUserDefaults standardUserDefaults] setObject:helpMutable forKey:@"help"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [self.view removeFromSuperview];
                [delegate performSelectorOnMainThread:@selector(helpShowingDidFinish) withObject:nil waitUntilDone:NO];
            }
                break;
                
                
                
            default:
                break;
        }
    }
    
    if (isEventsSheet) {
        switch ([currentTipNumber unsignedIntegerValue]) {
            case 0:
                if (isPad) {
                    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 20 , self.view.frame.size.width, self.view.frame.size.height);
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 130 , self.upperPress.frame.origin.y + 30 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 130 , self.upperFinger.frame.origin.y + 30 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 20 , self.view.frame.size.width, self.view.frame.size.height);
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 130 , self.upperPress.frame.origin.y + 30 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 130 , self.upperFinger.frame.origin.y + 30 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);

                }
                self.helpText.text = @"You can search events by country name here.";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = NO;
                
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
            case 1:
                self.helpText.text = @"If you will click to event, you may see country specific destinations, add those destinations to push list, and add event to local calendar.";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = YES;
                if (isPad) {
                    
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 100 , self.downPress.frame.origin.y - 90 , self.downPress.frame.size.width, self.downPress.frame.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 100 , self.downFinger.frame.origin.y - 90 , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                } else {
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 100 , self.downPress.frame.origin.y - 90 , self.downPress.frame.size.width, self.downPress.frame.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 100 , self.downFinger.frame.origin.y - 90 , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                    
                }
                self.downPress.hidden = NO;
                self.downFinger.hidden = NO;
                break;
           case 2:
            {
                NSMutableDictionary *help = [[NSUserDefaults standardUserDefaults] objectForKey:@"help"];
                NSMutableDictionary *helpMutable = [NSMutableDictionary dictionaryWithDictionary:help];
                [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isEventsSheet"];
                [[NSUserDefaults standardUserDefaults] setObject:helpMutable forKey:@"help"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [self.view removeFromSuperview];
                [delegate performSelectorOnMainThread:@selector(helpShowingDidFinish) withObject:nil waitUntilDone:NO];
            }
                break;
                
                
                
            default:
                break;
        }
    }
    
    if (isRoutesListSheet) {
        switch ([currentTipNumber unsignedIntegerValue]) {
            case 0:
                
                self.helpText.text = @"Here is configuration menu for all routes. By click it u have chance to post all routes to Linkedin/Twitter, or add routes in list.";
                self.upperPress.hidden = NO;
                self.upperFinger.hidden = NO;
                
                if (isPad) {
                    NSUInteger diffrerent = 0;
                    if (isCarriersListFromDestinationsList) diffrerent = 500 ;
                    else diffrerent = 280;
                    
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + diffrerent , self.upperPress.frame.origin.y , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + diffrerent , self.upperFinger.frame.origin.y , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 65 , self.upperPress.frame.origin.y + 10 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 65 , self.upperFinger.frame.origin.y + 10, self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                    
                }
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;

            case 1:
                
                self.helpText.text = @"You can search routes by country name or specific here.";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = NO;
                if (isPad) {
                    
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 190 , self.upperPress.frame.origin.y + 40 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 190 , self.upperFinger.frame.origin.y + 40 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 190 , self.upperPress.frame.origin.y + 40 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 190 , self.upperFinger.frame.origin.y + 40 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                    
                }
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
            case 2:
                self.helpText.text = @"If you will click to destination from list, destination will open to configure volume, ACD, ASR, price. Also you can do long press on opened destination, and showing menu will allow u to post one destination to Twitter or Linkedin, change carrier or remove destination from list.";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = YES;
                
                if (isPad) {
                    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y , self.view.frame.size.width, self.view.frame.size.height);

                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 100 , self.downPress.frame.origin.y - 90 , self.downPress.frame.size.width, self.downPress.frame.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 100 , self.downFinger.frame.origin.y - 90 , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                } else {
                    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 60 , self.view.frame.size.width, self.view.frame.size.height + 80);

                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 100 , self.downPress.frame.origin.y - 140 , self.downPress.frame.size.width, self.downPress.frame.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 100 , self.downFinger.frame.origin.y - 140 , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                    
                }
                self.downPress.hidden = NO;
                self.downFinger.hidden = NO;
                break;
            case 3:
            {
                NSMutableDictionary *help = [[NSUserDefaults standardUserDefaults] objectForKey:@"help"];
                NSMutableDictionary *helpMutable = [NSMutableDictionary dictionaryWithDictionary:help];
                [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isRoutesListSheet"];
                [[NSUserDefaults standardUserDefaults] setObject:helpMutable forKey:@"help"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [self.view removeFromSuperview];
                [delegate performSelectorOnMainThread:@selector(helpShowingDidFinish) withObject:nil waitUntilDone:NO];
            }
                break;
                
                
                
            default:
                break;
        }
    }

    if (isAddRoutesSheet) {
        switch ([currentTipNumber unsignedIntegerValue]) {
            case 0:
                
                self.helpText.text = @"To return in routes list, please press routes list.";
                self.upperPress.hidden = NO;
                self.upperFinger.hidden = NO;
                if (isPad) {
                    
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 280 , self.upperPress.frame.origin.y , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 280 , self.upperFinger.frame.origin.y , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 60 , self.upperPress.frame.origin.y , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 60 , self.upperFinger.frame.origin.y , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                }
                
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;

            case 1:
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                
                self.helpText.text = @"You can search routes, which you like to add by country name or specific or code here.";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = NO;
                
                if (isPad) {
                    
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 190 , self.upperPress.frame.origin.y + 10 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 190 , self.upperFinger.frame.origin.y + 10 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 190 , self.upperPress.frame.origin.y + 10 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 190 , self.upperFinger.frame.origin.y + 10 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                    
                }
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
            case 2:
                self.helpText.text = @"If you will click to country from list, country will open to show all specific with codes. If you will do long press, menu will opened to add destination/specific to pushlist.";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = YES;
                if (isPad) {
                    
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 100 , self.downPress.frame.origin.y - 90 , self.downPress.frame.size.width, self.downPress.frame.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 100 , self.downFinger.frame.origin.y - 90 , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                } else {
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 100 , self.downPress.frame.origin.y - 90 , self.downPress.frame.size.width, self.downPress.frame.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 100 , self.downFinger.frame.origin.y - 90 , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                    
                }
                self.downPress.hidden = NO;
                self.downFinger.hidden = NO;
                break;
            case 3:
            {
                NSMutableDictionary *help = [[NSUserDefaults standardUserDefaults] objectForKey:@"help"];
                NSMutableDictionary *helpMutable = [NSMutableDictionary dictionaryWithDictionary:help];
                [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isAddRoutesSheet"];
                [[NSUserDefaults standardUserDefaults] setObject:helpMutable forKey:@"help"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [self.view removeFromSuperview];
                [delegate performSelectorOnMainThread:@selector(helpShowingDidFinish) withObject:nil waitUntilDone:NO];
            }
                break;
                
                
                
            default:
                break;
        }
    }
    
    if (isCarriersList) {
        
        switch ([currentTipNumber unsignedIntegerValue]) {
            case 0:
                
                self.helpText.text = @"To edit or remove carrier in carriers list, please press edit button.";
                self.upperPress.hidden = NO;
                self.upperFinger.hidden = NO;
                if (isPad) {
                    
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 520 , self.upperPress.frame.origin.y, self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 520 , self.upperFinger.frame.origin.y, self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 60 , self.upperPress.frame.origin.y , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 60 , self.upperFinger.frame.origin.y , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                }
                
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
                
            case 1:
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                
                self.helpText.text = @"You can search carriers here.";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = NO;
                
                if (isPad) {
                    
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 190 , self.upperPress.frame.origin.y + 45 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 190 , self.upperFinger.frame.origin.y + 45 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 190 , self.upperPress.frame.origin.y + 45 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 190 , self.upperFinger.frame.origin.y + 45 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                    
                }
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
            case 2:
                self.helpText.text = @"If you will click to carrier, you will see all routes, which now this carrier like to push. If you will click, when you edit carrier, you can change carrier name.";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = YES;
                if (isPad) {
                    
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 100 , self.downPress.frame.origin.y - 90 , self.downPress.frame.size.width, self.downPress.frame.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 100 , self.downFinger.frame.origin.y - 90 , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                } else {
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 100 , self.downPress.frame.origin.y - 90 , self.downPress.frame.size.width, self.downPress.frame.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 100 , self.downFinger.frame.origin.y - 90 , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                    
                }
                self.downPress.hidden = NO;
                self.downFinger.hidden = NO;
                break;
            case 3:
            {
                NSMutableDictionary *help = [[NSUserDefaults standardUserDefaults] objectForKey:@"help"];
                NSMutableDictionary *helpMutable = [NSMutableDictionary dictionaryWithDictionary:help];
                [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isCarriersListSheet"];
                [[NSUserDefaults standardUserDefaults] setObject:helpMutable forKey:@"help"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.view removeFromSuperview];
                [delegate performSelectorOnMainThread:@selector(helpShowingDidFinish) withObject:nil waitUntilDone:NO];
            }
                break;
                
                
                
            default:
                break;
        }
    }

    if (isSocialNetworkAuthViewTwitter) {
        
        switch ([currentTipNumber unsignedIntegerValue]) {
            case 0:
                
                self.helpText.text = @"This is a place to select social network";
                self.upperPress.hidden = NO;
                self.upperFinger.hidden = NO;
                if (isPad) {
                    self.view.frame = CGRectMake(self.view.frame.origin.x + 180, self.view.frame.origin.y + 600, self.view.frame.size.width, self.view.frame.size.height);

                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 520 , self.upperPress.frame.origin.y, self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 520 , self.upperFinger.frame.origin.y, self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 60, self.view.frame.size.width, self.view.frame.size.height);

                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 40 , self.upperPress.frame.origin.y , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 40 , self.upperFinger.frame.origin.y , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                }
                
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
                
            case 1:
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                
                self.helpText.text = @"Then u will fill your user name and pass and click go, you will see pin, which u will write here.";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = NO;
                
                if (isPad) {
                    
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 190 , self.upperPress.frame.origin.y + 45 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 190 , self.upperFinger.frame.origin.y + 45 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 190 , self.upperPress.frame.origin.y + 60 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 190 , self.upperFinger.frame.origin.y + 60 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                    
                }
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
            case 2:
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                
                self.helpText.text = @"Then u will fill pin box, just press authorize to process authorization.";
                self.upperPress.hidden = NO;
                self.upperFinger.hidden = NO;
                
                if (isPad) {
                    
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 190 , self.upperPress.frame.origin.y + 45 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 190 , self.upperFinger.frame.origin.y + 45 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 120 , self.upperPress.frame.origin.y - 10, self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 120 , self.upperFinger.frame.origin.y - 10, self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                    
                }
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
            case 3:
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                
                self.helpText.text = @"You can anytime back to main menu if press back button.";
                self.upperPress.hidden = NO;
                self.upperFinger.hidden = NO;
                
                if (isPad) {
                    
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 60, self.upperPress.frame.origin.y + 45 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 60 , self.upperFinger.frame.origin.y + 45 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 100  , self.upperPress.frame.origin.y, self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 100 , self.upperFinger.frame.origin.y, self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                    
                }
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;


            case 4:
            {
                NSMutableDictionary *help = [[NSUserDefaults standardUserDefaults] objectForKey:@"help"];
                NSMutableDictionary *helpMutable = [NSMutableDictionary dictionaryWithDictionary:help];
                [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isSocialNetworkAuthViewTwitterSheet"];
                [[NSUserDefaults standardUserDefaults] setObject:helpMutable forKey:@"help"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.view removeFromSuperview];
                [delegate performSelectorOnMainThread:@selector(helpShowingDidFinish) withObject:nil waitUntilDone:NO];
            }
                break;
                
                
                
            default:
                break;
        }
    }

    if (isSocialNetworkAuthViewLinkedin) {
        
        switch ([currentTipNumber unsignedIntegerValue]) {
            case 0:
                
                self.helpText.text = @"Here is your own groups list, please select, to which groups you like to send messages.";
                self.upperPress.hidden = NO;
                self.upperFinger.hidden = NO;
                if (isPad) {
                    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 50, self.view.frame.size.width, self.view.frame.size.height);

                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 520 , self.upperPress.frame.origin.y, self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 520 , self.upperFinger.frame.origin.y, self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 50, self.view.frame.size.width, self.view.frame.size.height);

                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 50, self.upperPress.frame.origin.y + 60, self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 50, self.upperFinger.frame.origin.y + 60, self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                }
                
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
                
            case 1:
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                
                self.helpText.text = @"Please choice between groups list and message text editor";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = YES;
                if (isPad) {
                    
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 100 , self.downPress.frame.origin.y - 90 , self.downPress.frame.size.width, self.downPress.frame.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 100 , self.downFinger.frame.origin.y - 90 , self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                } else {
                    self.downPress.frame = CGRectMake(self.downPress.frame.origin.x + 150, self.downPress.frame.origin.y - 10, self.downPress.frame.size.width, self.downPress.frame.size.height);
                    self.downFinger.frame = CGRectMake(self.downFinger.frame.origin.x + 150, self.downFinger.frame.origin.y - 10, self.downFinger.frame.size.width, self.downFinger.frame.size.height);
                    
                }
                self.downPress.hidden = NO;
                self.downFinger.hidden = NO;
                break;
            case 2:
            {
                NSMutableDictionary *help = [[NSUserDefaults standardUserDefaults] objectForKey:@"help"];
                NSMutableDictionary *helpMutable = [NSMutableDictionary dictionaryWithDictionary:help];
                [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isSocialNetworkAuthViewLinkedinSheet"];
                [[NSUserDefaults standardUserDefaults] setObject:helpMutable forKey:@"help"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.view removeFromSuperview];
                [delegate performSelectorOnMainThread:@selector(helpShowingDidFinish) withObject:nil waitUntilDone:NO];
            }
                break;
            default:
                break;
        }
    }

    if (isSocialNetworkAuthViewLinkedinMessage) {
        
        switch ([currentTipNumber unsignedIntegerValue]) {
            case 0:
                
                self.helpText.text = @"Here is you can edit posting title.";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = NO;
                if (isPad) {
                    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);

                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 520 , self.upperPress.frame.origin.y, self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 520 , self.upperFinger.frame.origin.y, self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 160, self.view.frame.size.width, self.view.frame.size.height);

                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x  , self.upperPress.frame.origin.y - 80, self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x , self.upperFinger.frame.origin.y - 80, self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                }
                
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
                
            case 1:
//                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                
                self.helpText.text = @"Here is you can edit a first part (main body) of you message.";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = NO;
                
                if (isPad) {
                    
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x , self.upperPress.frame.origin.y + 45 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x  , self.upperFinger.frame.origin.y + 45 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x  , self.upperPress.frame.origin.y + 45 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x  , self.upperFinger.frame.origin.y + 45 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                    
                }
                self.downPress.hidden = YES;
                self.downFinger.hidden = NO;
                break;
            case 2:
                //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                
                self.helpText.text = @"Please keep in your mind, than here will be routes list, if you like to post rates, please uncheck button";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = NO;
                
                if (isPad) {
                    
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 190 , self.upperPress.frame.origin.y + 45 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x - 190 , self.upperFinger.frame.origin.y + 45 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x - 50 , self.upperPress.frame.origin.y + 40, self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x  - 50, self.upperFinger.frame.origin.y + 40, self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                    
                }
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
            case 3:
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                
                self.helpText.text = @"Here is may be you signature like:\nOleksii Vinogradov\nsales manager\nphone:+380442399740\nskype:oleksiivinogradov";
                self.upperPress.hidden = YES;
                self.upperFinger.hidden = NO;
                
                if (isPad) {
                    
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x + 60, self.upperPress.frame.origin.y + 45 , self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x + 60 , self.upperFinger.frame.origin.y + 45 , self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                } else {
                    self.upperPress.frame = CGRectMake(self.upperPress.frame.origin.x   , self.upperPress.frame.origin.y + 50, self.upperPress.frame.size.width, self.upperPress.frame.size.height);
                    self.upperFinger.frame = CGRectMake(self.upperFinger.frame.origin.x , self.upperFinger.frame.origin.y + 50, self.upperFinger.frame.size.width, self.upperFinger.frame.size.height);
                    
                }
                self.downPress.hidden = YES;
                self.downFinger.hidden = YES;
                break;
                
                
            case 4:
            {
                NSMutableDictionary *help = [[NSUserDefaults standardUserDefaults] objectForKey:@"help"];
                NSMutableDictionary *helpMutable = [NSMutableDictionary dictionaryWithDictionary:help];
                [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isSocialNetworkAuthViewLinkedinMessageSheet"];
                [[NSUserDefaults standardUserDefaults] setObject:helpMutable forKey:@"help"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.view removeFromSuperview];
                [delegate performSelectorOnMainThread:@selector(helpShowingDidFinish) withObject:nil waitUntilDone:NO];
            }
                break;
                
                
                
            default:
                break;
        }
    }

    
    self.currentTipNumber = [NSNumber numberWithUnsignedInteger:[currentTipNumber unsignedIntegerValue] + 1];

    
}

-(BOOL)isHelpNecessary;
{
    NSMutableDictionary *help = [[NSUserDefaults standardUserDefaults] objectForKey:@"help"];

    NSNumber *isHelpNecesary = nil;

    if (isInfoSheet)  isHelpNecesary = [help valueForKey:@"isInfoSheet"];
    if (isConfigSheet)  isHelpNecesary = [help valueForKey:@"isConfigSheet"];
    if (isEventsSheet)  isHelpNecesary = [help valueForKey:@"isEventsSheet"];
    if (isAddRoutesSheet)  isHelpNecesary = [help valueForKey:@"isAddRoutesSheet"];
    if (isRoutesListSheet)  isHelpNecesary = [help valueForKey:@"isRoutesListSheet"];
    if (isCarriersList)  isHelpNecesary = [help valueForKey:@"isCarriersListSheet"];
    if (isSocialNetworkAuthViewTwitter)  isHelpNecesary = [help valueForKey:@"isSocialNetworkAuthViewTwitterSheet"];
    if (isSocialNetworkAuthViewLinkedin)  isHelpNecesary = [help valueForKey:@"isSocialNetworkAuthViewLinkedinSheet"];
    if (isSocialNetworkAuthViewLinkedinMessage)  isHelpNecesary = [help valueForKey:@"isSocialNetworkAuthViewLinkedinMessageSheet"];


    if (isHelpNecesary) return [isHelpNecesary boolValue];
    else return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    CALayer *mainButton = [self.mainTextButton layer];
    mainButton.borderWidth = 3.0;
    mainButton.borderColor = [UIColor colorWithRed:0.17 green:0.16 blue:0.49 alpha:1.0].CGColor;
    mainButton.cornerRadius = 9.0;
 
    CALayer *logoLayer = [self.logo layer];
    logoLayer.borderWidth = 3.0;
    logoLayer.borderColor = [UIColor whiteColor].CGColor;
    logoLayer.cornerRadius = 9.0;
    logoLayer.masksToBounds = YES;
    logoLayer.opaque = NO;
    [self prepareTextAndImagesForNextTip];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setUpperFinger:nil];
    [self setHelpText:nil];
    [self setMainTextButton:nil];
    [self setLogo:nil];
    [self setDownFinger:nil];
    [self setEventsFinger:nil];
    [self setRoutesFinger:nil];
    [self setTwitterFinger:nil];
    [self setUpperPress:nil];
    [self setTwitterPress:nil];
    [self setEventsPress:nil];
    [self setRoutesPress:nil];
    [self setDownPress:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancel:(id)sender {
    //NSLog(@"CANCEL");

    [self.view removeFromSuperview];
    [delegate performSelectorOnMainThread:@selector(helpShowingDidFinish) withObject:nil waitUntilDone:NO];
    NSMutableDictionary *help = [[NSUserDefaults standardUserDefaults] objectForKey:@"help"];
    NSMutableDictionary *helpMutable = [NSMutableDictionary dictionaryWithDictionary:help];

    if (isInfoSheet)  [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isInfoSheet"]; 
    if (isConfigSheet)  [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isConfigSheet"];
    if (isEventsSheet)  [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isEventsSheet"];
    if (isAddRoutesSheet)  [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isAddRoutesSheet"]; 
    if (isRoutesListSheet)  [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isRoutesListSheet"];
    if (isCarriersList || isCarriersListFromDestinationsList)  [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isCarriersListSheet"];
    if (isSocialNetworkAuthViewTwitter) [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isSocialNetworkAuthViewTwitterSheet"];
    if (isSocialNetworkAuthViewLinkedin) [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isSocialNetworkAuthViewLinkedinSheet"];
    if (isSocialNetworkAuthViewLinkedinMessage) [helpMutable setObject:[NSNumber numberWithBool:NO] forKey:@"isSocialNetworkAuthViewLinkedinMessageSheet"];
    [[NSUserDefaults standardUserDefaults] setObject:helpMutable forKey:@"help"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)nextTip:(id)sender {
    [self prepareTextAndImagesForNextTip];    
}

- (void)dealloc {
    [upperFinger release];
    [helpText release];
    [mainTextButton release];
    [logo release];
    [downFinger release];
    [eventsFinger release];
    [routesFinger release];
    [twitterFinger release];
    [upperPress release];
    [twitterPress release];
    [eventsPress release];
    [routesPress release];
    [downPress release];
    [super dealloc];
}
@end
