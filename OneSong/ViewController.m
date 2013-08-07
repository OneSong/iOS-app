//
//  ViewController.m
//  OneSong
//
//  Created by Gabe Jacobs on 8/5/13.
//  Copyright (c) 2013 Gabe Jacobs. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking/AFHTTPClient.h"
#import "AFNetworking/AFJSONRequestOperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *fontArr = [UIFont fontNamesForFamilyName:@"Myriad Pro"];
    NSString *myrSemiBold = [fontArr objectAtIndex:0];
    NSString *myrReg = [fontArr objectAtIndex:1];
    
    self.activityBackView = [[UIView alloc] initWithFrame:CGRectMake(0, floorf(self.view.frame.size.height/2), 320, 175)];
    self.activityBackView.backgroundColor = [UIColor clearColor];
    
   	HUD = [[MBProgressHUD alloc] init];
    HUD.delegate = self;
	
    self.currentTimeLabel.hidden = YES;
    [self.currentTimeLabel setText:@"0:00"];
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    [self.currentTimeLabel setFont:[UIFont fontWithName:myrReg size:15.0]];
    [self.artistLabel setFont:[UIFont fontWithName:myrSemiBold size:19.0]];
    [self.songLabel setFont:[UIFont fontWithName:myrReg size:19.0]];
    self.artistLabel.textColor = [UIColor whiteColor];
    self.songLabel.textColor = [UIColor whiteColor];

    _refreshButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_refreshButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    _refreshButton.frame = CGRectMake(floorf(self.view.frame.size.width/2 - _refreshButton.imageView.image.size.width/2), floorf(self.view.frame.size.height/2 - _refreshButton.imageView.image.size.height/2)-30, _refreshButton.imageView.image.size.width, _refreshButton.imageView.image.size.height);
    _refreshButton.backgroundColor = [UIColor clearColor];
    [_refreshButton addTarget:self action:@selector(getSong) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_refreshButton];

    self.playSongButton.hidden = YES;
    self.timerBar.hidden = YES;
    self.artistLabel.hidden = YES;
    self.songLabel.hidden = YES;
    _refreshButton.hidden = NO;

    
    [self getSong];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getSongDetails:(void (^)(NSString* artURL, NSString* mp3URL, NSString* artName, NSString* songTitle))completion
{
    NSString *operationURL = @"http://onesong-api.herokuapp.com";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:operationURL]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPClient alloc] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSError *error = nil;
        NSDictionary *dict = [[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error] objectForKey:@"song"];
        NSString *artURL = [dict valueForKey:@"image"];
        NSString *mp3URL = [dict valueForKey:@"audio"];
        NSString *title = [dict valueForKey:@"title"];
        NSRange rangeOfDash = [title rangeOfString:@" – "];
        NSString *songTitle = [title substringFromIndex:rangeOfDash.location+3];
        NSString *artName = [title substringToIndex:rangeOfDash.location];
        
        completion(artURL,mp3URL, artName, songTitle);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil,nil, nil, nil);

    }];
    
	[operation start];
}

-(void)timedOut
{
    NSLog(@"TIMED OUT");
}

-(void)setUpAVPlayer
{
    AVPlayer *player = [[AVPlayer alloc]initWithURL:self.mp3URL];
    _audioPlayer = player;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_audioPlayer currentItem]];
    [_audioPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTimeLabel:) userInfo:nil repeats:YES];

    self.timerBar = [[ProgressBar alloc] initWithFrame:CGRectMake(85, 452, 215, 19)];
    [self.timerBar setAudioPlayer:_audioPlayer];
}


- (IBAction)playPauseSong:(id)sender {
    if(self.playing)
    {
        [self.playSongButton setImage:[UIImage imageNamed:@"videoPlayButton"] forState:UIControlStateNormal];

        [_audioPlayer pause];
        self.playing = NO;

    }
    else
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTimeLabel:) userInfo:nil repeats:YES];

        [self.playSongButton setImage:[UIImage imageNamed:@"videoPauseButton"] forState:UIControlStateNormal];

        [_audioPlayer play];
    
        [self.timerBar updateWithTime];
        self.playing = YES;
    }

}

