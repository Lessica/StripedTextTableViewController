# StripedTextTableViewController

[![Xcode - Build and Analyze](https://github.com/Lessica/StripedTextTableViewController/actions/workflows/objective-c-xcode.yml/badge.svg)](https://github.com/Lessica/StripedTextTableViewController/actions/workflows/objective-c-xcode.yml)

A simple log viewer in Objective-C.

## Usage

```objective-c
StripedTextTableViewController *ctrl = [[StripedTextTableViewController alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"keybagd.log" ofType:@"0"]];
ctrl.autoReload = YES;
ctrl.maximumNumberOfRows = 100;
ctrl.reversed = YES;
ctrl.allowTrash = NO;
ctrl.allowSearch = YES;
ctrl.pullToReload = YES;
ctrl.tapToCopy = YES;
ctrl.pressToCopy = YES;
ctrl.preserveEmptyLines = NO;
ctrl.removeDuplicates = YES;
ctrl.rowSeparator = @"\n";
ctrl.rowPrefixRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"^(Mon|Tue|Wen|Thu|Fri|Sat|Sun)\\s" options:kNilOptions error:nil];
UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
[self presentViewController:navCtrl animated:YES completion:nil];
```

## Screenshots

<p float="left">
  <img src="/Screenshots/IMG_0011.png" width="32%">
  <img src="/Screenshots/IMG_0012.png" width="32%">
  <img src="/Screenshots/IMG_0013.png" width="32%">
</p>
