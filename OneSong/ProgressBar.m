//
//  ProgressBar.m
//  OneSong
//
//  Created by Gabe Jacobs on 8/5/13.
//  Copyright (c) 2013 Gabe Jacobs. All rights reserved.
//

#import "ProgressBar.h"

@implementation ProgressBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.blueStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.blueStatusBar.backgroundColor = [UIColor colorWithRed:1.0/255.0 green:84.0/255.0 blue:154.0/255.0 alpha:1.0];
        [self addSubview:self.blueStatusBar];
        self.audioPlayer.delegate = self;
        self.backgroundColor = [UIColor blackColor];

    }
    return self;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)updateWithTime
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
           
}

- (void)timerFired:(NSTimer*)timer
{
    NSTimeInterval currentTime = self.audioPlayer.currentTime;
    NSTimeInterval duration = self.audioPlayer.duration;
    double timeCompleted = currentTime/duration;
    double newWidth = 215 * timeCompleted;
    
    self.blueStatusBar.frame = CGRectMake(self.blueStatusBar.frame.origin.x, self.blueStatusBar.frame.origin.y, floorf(newWidth), self.blueStatusBar.frame.size.height);

    NSLog(@"%f", newWidth);
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    double ratio = location.x/215.0;
    NSTimeInterval newTime = self.audioPlayer.duration * ratio;
    self.audioPlayer.currentTime = newTime;
    self.blueStatusBar.frame = CGRectMake(self.blueStatusBar.frame.origin.x, self.blueStatusBar.frame.origin.y, location.x, self.blueStatusBar.frame.size.height);
    NSLog(@"x: %f", location.x);
}

@end
