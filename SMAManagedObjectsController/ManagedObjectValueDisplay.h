//
//  ManagedObjectValueDisplay.h
//  SMAManagedObjectsController
//
//  Created by Soheil Azarpour on 6/26/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//


#import <Foundation/Foundation.h>


@protocol SMAManagedObjectValueDisplay
- (NSString *)managedObjectValueDisplay;
@end


@interface NSString (ManagedObjectValueDisplay) <SMAManagedObjectValueDisplay>
- (NSString *)managedObjectValueDisplay;
@end


@interface NSDate (ManagedObjectValueDisplay) <SMAManagedObjectValueDisplay>
- (NSString *)managedObjectValueDisplay;
@end


@interface NSNumber (ManagedObjectValueDisplay) <SMAManagedObjectValueDisplay>
- (NSString *)managedObjectValueDisplay;
@end


@interface NSDecimalNumber (ManagedObjectValueDisplay) <SMAManagedObjectValueDisplay>
- (NSString *)managedObjectValueDisplay;
@end
