//
//  PathViewController.m
//  Path
//
//  Created by Art on 24.08.2014.
//  Copyright (c) 2014 Path. All rights reserved.
//

#import "PathViewController.h"
#import "AOShortestPath.h"

@interface PathViewController ()

@property (strong, nonatomic) AOShortestPath *pathManager;
@property (strong, nonatomic) NSArray *plane;

@property (strong, nonatomic) UIButton *startField;
@property (strong, nonatomic) UIButton *targetField;

@property (strong, nonatomic) UIImageView *person;

@property (assign, nonatomic) BOOL search;

@end

@implementation PathViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _pathManager = [[AOShortestPath alloc] init];
    _pathManager.pointList = [NSMutableArray array];
    
    // create visual structure of plane
    _plane = @[
        @[@1,@0,@1,@1,@1,@1,@1],
        @[@1,@1,@1,@0,@0,@0,@1],
        @[@1,@0,@1,@0,@1,@0,@1],
        @[@1,@0,@0,@0,@1,@0,@1],
        @[@1,@0,@1,@0,@1,@1,@1],
        @[@1,@0,@1,@0,@0,@1,@1],
        @[@1,@0,@1,@0,@1,@1,@1],
        @[@1,@0,@1,@0,@1,@1,@1],
        @[@1,@0,@1,@1,@1,@1,@1]
    ];
    
    // set default field size
    CGFloat size = self.view.frame.size.width/[_plane[0] count];
    
    // generate plans's fields
    for (int i = 0; i<_plane.count; i++) {
        NSArray *row = _plane[i];
        for (int j=0; j<row.count; j++) {
            UIButton *l = [[UIButton alloc] initWithFrame:CGRectMake(j*size, i*size+50, size, size)];
            l.tag = i*10 + j + 1;
            l.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
            l.layer.borderColor = [UIColor whiteColor].CGColor;
            l.layer.borderWidth = 1;
            NSNumber *num = _plane[i][j];
            if ([num integerValue] == 0) {
                [l setTitle:@"X" forState:UIControlStateNormal];
                l.backgroundColor = [UIColor blackColor];
            } else {
                [l setTitle:[NSString stringWithFormat:@"%d%d", i, j] forState:UIControlStateNormal];
            }
            if (l.tag == 76) {
                l.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
            }
            [l addTarget:self action:@selector(actionField:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:l];
            
            // add path path point
            AOPathPoint *p = [[AOPathPoint alloc] initWithTag:l.tag];
            [_pathManager.pointList addObject:p];
        }
    }
    
    // create path connections
    for (int i = 0; i<_pathManager.pointList.count; i++) {
        AOPathPoint *p = _pathManager.pointList[i];
        NSArray *connectionList = [self getConnectionListForTag:p.tag];
        [connectionList enumerateObjectsUsingBlock:^(UIButton *b, NSUInteger idx, BOOL *stop) {
            AOPathConnection *c = [[AOPathConnection alloc] init];
            if (p.tag == 76) {
                // its very hard to get on this field
                c.weight = 10;
            }
            c.point = [_pathManager getPathPointWithTag:b.tag];
            [p addConnection:c];
        }];
    }
    
    _startField = (UIButton*)[self.view viewWithTag:1];
    _startField.backgroundColor = [UIColor greenColor];
    
    _person = [[UIImageView alloc] initWithFrame:_startField.frame];
    _person.contentMode = UIViewContentModeScaleAspectFit;
    _person.image = [UIImage imageNamed:@"person.png"];
    [self.view addSubview:_person];
}

- (void)actionField:(UIButton*)sender {
    if (!_search) {
        _search = YES;
        sender.backgroundColor = [UIColor greenColor];
        _targetField = sender;
        
        AOPathPoint *startPoint = [_pathManager getPathPointWithTag:_startField.tag];
        AOPathPoint *endPoint = [_pathManager getPathPointWithTag:_targetField.tag];
        NSArray *path = [_pathManager getShortestPathFromPoint:startPoint toPoint:endPoint];
        if (path.count) {
            NSMutableArray *buttonPath = [NSMutableArray array];
            for (AOPathPoint *p in path) {
                UIButton *but = (UIButton*)[self.view viewWithTag:p.tag];
                but.backgroundColor = [UIColor redColor];
                [buttonPath addObject:but];
            }
            [self animate:buttonPath withCompletion:^{
                for (UIButton *b in self.view.subviews) {
                    if ([b isKindOfClass:[UIButton class]]) {
                        if ([b.currentTitle isEqualToString:@"X"]) {
                            b.backgroundColor = [UIColor blackColor];
                        } else if (b.tag == 76) {
                            b.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
                        } else {
                            b.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
                        }
                    }
                }
                _search = NO;
                _startField = _targetField;
                _startField.backgroundColor = [UIColor greenColor];
            }];
        } else {
            _search = NO;
        }
    }
}

- (void)animate:(NSArray*)path withCompletion:(void(^)())completion {
    NSMutableArray *animatePoints = [NSMutableArray array];
    for (UIButton *field in path) {
        void (^p)(void) = ^{
            _person.center = field.center;
        };
        [animatePoints addObject:p];
    }
    
    float duration = 0.1;
    long numberOfKeyframes = path.count;
    [UIView animateKeyframesWithDuration:duration*numberOfKeyframes delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
        for (long i=0; i<numberOfKeyframes; i++) {
            [UIView addKeyframeWithRelativeStartTime:duration*i relativeDuration:duration animations:animatePoints[i]];
        }
    } completion:^(BOOL finished) {
        completion();
    }];
}

// we need this method to easily generate connections for basic 2d game plane
- (NSArray*)getConnectionListForTag:(long)tag {
    int row = tag/10;
    int col = tag-row*10;
    
    NSString *titleX = @"X";
    
    NSMutableArray *cons = [NSMutableArray array];
    if (col-1 > 0) {
        UIButton *but = (UIButton*)[self.view viewWithTag:(row*10+col-1)];
        if (![but.currentTitle isEqualToString:titleX]) {
            [cons addObject:but];
        }
    }
    if (col+1 < [_plane[0] count]+1) {
        UIButton *but = (UIButton*)[self.view viewWithTag:(row*10+col+1)];
        if (![but.currentTitle isEqualToString:titleX]) {
            [cons addObject:but];
        }
    }
    if (row-1 >= 0) {
        UIButton *but = (UIButton*)[self.view viewWithTag:((row-1)*10+col)];
        if (![but.currentTitle isEqualToString:titleX]) {
            [cons addObject:but];
        }
    }
    if (row+1 < [_plane count]) {
        UIButton *but = (UIButton*)[self.view viewWithTag:((row+1)*10+col)];
        if (![but.currentTitle isEqualToString:titleX]) {
            [cons addObject:but];
        }
    }
    
    return cons;
}

@end
