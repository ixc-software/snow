//
//  DestinationsHeaderView.m
//  snow
//
//  Created by Oleksii Vynogradov on 3/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "DestinationsHeaderView.h"
#import "mobileAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation DestinationsHeaderView
@synthesize testingProgress;
@synthesize testingResults;
@synthesize testingTitle;
@synthesize view;
@synthesize country,specific,rate,delegate,section,disclosureButton,isOpened,objectID,lastUsedACD,lastUsedMinutesLenght,testingButton;
+ (Class)layerClass {
    
    return [CAGradientLayer class];
}

-(id)initWithFrame:(CGRect)frame 
       withCountry:(NSString *)countryForHeader 
      withSpecific:(NSString *)specificForHeader 
         withPrice:(NSNumber *)price 
       withMinutes:(NSNumber *)minutes 
           withACD:(NSNumber *)acd 
      withObjectID:(NSManagedObjectID *)objectIDexternal 
           section:(NSUInteger)sectionNumber 
          isOpened:(BOOL)isOpenedForHeader
          delegate:(id <DestinationsHeaderViewDelegate>)aDelegate
  isTestingResults:(BOOL)isTestingResults
           testing:(NSUInteger)testingFlow; 
{
    self = [super initWithFrame:frame];
    if (self) {
        // testing flow:
        // 0 - no tests
        // 1 - processed
        // 3 - result failed no success calls
        // 4 - result faile FAS
        // >> 4 - result success, mean ASR 
       
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        static NSMutableArray *colors = nil;
        if (colors == nil) {
            colors = [[NSMutableArray alloc] initWithCapacity:3];
            UIColor *color = nil;
            color = [UIColor colorWithRed:0.82 green:0.84 blue:0.87 alpha:1.0];
            [colors addObject:(id)[color CGColor]];
            color = [UIColor colorWithRed:0.15 green:0.15 blue:0.49 alpha:1.0];
            [colors addObject:(id)[color CGColor]];
            color = [UIColor colorWithRed:0.15 green:0.15 blue:0.49 alpha:1.0];
            [colors addObject:(id)[color CGColor]];
        }
        [gradient setColors:colors];
        [gradient setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.91], [NSNumber numberWithFloat:1.0], nil]];
        [self.layer addSublayer:gradient];

        // Initialization code
        mobileAppDelegate *delegateMain = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
        if ([delegateMain isPad]) [[NSBundle mainBundle] loadNibNamed:@"DestinationsHeaderViewIPad" owner:self options:nil];
        else [[NSBundle mainBundle] loadNibNamed:@"DestinationsHeaderView" owner:self options:nil];       
        [self addSubview:self.view];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
        [self addGestureRecognizer:tapGesture];
        tapGesture.delegate = self;
        [tapGesture release];

        objectID = objectIDexternal;

        delegate = aDelegate;        

        //self.userInteractionEnabled = YES;
        section = sectionNumber;
        country.text = countryForHeader;
        specific.text = specificForHeader;
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:5];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setCurrencySymbol:@"$"];
        rate.text = [formatter stringFromNumber:price];
        
        if (acd.doubleValue != 0) {
            lastUsedACD.hidden = NO;
            [formatter setMaximumFractionDigits:1];
            [formatter setNumberStyle:NSNumberFormatterNoStyle];
            lastUsedACD.text = [NSString stringWithFormat:@"ACD:%@",[formatter stringFromNumber:acd]];
            
        } else lastUsedACD.hidden = YES;
        
        if (minutes.doubleValue != 0) {
            lastUsedMinutesLenght.hidden = NO;
            
            [formatter setMaximumFractionDigits:0];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            lastUsedMinutesLenght.text = [NSString stringWithFormat:@"Minutes:%@",[formatter stringFromNumber:minutes]];        
        } else lastUsedMinutesLenght.hidden = YES;
        
        [formatter release], formatter = nil;
        
        if (!isTestingResults) {
            testingResults.hidden = YES;
            testingButton.hidden = YES;
            testingTitle.hidden = YES;
            
            rate.frame = CGRectMake(rate.frame.origin.x + 75, rate.frame.origin.y, rate.frame.size.width, rate.frame.size.height);
            lastUsedMinutesLenght.frame = CGRectMake(lastUsedMinutesLenght.frame.origin.x + 75, lastUsedMinutesLenght.frame.origin.y, lastUsedMinutesLenght.frame.size.width, lastUsedMinutesLenght.frame.size.height);
            lastUsedACD.frame = CGRectMake(lastUsedACD.frame.origin.x + 75, lastUsedACD.frame.origin.y, lastUsedACD.frame.size.width, lastUsedACD.frame.size.height);
        }    

        
        [disclosureButton addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];
        disclosureButton.selected = isOpenedForHeader;
        isOpened = isOpenedForHeader;

        [testingButton addTarget:self action:@selector(testResultViewOpen:) forControlEvents:UIControlEventTouchUpInside];

        testingProgress.hidden = YES;
        
        if (testingFlow == 1) {
            testingTitle.text = @"Testing processing...";
            testingProgress.hidden = NO;
            [testingProgress startAnimating];
        } else {
            testingTitle.text = @"Testing results.";
        }
        
    }
    return self;
}

-(IBAction)toggleOpen:(id)sender {
    [self toggleOpenWithUserAction:YES];
}


-(void)toggleOpenWithUserAction:(BOOL)userAction;
{
    //NSLog(@">>>  state was :%@",[NSNumber numberWithBool:isOpened]);
    
    self.isOpened = !self.isOpened;
    self.disclosureButton.selected = isOpened;
    if (isOpened) {
        if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
            [delegate sectionHeaderView:self 
                          sectionOpened:section];
        }
    } else {
        if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
            
            [delegate sectionHeaderView:self 
                          sectionClosed:section];
        }
    }
    
}
- (IBAction)testResultViewOpen:(id)sender {
    if ([delegate respondsToSelector:@selector(sectionHeaderView:openTestingResults:)]) {
        [delegate sectionHeaderView:self 
                openTestingResults:section];
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // test if our control subview is on-screen
    NSLog(@"start checking..");
    if (self.superview != nil) {
        NSLog(@"superview not nil..");

        if ([touch.view isDescendantOfView:testingButton] && testingButton.hidden != YES) {
            // we touched our control surface
            NSLog(@"ignore the touch");

            return NO; // ignore the touch
        }
    }
    return YES; // handle the touch
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void) awakeFromNib
{
    [super awakeFromNib];
    
    mobileAppDelegate *delegateMain = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([delegateMain isPad]) [[NSBundle mainBundle] loadNibNamed:@"DestinationsHeaderViewIPad" owner:self options:nil];
    else [[NSBundle mainBundle] loadNibNamed:@"DestinationsHeaderView" owner:self options:nil];       
    [self addSubview:self.view];
}

- (void)dealloc {
    [view release];

    [testingResults release];
    [testingTitle release];
    [testingProgress release];
    [super dealloc];
}
@end
