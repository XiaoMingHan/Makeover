//
//  mainViewController.h
//  FaceAddEffect
//
//

#import <UIKit/UIKit.h>

@interface mainViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *img_gallery;

@end
