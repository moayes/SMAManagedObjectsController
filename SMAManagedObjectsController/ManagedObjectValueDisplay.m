//
//  ManagedObjectValueDisplay.m
//  SMAManagedObjectsController
//
//  Created by Soheil Azarpour on 6/26/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//


#import "ManagedObjectValueDisplay.h"


@implementation NSString (SMAManagedObjectValueDisplay)
- (NSString *)managedObjectValueDisplay {
	return self;
}
@end


@implementation NSDate (SMAManagedObjectValueDisplay)
- (NSString *)managedObjectValueDisplay {
    
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	NSString *ret = [formatter stringFromDate:self];
    formatter = nil;
    
	return ret;
}
@end


@implementation NSNumber (SMAManagedObjectValueDisplay) 
- (NSString *)managedObjectValueDisplay {
    
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    formatter.minimumIntegerDigits = 1;
    formatter.maximumFractionDigits = 2;
    formatter.minimumFractionDigits = 2;
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    NSString *ret = [formatter stringFromNumber:self];
    formatter = nil;
    
    return ret;
}
@end


@implementation NSDecimalNumber (SMAManagedObjectValueDisplay) 
- (NSString *)managedObjectValueDisplay {
    return [self descriptionWithLocale:[NSLocale currentLocale]];
}
@end

