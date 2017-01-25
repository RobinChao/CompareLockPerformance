//
//  main.m
//  CompareLockPerformance
//
//  Created by Alex_Wu on 1/18/17.
//  Copyright © 2017 starcor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <pthread.h>
#import <libkern/OSAtomic.h>

#define Iterations (1024 * 1024 * 32)

typedef id (*_IMP)(id, SEL, ...);


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        CFAbsoluteTime before,after;
        
        //Test NSLock
        NSLock *lockTest = [[NSLock alloc]init];
        
        before = CFAbsoluteTimeGetCurrent();
        for (NSUInteger i = 0; i < Iterations; i++)
        {
            [lockTest lock];
            
            [lockTest unlock];
        }
        after = CFAbsoluteTimeGetCurrent();
        
        printf("NSLock %f sec \n",(after - before));
        
        
        //Test NSLock with IMP cache
        
        _IMP lockIMP = [lockTest methodForSelector:@selector(lock)];
        _IMP unlockIMP = [lockTest methodForSelector:@selector(unlock)];
        
        before = CFAbsoluteTimeGetCurrent();
        for (NSUInteger i = 0; i < Iterations; i++)
        {
            lockIMP(lockTest,@selector(lock));
            unlockIMP(lockTest,@selector(unlock));
        }
        after = CFAbsoluteTimeGetCurrent();
        
        printf("NSLock with IMP cache %f sec \n",(after - before));
        
        //Test pthread mutex
        pthread_mutex_t mutex_lock = PTHREAD_MUTEX_INITIALIZER;
        before = CFAbsoluteTimeGetCurrent();
        for (NSUInteger i = 0; i < Iterations; i++)
        {
            pthread_mutex_lock(&mutex_lock);
            pthread_mutex_unlock(&mutex_lock);
        }
        after = CFAbsoluteTimeGetCurrent();
        
        printf("pthread mutex %f sec \n",(after - before));
        
        
        //Test OSSpinLock
        OSSpinLock spin_lock = OS_SPINLOCK_INIT;
        before = CFAbsoluteTimeGetCurrent();
        for (NSUInteger i = 0; i < Iterations; i++)
        {
            OSSpinLockLock(&spin_lock);
            OSSpinLockUnlock(&spin_lock);
        }
        after = CFAbsoluteTimeGetCurrent();
        
        printf("OSSpinLock %f sec \n",(after - before));

    }
    return 0;
}
