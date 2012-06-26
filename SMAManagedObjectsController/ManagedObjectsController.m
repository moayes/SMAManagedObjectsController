//
//  ManagedObjectsController.m
//  SMAManagedObjectsController
//
//  Created by Soheil Azarpour on 6/26/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//


#import "ManagedObjectsController.h"
#import "ManagedObjectValueDisplay.h"


#define DUMMY_SECTION_NAME @"Section"


@interface SMAManagedObjectsController ()
@property (ah_retain, nonatomic)    NSManagedObjectContext * managedObjectContext;
@property (ah_retain, nonatomic)    NSManagedObject        * managedObject;
@property (ah_retain, nonatomic)    NSString               * entityName;
@property (readwrite, nonatomic)    NSArray                * allObjects;
@property (readwrite, nonatomic)    NSDictionary           * objectsDictionary;
@property (ah_retain, nonatomic)    NSString               * relationshipKeyPath;
@property (ah_retain, nonatomic)    NSString               * inverseRelationshipKeyPath;
@property (ah_retain, nonatomic)    NSString               * sectionKeyPath;
@end


@implementation SMAManagedObjectsController

// @synthsize public properties
@synthesize delegate = _delegate;
@synthesize allObjects = _allObjects;
@synthesize objectsDictionary = _objectsDictionary;
@synthesize sectionsName = _sectionsName;
@synthesize numberOfSections = _numberOfSections;


// @synthesize private properties
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObject = _managedObject;
@synthesize entityName = _entityName;
@synthesize relationshipKeyPath = _relationshipKeyPath;
@synthesize inverseRelationshipKeyPath = _inverseRelationshipKeyPath;
@synthesize sectionKeyPath = _sectionKeyPath;


#pragma mark - 
#pragma mark - Initialization

// Initialization with NSManagedObjectContext
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context 
                       entityNamed:(NSString *)name 
                       descriptors:(NSArray *)descriptors 
                    sectionKeyPath:(NSString *)sectionKeyPath {
    
    if (self = [super init]) {
        
        self.managedObjectContext = context;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:name];
        request.sortDescriptors = descriptors;
        
        NSError *error;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (error) {
            NSLog(@"Unresolved error fetching objects: %@", error.userInfo);
        }
        
        self.allObjects = results;
        self.sectionKeyPath = sectionKeyPath;
        self.entityName = name;
        
        self.objectsDictionary = [self dictionaryFromArray:self.allObjects keyPath:self.sectionKeyPath];
        
        request = nil;
        [request release];
        
        error = nil;
        results = nil;
    }
    return self;
}


// Initialization with relationship of a NSManagedObject
- (id)initWithManagedObject:(NSManagedObject *)managedObject
                entityNamed:(NSString *)name 
        relationshipKeyPath:(NSString *)relationshipKeyPath 
 inverseRelationshipKeyPath:(NSString *)inverseRelationshipKeyPath 
                descriptors:(NSArray *)descriptors 
             sectionKeyPath:(NSString *)sectionKeyPath {
    
    if (self = [super init]) {
        
        self.managedObjectContext = managedObject.managedObjectContext;
        self.managedObject = managedObject;
        self.relationshipKeyPath = relationshipKeyPath;
        
        NSArray *results = [[[self.managedObject valueForKey:self.relationshipKeyPath] allObjects] sortedArrayUsingDescriptors:descriptors];
        
        self.entityName = name;
        self.inverseRelationshipKeyPath = inverseRelationshipKeyPath;
        self.allObjects = results;
        self.sectionKeyPath = sectionKeyPath; 
        
        self.objectsDictionary = [self dictionaryFromArray:self.allObjects keyPath:self.sectionKeyPath];
        
        results = nil;
    }
    return self;
}


#pragma mark -
#pragma mark - Private methods


