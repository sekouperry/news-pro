
#import "NINetworkActivity.h"
#import <pthread.h>
#import <UIKit/UIKit.h>

static int              gNetworkTaskCount = 0;
static pthread_mutex_t  gMutex = PTHREAD_MUTEX_INITIALIZER;

void NINetworkActivityTaskDidStart(void) {
  pthread_mutex_lock(&gMutex);

  BOOL enableNetworkActivityIndicator = (0 == gNetworkTaskCount);

  ++gNetworkTaskCount;

  if (enableNetworkActivityIndicator) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  }

  pthread_mutex_unlock(&gMutex);
}

void NINetworkActivityTaskDidFinish(void) {
  pthread_mutex_lock(&gMutex);

  --gNetworkTaskCount;
    
  gNetworkTaskCount = MAX(0, gNetworkTaskCount);

  if (gNetworkTaskCount == 0) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  }
  pthread_mutex_unlock(&gMutex);
}


