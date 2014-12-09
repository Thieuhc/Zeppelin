#import "ZPTheme.h"
#import "Defines.h"

@implementation ZPTheme
@synthesize name, image, whiteImage, pack, hidden, shouldTint, shouldUseLegacyImages;

+ (ZPTheme*)themeWithPath:(NSString*)path {
	return [[[ZPTheme alloc] initWithPath:path] autorelease];
}

- (id)initWithPath:(NSString*)path {
	// make sure it is a dir
	BOOL isDir = NO;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
	
	if (!exists || !isDir) {
		[self release];
		return nil;
	}
	
	if ((self = [super init])) {
		self.name = [[path lastPathComponent] stringByDeletingPathExtension];

		// Find out which image to use
		NSString *silverName;
		if (IS_IOS_70_OR_LATER()) {
			silverName = MAXIMIZE(kLogoImageName, path);
			self.image = self.whiteImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:silverName]];

			// Since I changed the logo format in iOS7 from dark.png and light.png to logo.png
			// I'm adding support for dark.png to be used as logo.png to avoid many support emails
			if (!self.image) {
				silverName = MAXIMIZE(kDarkImageName, path);
				self.image = self.whiteImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:silverName]];
			} else {
				self.shouldTint = YES;
			}
		}

		if (!self.image) {
			silverName = MAXIMIZE(kSilverImageName, path);
			self.image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:silverName]];

			if (self.image) {
				self.shouldUseLegacyImages = YES;
			}
		}

		NSString *blackName;
		if (!self.whiteImage) {
			blackName = MAXIMIZE(kBlackImageName, path);
			self.whiteImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:blackName]];

			if (!self.whiteImage) {
				blackName = MAXIMIZE(kEtchedImageName, path);
				self.whiteImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:blackName]];
			}
		}
				
		// no images? kill myself
		if (!self.whiteImage || !self.image) {
			[self release];
			return nil;
		}
		
		if ([self.image respondsToSelector: @selector(imageWithRenderingMode:)]) {
			self.image = [self.image imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
		}
	}
	return self;
}

- (void)dealloc {
	self.name = nil;
	self.image = nil;
	self.whiteImage = nil;
	[super dealloc];
}

@end