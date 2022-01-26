//
//  ViewController.m
//  StripedTextTableViewControllerExample
//
//  Created by Lessica on 2024/1/14.
//

#import "ViewController.h"
#import "StripedTextTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)showButtonTapped:(id)sender {
    StripedTextTableViewController *ctrl = [[StripedTextTableViewController alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"tap" ofType:@"log"]];
    ctrl.autoReload = YES;
    ctrl.maximumNumberOfRows = 100;
    ctrl.reversed = YES;
    ctrl.allowTrash = NO;
    ctrl.allowSearch = YES;
    ctrl.allowMultiline = YES;
    ctrl.pullToReload = YES;
    ctrl.tapToCopy = YES;
    ctrl.pressToCopy = YES;
    ctrl.preserveEmptyLines = NO;
    ctrl.removeDuplicates = YES;
    ctrl.rowSeparator = @"\n";
    ctrl.rowPrefixRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"^\\d{2}:\\d{2}:\\d{2}\\.\\d{6}\\+\\d{4}\t" options:kNilOptions error:nil];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:navCtrl animated:YES completion:nil];
}

@end
