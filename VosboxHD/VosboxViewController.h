//
//  VosboxViewController.h
//  VosboxHD
//
//  Created by Lorenzo Primiterra on 02/06/2012.
//  Copyright (c) 2012 K2 Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaylistViewController.h"
#import "AudioStreamer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import "NSString+MD5.h"
#import "WebServiceManager.h"

@interface VosboxViewController : UIViewController <UISearchBarDelegate, PlaylistViewControllerDelegate> {
    IBOutlet UITableView *tableView1;
    IBOutlet UITableView *tableView2;
    IBOutlet UISearchBar *mySearchBar;
    IBOutlet UILabel *startText;
    IBOutlet UIBarButtonItem *enqueueButton;
    IBOutlet UIBarButtonItem *shareButton;
    IBOutlet UIBarButtonItem *emptyButton;
    IBOutlet UIBarButtonItem *shuffleButton;
    int currentSongINDEX;
    UIAlertView *alertView;
    NSString *searchString;
    NSMutableArray *searchArray;
    NSMutableArray *playlist;
    NSMutableDictionary *covers;
    NSMutableArray *playlistsList;
    UIAlertView *myAlertView;
    UITextField *myTextField;
    
    IBOutlet UILabel *artist_label, *album_label, *song_label, *year_label, *time_elapsed, *time_song;
	IBOutlet UIImageView *album_art;
    IBOutlet UIButton *playButton;
    IBOutlet UIView *waitingView;
    IBOutlet UIActivityIndicatorView *activity;
	IBOutlet UIView *volumeSlider;
	IBOutlet UILabel *positionLabel;
	IBOutlet UISlider *progressSlider;
    
    NSTimer *volumeTimer;
	NSDictionary *current_song;
	int song_time;
    BOOL playON, playerON;
    
	AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;

    NSString *custom_srv;
    NSString *srv_addr;
}

- (void) vosSearch;
- (void)play_current_song:(int)index;
- (IBAction)play;
- (IBAction)prevSong;
- (IBAction)nextSong;
- (void)updateProgress:(NSTimer *)aNotification;
- (IBAction)sliderMoved:(UISlider *)aSlider;
- (void)checkPaused;
- (IBAction)stopPlaying;
- (void)reloadSettings;
- (IBAction)enqueueAll;
- (NSString*) getUrl;
- (void)handleOpenURL:(NSURL *)url;

@property (nonatomic, retain) NSString *custom_srv;
@property (nonatomic, retain) NSString *srv_addr;
@property (nonatomic, retain) NSMutableArray *playlistsList;
@end
