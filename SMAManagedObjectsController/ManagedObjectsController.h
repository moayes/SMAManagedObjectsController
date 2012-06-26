//
//  ManagedObjectsController.h
//  SMAManagedObjectsController
//
//  Created by Soheil Azarpour on 6/26/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ARCHelper.h"


typedef enum {
    ManagedObjectsChangeInsert,
    ManagedObjectsChangeDelete,
    ManagedObjectsChangeUpdate,
    ManagedObjectsChangeMove
} ManagedObjectsChange;


@protocol ManagedObjectsControllerDelegate;


@interface SMAManagedObjectsController : NSObject

// Delegate notifies objects, rows, sections that are deleted, inserted, updated
@property (ah_weak, nonatomic) id <ManagedObjectsControllerDelegate> delegate;

// Returns an array of all objects fetched, either through relationship or in the NSManagedObjectContext
@property (readonly, nonatomic) NSArray *allObjects;

// Returns a dictionary. Keys are the object defined by the keyPaht in init-method.
// Object for each key is an array of NSManagedObjects represent a section in UITableView
// If sectionKeyPath is set to nil, only one section will be returned with all objects in an array
@property (readonly, nonatomic) NSDictionary *objectsDictionary;

// Returns an array of objects as section names (instances of NSString, NSDate)
@property (readonly, nonatomic) NSArray *sectionsName;

// Returns number of sections
// Call this in UITableView -numberOfSections
@property (readonly, nonatomic) NSInteger numberOfSections;


- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
                       entityNamed:(NSString *)name
                       descriptors:(NSArray *)descriptors
                    sectionKeyPath:(NSString *)sectionKeyPath;

- (id)initWithManagedObject:(NSManagedObject *)managedObject
                entityNamed:(NSString *)name 
        relationshipKeyPath:(NSString *)relationshipKeyPath
 inverseRelationshipKeyPath:(NSString *)inverseRelationshipKeyPath
                descriptors:(NSArray *)descriptors
             sectionKeyPath:(NSString *)sectionKeyPath;

// Saving methods

- (void)saveContext;

// Inserting methods

- (id)newObject;

// Deleting methods

- (void)deleteObject:(NSManagedObject *)object;
- (void)deleteObjects:(NSArray *)objects;
- (void)deleteObjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)deleteObjectAtIndexPaths:(NSArray *)indexPaths;

// Retrieving methods

- (NSArray *)objectsInSection:(NSInteger)section;
- (NSInteger)numberOfObjectsInSection:(NSInteger)section;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathOfObject:(NSManagedObject *)object;

- (NSString *)titleForSection:(NSInteger)section;




// Moving methods

- (void)moveObject:(id)object fromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end


@protocol ManagedObjectsControllerDelegate <NSObject>

- (void)controllerWillChangeContent:(SMAManagedObjectsController *)controller;

- (void)controller:(SMAManagedObjectsController *)controller didChangeObject:(id)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(ManagedObjectsChange)type newIndexPath:(NSIndexPath *)newIndexPath;

- (void)controller:(SMAManagedObjectsController *)controller didChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(ManagedObjectsChange)type;

- (void)controllerDidChangeContent:(SMAManagedObjectsController *)controller;

@end