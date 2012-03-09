//
//  CountrySpecificCodeList.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "CountrySpecificCodeList.h"
#import "CodesList.h"
#import "MainSystem.h"

#import "NormalizedCountryTransformer.h"
#import "NormalizedSpecificTransformer.h"
#import "NormalizedCodesTransformer.h"


@implementation CountrySpecificCodeList

@dynamic codes;
@dynamic codesNormalized;
@dynamic country;
@dynamic countryNormalized;
@dynamic creationDate;
@dynamic GUID;
@dynamic modificationDate;
@dynamic opened;
@dynamic rowHeight;
@dynamic specific;
@dynamic specificNormalized;
@dynamic codesList;
@dynamic mainSystem;
- (void)awakeFromInsert {
    NSDate *now = [NSDate date];
    
    [self willChangeValueForKey:@"GUID"];
    [self setPrimitiveValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:@"GUID"];
    [self didChangeValueForKey:@"GUID"];
    
    [self willChangeValueForKey:@"creationDate"];
    [self setPrimitiveValue:now forKey:@"creationDate"];
    [self didChangeValueForKey:@"creationDate"];
    
    [self willChangeValueForKey:@"modificationDate"];
    [self setPrimitiveValue:now forKey:@"modificationDate"];
    [self didChangeValueForKey:@"modificationDate"];
}

-(void)willSave {
    NSDate *now = [NSDate date];
    if ([self isUpdated]) {
        
        
        if (self.modificationDate == nil || [now timeIntervalSinceDate:self.modificationDate] > 1.0) {
            self.modificationDate = now;
        }
    }
}

- (void)setCodes:(NSString *)codes {
    
    [self willChangeValueForKey:@"codes"];
    [self setPrimitiveValue:codes forKey:@"codes"];
    
    // normalize the text and store it the 'normalizedText' derived property
    
    [self setCodesNormalized:[NormalizedCodesTransformer normalizeString:codes]];
    
    [self didChangeValueForKey:@"codes"];
}


- (void)setSpecific:(NSString *)specific {
    
    [self willChangeValueForKey:@"specific"];
    
    [self setPrimitiveValue:specific forKey:@"specific"];
    
    // normalize the text and store it the 'normalizedText' derived property
    
    [self setSpecificNormalized:[NormalizedSpecificTransformer normalizeString:specific]];
    
    [self didChangeValueForKey:@"specific"];
}



- (void)setCountry:(NSString *)country {
    
    [self willChangeValueForKey:@"country"];
    //[self setPrimitiveСountry:country];
    [self setPrimitiveValue:country forKey:@"country"];
    
    // normalize the text and store it the 'normalizedText' derived property
    
    [self setCountryNormalized:[NormalizedCountryTransformer normalizeString:country]];
    
    [self didChangeValueForKey:@"country"];
}



@end
