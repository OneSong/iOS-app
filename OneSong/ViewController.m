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
    [self getSongDetails:^(NSString *artURL, NSString *mp3URL){
       

        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:artURL]];
        UIImage *img = [[UIImage alloc] initWithData:imageData];
        [self.albumArt setImage:img];
        self.albumArt.hidden = NO;
        self.mp3URL = [NSURL URLWithString:mp3URL];
        [self setUpAVPlayer];

       
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getSongDetails:(void (^)(NSString* artURL, NSString* mp3URL))completion
{
    NSString *operationURL = @"http://onesong-api.herokuapp.com";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:operationURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPClient alloc] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSError *error = nil;
        NSDictionary *dict = [[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error] objectForKey:@"song"];
        NSString *artURL = [dict valueForKey:@"image"];
        NSString *mp3URL = [dict valueForKey:@"audio"];
        /*
        NSData *imageData = [NSData dataWithContentsOfURL:artURL];
        UIImage *img = [[UIImage alloc] initWithData:imageData];
        [self.albumArt setImage:img];
        self.albumArt.hidden = NO;
         */
        
        completion(artURL,mp3URL);

    
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
	[operation start];
}

-(void)setUpAVPlayer
{
    
    NSData *soundData = [NSData dataWithContentsOfURL:self.mp3URL];
	NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithData:soundData error:&error];
	audioPlayer.numberOfLoops = 0;
    self.timerBar = [[ProgressBar alloc] initWithFrame:CGRectMake(85, 467, 215, 19)];
    [self.view addSubview:self.timerBar];
    [self.timerBar setAudioPlayer:audioPlayer];
}


- (IBAction)playPauseSong:(id)sender {
    if(self.playing)
    {
        [audioPlayer pause];
        self.playing = NO;

    }
    else
    {
        [audioPlayer play];
        [self.timerBar updateWithTime];
        self.playing = YES;
    }


}
@end
