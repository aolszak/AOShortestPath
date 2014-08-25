//
//  AOShortPath.h
//  Path
//
//  Created by Art on 25.08.2014.
//  Copyright (c) 2014 Path. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AOPathPoint : NSObject
@property (assign, nonatomic) NSUInteger tag;
@end

@interface AOPathConnection : NSObject
@property (strong, nonatomic) AOPathPoint *pointA;
@property (strong, nonatomic) AOPathPoint *pointB;
@property (assign, nonatomic) CGFloat weight;
@end

@interface AOShortestPath : NSObject

@property (strong, nonatomic) NSArray *connectionList;

- (NSArray*)getShortestPathFromPoint:(AOPathPoint*)fromPoint toPoint:(AOPathPoint*)toPoint;

@end