- (NSDictionary *)dictionaryFromArray:(NSArray *)inputArray keyPath:(NSString *)keyPath {
    
    // Create an empty mutable dictionary
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    // If keyPath is nil, we'll return a dictionary that has only one section
    // i.e. a dummy section title, and an array of all objects
    
    if (!keyPath) {
        
        [dictionary setObject:inputArray forKey:DUMMY_SECTION_NAME];
        
    }
    else {
        
        for (NSManagedObject *anObject in inputArray) {
            
            // Get all the keys
            NSArray *keys = [dictionary allKeys];
            
            // Get the anObject's key
            id objectKey = [anObject valueForKeyPath:keyPath];
            
            // Iterate through keys
            if ([keys containsObject:objectKey]) {
                
                // Get the arrays of objects with this key
                NSMutableArray *keyObjects = [[dictionary objectForKey:objectKey] mutableCopy];
                
                // If anObject is not there (you expect this to be always True)
                // add anObject to the array
                
                if (![keyObjects containsObject:anObject]) {
                    
                    // Add the new object
                    [keyObjects addObject:anObject];
                    
                    // Update the dictionary by removing the old one
                    [dictionary removeObjectForKey:objectKey];
                    
                    // ... and replacing the new one
                    [dictionary setObject:keyObjects forKey:objectKey];
                }
            }
            
            // If keys does not have the anObject's key
            else {
                
                // Create an array with anObject
                NSArray *objectsToAdd = [NSArray arrayWithObject:anObject];
                
                // Add it to the dictionary with its key
                [dictionary setObject:objectsToAdd forKey:objectKey];
            }
        }
    }    
    
    return dictionary;
}


// Returns the key to a section as is
// It doesn't change or modify the object based on NSManagedObjectValueDisplay

- (id)keyForSection:(NSInteger)section {
    
    NSArray *allKeys = self.objectsDictionary.allKeys;
    
    if (!allKeys || allKeys.count == 0 || section > allKeys.count)
        return nil;
    
    id key = [allKeys objectAtIndex:section];
    return key;
}


#pragma mark -
#pragma mark - Public methods


// Saving methods

- (void)saveContext {
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error saving: %@", error.userInfo);
    }
    error = nil;
}


// Inserting methods

- (id)newObject {
    
    // Create a new object
    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    
    // If there is a relationship, set that up
    if (self.managedObject) {
        [newObject setValue:self.managedObject forKeyPath:self.inverseRelationshipKeyPath];
    }
    
    // Update the array of all objects
    NSMutableArray *array = [self.allObjects mutableCopy];
    [array addObject:newObject];
    self.allObjects = [array copy];
    array = nil;
    
    // Update the dictionary
    self.objectsDictionary = [self dictionaryFromArray:self.allObjects keyPath:self.sectionKeyPath];
    
    // Notify the delegate to update UI
    NSIndexPath *newObjectIndexPath = [self indexPathOfObject:newObject];
    NSInteger numberOfSections = [self numberOfSections];
    NSInteger numberOfObjectsInSection = [self numberOfObjectsInSection:newObjectIndexPath.section];
    
    if (numberOfObjectsInSection == 1 && numberOfSections == 1) {
        
        // Notify of change in section
        [self.delegate controller:self didChangeSectionAtIndex:newObjectIndexPath.section forChangeType:ManagedObjectsChangeInsert];
    }
    else {
        
        // Notify the delegae of the update
        [self.delegate controllerWillChangeContent:self];
        
        // Notify of change in object
        [self.delegate controller:self didChangeObject:newObject atIndexPath:newObjectIndexPath forChangeType:ManagedObjectsChangeInsert newIndexPath:nil];
        
        // Finish the update
        [self.delegate controllerDidChangeContent:self];
    }
    
    return newObject;
}


// Deleting methods

- (void)deleteObject:(NSManagedObject *)object {
    
    NSIndexPath *indexPathToDelete = [self indexPathOfObject:object];
    NSInteger numberOfSections = [self numberOfSections];
    NSInteger numberOfObjectsInSection = [self numberOfObjectsInSection:indexPathToDelete.section];
    
    // If self.managedObject != nil,
    // that means we have a relationship
    
    if (self.managedObject) {
        
        [self.managedObject setValue:nil forKeyPath:self.relationshipKeyPath];
    }
    
    [self.managedObjectContext deleteObject:object];
    
    // Update the array of all objects
    NSMutableArray *array = [self.allObjects mutableCopy];
    [array removeObject:object];
    self.allObjects = [array copy];
    array = nil;
    
    // Update the dictionary
    self.objectsDictionary = [self dictionaryFromArray:self.allObjects keyPath:self.sectionKeyPath];
    
    // Notify the delegate to update UI
    if (numberOfObjectsInSection == 1 && numberOfSections == 1) {
        
        // Notify of change in section
        [self.delegate controller:self didChangeSectionAtIndex:indexPathToDelete.section forChangeType:ManagedObjectsChangeDelete];
    }
    else {
        
        // Notify the delegae of the update
        [self.delegate controllerWillChangeContent:self];
        
        // Notify of change in object
        [self.delegate controller:self didChangeObject:object atIndexPath:indexPathToDelete forChangeType:ManagedObjectsChangeDelete newIndexPath:nil];
        
        // Finish the update
        [self.delegate controllerDidChangeContent:self];
    }
}

