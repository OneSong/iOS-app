//
//  ViewController.h
//  OneSong
//
//  Created by Gabe Jacobs on 8/5/13.
//  Copyright (c) 2013 Gabe Jacobs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ProgressBar.h"
#import "MBProgressHUD.h"


@interface ViewController : UIViewController<AVAudioPlayerDelegate, MBProgressHUDDelegate>
{
	AVPlayer *_audioPlayer;
    UIActivityIndicatorView *_spinner;
    MBProgressHUD *HUD;
    UIButton *_refreshButton;

}

@property (weak, nonatomic) IBOutlet UIImageView *albumArt;
@property (weak, nonatomic) IBOutlet UIButton *playSongButton;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
- (IBAction)playPauseSong:(id)sender;

@property (nonatomic) ProgressBar *timerBar;
@property (nonatomic) NSURL *mp3URL;
@property (nonatomic) BOOL playing;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic) UIView *activityBackView;



@end
