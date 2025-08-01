#include <jni.h>
#include <string>
#include "PrayerTimes.h"

extern "C" JNIEXPORT jobject JNICALL
Java_com_adhan_AdhanModule_getPrayerTimesNative(
  JNIEnv* env,
  jobject /* this */,
  jdouble lat,
  jdouble lon,
  jstring dateIsoStr,
  jstring methodStr
) {
  const char* dateCStr = env->GetStringUTFChars(dateIsoStr, 0);
  const char* methodCStr = env->GetStringUTFChars(methodStr, 0);

  std::map<std::string, std::string> times = getPrayerTimesCpp(lat, lon, dateCStr, methodCStr);

  jclass hashMapClass = env->FindClass("java/util/HashMap");
  jmethodID init = env->GetMethodID(hashMapClass, "<init>", "()V");
  jmethodID put = env->GetMethodID(hashMapClass, "put",
    "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");
  jobject map = env->NewObject(hashMapClass, init);

  for (const auto& pair : times) {
    jstring key = env->NewStringUTF(pair.first.c_str());
    jstring val = env->NewStringUTF(pair.second.c_str());
    env->CallObjectMethod(map, put, key, val);
    env->DeleteLocalRef(key);
    env->DeleteLocalRef(val);
  }

  env->ReleaseStringUTFChars(dateIsoStr, dateCStr);
  env->ReleaseStringUTFChars(methodStr, methodCStr);
  return map;
}