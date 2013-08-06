//
//  ProgressBar.h
//  OneSong
//
//  Created by Gabe Jacobs on 8/5/13.
//  Copyright (c) 2013 Gabe Jacobs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ProgressBar : UIView <AVAudioPlayerDelegate>

@property(nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer* timer;
@property(nonatomic) UIView           *blueStatusBar;

-(void)updateWithTime;

@end