- (void)updateTimeLabel:(NSTimer*)timer
{
    

    NSInteger seconds = CMTimeGetSeconds(_audioPlayer.currentTime);
    seconds = seconds%60;
    NSInteger minutes = CMTimeGetSeconds(_audioPlayer.currentTime)/60;

    NSString* currentTimeString;

    if(seconds < 10)
    {
        currentTimeString = [NSString stringWithFormat:@"%i:0%i", minutes, seconds];

    }
    else{
        currentTimeString = [NSString stringWithFormat:@"%i:%i", minutes, seconds];
    }
    
    [self.currentTimeLabel setText:currentTimeString];
     
}

-(void)getSong
{
    NSArray *fontArr = [UIFont fontNamesForFamilyName:@"Myriad Pro"];
    NSString *myrReg = [fontArr objectAtIndex:1];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Fetching Song Of The Day";
    _refreshButton.hidden = YES;

    HUD.labelFont = [UIFont fontWithName:myrReg size:18.0];
    HUD.detailsLabelText = @"Don't worry, it's coming";
    HUD.detailsLabelFont = [UIFont fontWithName:myrReg size:15.0];
    [self.view addSubview:self.activityBackView];
    [self.activityBackView addSubview:HUD];
    [HUD show:YES];
    
    [self getSongDetails:^(NSString *artURL, NSString *mp3URL, NSString* artName, NSString* songTitle){
        
        if(artName == nil || artURL == nil || mp3URL == nil || songTitle == nil)
        {
            [self showFailedConnection];
        }
        else{

            self.mp3URL = [NSURL URLWithString:mp3URL];
            [self setUpAVPlayer];
    
                [self.artistLabel setText:artName];
                [self.songLabel setText:[NSString stringWithFormat:@"\"%@\"", songTitle]];
                [self.songLabel sizeToFit];
                [self.artistLabel sizeToFit];
                
                
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:artURL]];
                UIImage *img = [[UIImage alloc] initWithData:imageData];
                [self.albumArt setImage:img];
                
                [self.view addSubview:self.timerBar];
                self.currentTimeLabel.hidden = NO;
                self.songLabel.hidden = NO;
                self.artistLabel.hidden = NO;
                self.playSongButton.hidden = NO;
                self.timerBar.hidden = NO;

                [HUD hide:YES];
        }
    
    }];
}

-(void)showFailedConnection
{
    NSArray *fontArr = [UIFont fontNamesForFamilyName:@"Myriad Pro"];
    NSString *myrReg = [fontArr objectAtIndex:1];
    HUD.labelFont = [UIFont fontWithName:myrReg size:16.0];
    HUD.detailsLabelFont = [UIFont fontWithName:myrReg size:14.0];
    
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"Check Your Internet Connection!";
    HUD.detailsLabelText = @"We can't reach the server";
    [self.view addSubview:self.activityBackView];
    [self.activityBackView addSubview:HUD];
    
    [HUD show:YES];
    
    self.currentTimeLabel.hidden = YES;
    self.songLabel.hidden = YES;
    self.artistLabel.hidden = YES;
    self.playSongButton.hidden = YES;
    self.timerBar.hidden = YES;
    _refreshButton.hidden = NO;

    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == _audioPlayer && [keyPath isEqualToString:@"status"]) {
        if (_audioPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
            
        } else if (_audioPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            
            
        } else if (_audioPlayer.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
            
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    [self.playSongButton setImage:[UIImage imageNamed:@"videoPlayButton"] forState:UIControlStateNormal];
    
    [_audioPlayer pause];
    [_audioPlayer seekToTime:CMTimeMakeWithSeconds(0, _audioPlayer.currentTime.timescale)];

    self.playing = NO;
    
}

- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player {
    NSLog(@"here");
}


@end
