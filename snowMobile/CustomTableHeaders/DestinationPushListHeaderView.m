//
//  DestinationPushListHeaderView.m
//  snow
//
//  Created by Oleksii Vynogradov on 30.04.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "DestinationPushListHeaderView.h"

#import <QuartzCore/QuartzCore.h>

@implementation DestinationPushListHeaderView

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
          delegate:(id <DestinationPushListHeaderViewDelegate>)aDelegate
isDestinationsPushList:(BOOL)isDestinationsPushListEntity
           testing:(NSUInteger)testingFlow; 

{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        // testing flow:
        // 0 - no tests
        // 1 - processed
        // 3 - result failed no success calls
        // 4 - result faile FAS
        // >> 4 - result success, mean ASR 

        // Set up the tap gesture recognizer.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
        [self addGestureRecognizer:tapGesture];
        [tapGesture release];
        objectID = objectIDexternal;
        
        delegate = aDelegate;        
        //object = anObject;
        self.userInteractionEnabled = YES;
        
        
        // Create and configure the title label.
        section = sectionNumber;
        CGRect titleLabelFrame = self.bounds;
        titleLabelFrame.origin.x += 35.0;
        titleLabelFrame.origin.y -= 10.0;
        
        titleLabelFrame.size.width -= 35.0;
        CGRectInset(titleLabelFrame, 0.0, 5.0);
        country = [[UILabel alloc] initWithFrame:titleLabelFrame];
        country.text = countryForHeader;
        country.font = [UIFont systemFontOfSize:15.0];
        country.textColor = [UIColor whiteColor];
        country.backgroundColor = [UIColor clearColor];
        country.shadowColor = [UIColor blackColor];
        country.shadowOffset = CGSizeMake(1, 1);
        
        [self addSubview:country];
        
        //titleLabelFrame.origin.x += 35.0;
        titleLabelFrame.origin.y += 20.0;
        
        specific = [[UILabel alloc] initWithFrame:titleLabelFrame];
        specific.text = specificForHeader;
        specific.font = [UIFont systemFontOfSize:11.0];
        specific.textColor = [UIColor whiteColor];
        specific.backgroundColor = [UIColor clearColor];
        specific.shadowColor = [UIColor blackColor];
        specific.shadowOffset = CGSizeMake(1, 1);


        [self addSubview:specific];

        titleLabelFrame.origin.x += 170.0;
        //titleLabelFrame.origin.y -= 10.0;
        
        rate = [[UILabel alloc] initWithFrame:titleLabelFrame];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:5];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setCurrencySymbol:@"$"];
        rate.text = [formatter stringFromNumber:price];
        rate.font = [UIFont systemFontOfSize:20.0];
        rate.textColor = [UIColor whiteColor];
        rate.backgroundColor = [UIColor clearColor];
        rate.shadowColor = [UIColor blackColor];
        rate.shadowOffset = CGSizeMake(2, 2);
        [self addSubview:rate];
        
        if (!isDestinationsPushListEntity) {
            titleLabelFrame.origin.x -= 40.0;
            titleLabelFrame.origin.y -= 20.0;
            
            if (acd.doubleValue != 0) {
                lastUsedACD = [[UILabel alloc] initWithFrame:titleLabelFrame];
                [formatter setMaximumFractionDigits:1];
                [formatter setNumberStyle:NSNumberFormatterNoStyle];
                lastUsedACD.text = [NSString stringWithFormat:@"ACD:%@",[formatter stringFromNumber:acd]];
                lastUsedACD.font = [UIFont systemFontOfSize:13.0];
                lastUsedACD.textColor = [UIColor whiteColor];
                lastUsedACD.backgroundColor = [UIColor clearColor];
                lastUsedACD.shadowColor = [UIColor blackColor];
                lastUsedACD.shadowOffset = CGSizeMake(2, 2);
                [self addSubview:lastUsedACD];
            }
            titleLabelFrame.origin.x += 60.0;
            //        titleLabelFrame.origin.y -= 10.0;
            
            if (minutes.doubleValue != 0) {

            lastUsedMinutesLenght = [[UILabel alloc] initWithFrame:titleLabelFrame];
            
            [formatter setMaximumFractionDigits:0];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            lastUsedMinutesLenght.text = [NSString stringWithFormat:@"Minutes:%@",[formatter stringFromNumber:minutes]];        
            lastUsedMinutesLenght.font = [UIFont systemFontOfSize:13.0];
            lastUsedMinutesLenght.textColor = [UIColor whiteColor];
            lastUsedMinutesLenght.backgroundColor = [UIColor clearColor];
            lastUsedMinutesLenght.shadowColor = [UIColor blackColor];
            lastUsedMinutesLenght.shadowOffset = CGSizeMake(2, 2);
            [self addSubview:lastUsedMinutesLenght];
            }
        }
        [formatter release], formatter = nil;
        self.testingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        testingButton.frame = CGRectMake(100.0, 100.0, 45.0, 45.0);
        [disclosureButton setImage:[UIImage imageNamed:@"carat.png"] forState:UIControlStateNormal];
        [disclosureButton setImage:[UIImage imageNamed:@"carat-open.png"] forState:UIControlStateSelected];
        [disclosureButton addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];

        
        self.disclosureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        disclosureButton.frame = CGRectMake(0.0, 8.0, 45.0, 45.0);
        [disclosureButton setImage:[UIImage imageNamed:@"carat.png"] forState:UIControlStateNormal];
        [disclosureButton setImage:[UIImage imageNamed:@"carat-open.png"] forState:UIControlStateSelected];
        [disclosureButton addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];
        disclosureButton.selected = isOpenedForHeader;
        isOpened = isOpenedForHeader;
        //disclosureButton.selected = [object.opened boolValue];
        [self addSubview:disclosureButton];
        
        // Set the colors for the gradient layer.
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
        [(CAGradientLayer *)self.layer setColors:colors];
        [(CAGradientLayer *)self.layer setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.91], [NSNumber numberWithFloat:1.0], nil]];

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


@end
