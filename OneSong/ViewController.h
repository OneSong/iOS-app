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


@interface ViewController : UIViewController
{
	AVAudioPlayer *audioPlayer;

}
@property (weak, nonatomic) IBOutlet UIImageView *albumArt;
@property (weak, nonatomic) IBOutlet UIButton *playSongButton;
- (IBAction)playPauseSong:(id)sender;

@property (nonatomic) ProgressBar *timerBar;
@property (nonatomic) NSURL *mp3URL;
@property (nonatomic) BOOL playing;


@end
