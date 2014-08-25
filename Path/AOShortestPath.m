//
//  AOShortPath.m
//  Path
//
//  Created by Art on 25.08.2014.
//  Copyright (c) 2014 Path. All rights reserved.
//

#import "AOShortestPath.h"

@implementation AOPathPoint
- (id)initWithTag:(long)tag {
    _tag = tag;
    if (!self) {
        return [self init];
    }
    return self;
}
- (void)addConnection:(AOPathConnection *)connection {
    if (!_connectionList) {
        _connectionList = [NSMutableArray array];
    }
    [_connectionList addObject:connection];
}
- (AOPathConnection*)getConnectionToPointWithTag:(long)tag {
    __block AOPathConnection *c;
    [self.connectionList enumerateObjectsUsingBlock:^(AOPathConnection *connection, NSUInteger idx, BOOL *stop) {
        if (connection.point.tag == tag) {
            c = connection;
        }
    }];
    return c;
}
@end

@implementation AOPathConnection
- (id)init {
    _weight = 1;
    if (!self) {
        return [self init];
    }
    return self;
}
@end

@interface AOShortestPath ()
@property (strong, nonatomic) AOPathPoint *targetPoint;
@end

@implementation AOShortestPath

- (NSArray*)getShortestPathFromPoint:(AOPathPoint*)fromPoint toPoint:(AOPathPoint*)toPoint {
    _targetPoint = toPoint;
    return [self getPathForPoint:fromPoint withPath:[NSMutableArray arrayWithObject:fromPoint]];
}

- (NSMutableArray*)getPathForPoint:(AOPathPoint*)point withPath:(NSMutableArray*)path {
    
    NSMutableArray *paths = [NSMutableArray array];
    if (point == _targetPoint) {
        [path addObject:_targetPoint];
        [paths addObject:path];
    } else {
        NSArray *connections = point.connectionList;
        for (int i=0; i<connections.count; i++) {
            AOPathConnection *connection = connections[i];
            if (![path containsObject:connection.point] && connection.weight != 0) {
                NSMutableArray *newPath = [path mutableCopy];
                [newPath addObject:connection.point];
                NSMutableArray *shortestPath = [self getPathForPoint:connection.point withPath:newPath];
                if (shortestPath.count > 0) {
                    [paths addObject:shortestPath];
                }
            }
        }
    }
    long smallestWeight = 0;
    NSMutableArray *smallest = [NSMutableArray array];
    for (int i=0; i<paths.count; i++) {
        NSMutableArray *path = paths[i];
        
        long weight = 0;
        for (int j=0; j<path.count-1; j++) {
            AOPathPoint *pointFrom = path[j];
            AOPathPoint *pointTo = path[j+1];
            weight += [[pointFrom getConnectionToPointWithTag:pointTo.tag] weight];
        }
        
        if (weight < smallestWeight || smallestWeight == 0) {
            smallest = path;
            smallestWeight = weight;
        }
    }
    return smallest;
}

- (AOPathPoint*)getPathPointWithTag:(long)tag {
    __block AOPathPoint *pathPoint;
    [_pointList enumerateObjectsUsingBlock:^(AOPathPoint *p, NSUInteger idx, BOOL *stop) {
        if (p.tag == tag) {
            pathPoint = p;
            *stop = YES;
        }
    }];
    return pathPoint;
}

@end
