//
//  ViewController.m
//  Keychain34018
//
//  Created by Matt Palcic on 10/16/14.
//  Copyright (c) 2014 ExpeData LLC. All rights reserved.
//

#import "ViewController.h"
#import "JNKeychain.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (copy, nonatomic) NSData *bigData;
@property (strong, nonatomic) UIView *snapshot;
@property (strong, nonatomic) UIImage *img;
@property (strong, nonatomic) NSData *imgData;

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.textView.text = nil;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(didReturnFromBackground:)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];

  self.bigData = [self randomDataWithLength:40*1024*1024];
  self.snapshot = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
  [self.view addSubview:self.snapshot];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.apple.com"]];
  [self.webView loadRequest:request];
  [self grabScreenshot];
  self.imageView.image = self.img;
  self.snapshot.hidden = YES;
}

- (void)grabScreenshot
{
  UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
  [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
  self.img = UIGraphicsGetImageFromCurrentImageContext();
  self.imgData = UIImageJPEGRepresentation(self.img, 1.0);
  UIGraphicsEndImageContext();
}

- (id)randomDataWithLength:(NSUInteger)length
{
  NSMutableData* data=[NSMutableData dataWithLength:length];
  [[NSInputStream inputStreamWithFileAtPath:@"/dev/urandom"] read:(uint8_t*)[data mutableBytes] maxLength:length];
  return data;
}

- (void)addLogMessage:(NSString *)message
{
  if (message) {
    self.textView.text = [NSString stringWithFormat:@"%@%@\n", self.textView.text, message];
  }
}

- (void)saveTimestamp
{
  NSString *keychainValue = [[NSDate date] description];
  NSString *status = [JNKeychain saveValue:keychainValue forKey:@"Keychain34018"];
  if (status) {
    NSString *message = [NSString stringWithFormat:@"SAVE: %@", status];
    [self addLogMessage:message];
  }
}

- (void)loadTimestamp
{
  NSString *keychainValue = [JNKeychain loadValueForKey:@"Keychain34018"];
  if (keychainValue) {
    NSString *message = [NSString stringWithFormat:@"LOAD: %@", keychainValue];
    [self addLogMessage:message];
  }
}

- (void)didReturnFromBackground:(NSNotification *)event
{
  [self loadTimestamp];
}

- (IBAction)updateKeychainValue:(id)sender
{
  [self saveTimestamp];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
