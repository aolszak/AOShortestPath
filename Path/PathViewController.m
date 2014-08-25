//
//  PathViewController.m
//  Path
//
//  Created by Art on 24.08.2014.
//  Copyright (c) 2014 Path. All rights reserved.
//

#import "PathViewController.h"

@interface PathViewController ()

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
	// Do any additional setup after loading the view, typically from a nib.
    
    _plane = @[
        @[@1,@0,@1,@0,@1,@1],
        @[@1,@1,@1,@0,@1,@1],
        @[@1,@0,@1,@0,@1,@1],
        @[@1,@0,@1,@0,@1,@1],
        @[@1,@0,@1,@1,@1,@1],
        @[@1,@0,@1,@1,@1,@1],
        @[@1,@0,@1,@1,@1,@1]
    ];
    
    CGFloat size = self.view.frame.size.width/[_plane[0] count];
    
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
            [l addTarget:self action:@selector(actionField:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:l];
        }
    }
    
    _startField = (UIButton*)[self.view viewWithTag:41];
    _startField.backgroundColor = [UIColor greenColor];
    
    _person = [[UIImageView alloc] initWithFrame:_startField.frame];
    _person.contentMode = UIViewContentModeScaleAspectFit;
    _person.image = [UIImage imageNamed:@"person.png"];
    [self.view addSubview:_person];
}

- (void)actionField:(UIButton*)sender {
    _search = !_search;
    
    if (_search) {
        sender.backgroundColor = [UIColor greenColor];
        _targetField = sender;
        
        NSArray *path = [self getPathForField:_startField withPath:[NSMutableArray array]];
        for (UIButton *but in path) {
            but.backgroundColor = [UIColor redColor];
        }
        [self animate:path];
    } else {
        for (UIButton *b in self.view.subviews) {
            if ([b isKindOfClass:[UIButton class]]) {
                if ([b.currentTitle isEqualToString:@"X"]) {
                    b.backgroundColor = [UIColor blackColor];
                } else {
                    b.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
                }
            }
        }
        _startField = _targetField;
        _startField.backgroundColor = [UIColor greenColor];
    }
}

- (void)animate:(NSArray*)path {
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
        
    }];
}

- (NSMutableArray*)getPathForField:(UIButton*)field withPath:(NSMutableArray*)path {
    
    NSMutableArray *paths = [NSMutableArray array];
    if (field == _targetField) {
        [path addObject:_targetField];
        [paths addObject:path];
    } else {
        NSArray *fields = [self getConnectionsForField:field];
        for (int i=0; i<fields.count; i++) {
            UIButton *field = fields[i];
            if (![path containsObject:field] && field != _startField && ![field.currentTitle isEqualToString:@"X"]) {
                NSMutableArray *pathh = [path mutableCopy];
                [pathh addObject:field];
                //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
                //NSLog(@"go");
                dispatch_async(dispatch_get_main_queue(), ^{
                    //field.backgroundColor = [UIColor redColor];
                });
                NSMutableArray *pathNew = [self getPathForField:field withPath:pathh];
                if (pathNew && pathNew.count > 0) {
                    [paths addObject:pathNew];
                }
            }
        }
    }
    NSMutableArray *smallest = [NSMutableArray array];
    for (int i=0; i<paths.count; i++) {
        NSMutableArray *path = paths[i];
        if (path.count < smallest.count || smallest.count == 0) {
            smallest = path;
        }
    }
    return smallest;
}

- (NSArray*)getConnectionsForField:(UIButton*)field {
    int row = field.tag/10;
    int col = field.tag-row*10;
    
    NSMutableArray *cons = [NSMutableArray array];
    if (col-1 > 0) {
        UIButton *but = (UIButton*)[self.view viewWithTag:(row*10+col-1)];
        [cons addObject:but];
    }
    if (col+1 < [_plane[0] count]+1) {
        UIButton *but = (UIButton*)[self.view viewWithTag:(row*10+col+1)];
        [cons addObject:but];
    }
    if (row-1 >= 0) {
        UIButton *but = (UIButton*)[self.view viewWithTag:((row-1)*10+col)];
        [cons addObject:but];
    }
    if (row+1 < [_plane count]) {
        UIButton *but = (UIButton*)[self.view viewWithTag:((row+1)*10+col)];
        [cons addObject:but];
    }
    
    return cons;
}

@end