- (void)deleteObjects:(NSArray *)objects {
    for (NSManagedObject *anObject in objects) {
        [self deleteObject:anObject];
    }
}


- (void)deleteObjectAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectAtIndexPath:indexPath];
    [self deleteObject:object];
}


- (void)deleteObjectAtIndexPaths:(NSArray *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        id object = [self objectAtIndexPath:indexPath];
        [self deleteObject:object];
    }
}


// Retrieving methods

- (NSInteger)numberOfSections {
    _numberOfSections = self.objectsDictionary.count;
    if (_numberOfSections < 1)
        _numberOfSections = 1;
    return _numberOfSections;
}

// Returns a NSArray of all section names, a.k.a all keys of objectsDictionary
// objectes are modified based on ManagedObjectValueDisplay before being passed on

- (NSArray *)sectionsName {
    
    NSArray *allKeys = self.objectsDictionary.allKeys;
    NSMutableArray *adjusted_keys = [NSMutableArray array];
    for (id key in allKeys) {
        [adjusted_keys addObject:[key managedObjectValueDisplay]];
    }
    _sectionsName = nil;
    _sectionsName = [adjusted_keys copy];
    
    allKeys = nil;
    adjusted_keys = nil;
    
    return _sectionsName;
}

// Returns all the object in a given section

- (NSArray *)objectsInSection:(NSInteger)section {
    
    id key = [self keyForSection:section];
    return [self.objectsDictionary objectForKey:key];
}


- (NSInteger)numberOfObjectsInSection:(NSInteger)section {
    NSArray *objects = [self objectsInSection:section];
    return objects.count;
}


// Returns an object at the given indexPath

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *objectsInSection = [self objectsInSection:indexPath.section];
    return [objectsInSection objectAtIndex:indexPath.row];
}


- (NSIndexPath *)indexPathOfObject:(NSManagedObject *)object {
    
    NSIndexPath *indexPah;
    NSInteger section = 0;
    NSInteger row;
    
    if (self.sectionKeyPath) {
        
        NSArray *allKeys = self.objectsDictionary.allKeys;
        id objectKey = [object valueForKeyPath:self.sectionKeyPath];
        
        for (id key in allKeys) {
            if ([key isEqual:objectKey]) {
                
                section = [allKeys indexOfObject:key];
                row = [[self objectsInSection:section] indexOfObject:object];
                indexPah = [NSIndexPath indexPathForRow:row inSection:section];
                break;
            }
        }
    }
    else {
        
        row = [[self.objectsDictionary objectForKey:DUMMY_SECTION_NAME] indexOfObject:object];
        indexPah = [NSIndexPath indexPathForRow:row inSection:section];
    }
    
    return indexPah;
}


- (NSString *)titleForSection:(NSInteger)section {
    id key = [self keyForSection:section];
    return [key managedObjectValueDisplay];
}


// Moving methods

- (void)moveObject:(id)object fromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    [self.delegate controllerWillChangeContent:self];
    
    id newKey;
    if (fromIndexPath.section != toIndexPath.section) {
        newKey = [self keyForSection:toIndexPath.section];
    }
    
    if (newKey) {
        [object setValue:newKey forKeyPath:self.sectionKeyPath];
    }
    
    self.objectsDictionary = [self dictionaryFromArray:self.allObjects keyPath:self.sectionKeyPath];
    [self.delegate controller:self didChangeObject:object atIndexPath:fromIndexPath forChangeType:ManagedObjectsChangeMove newIndexPath:toIndexPath];
    
    [self.delegate controllerDidChangeContent:self];
}

@end
