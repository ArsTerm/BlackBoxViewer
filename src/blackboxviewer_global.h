#ifndef CANINITPARSER_GLOBAL_H
#define CANINITPARSER_GLOBAL_H

#define BBVIEWER_BEGIN_NS namespace bbviewer {
#define BBVIEWER_END_NS }

#if defined(_MSC_VER) || defined(WIN64) || defined(_WIN64)         \
        || defined(__WIN64__) || defined(WIN32) || defined(_WIN32) \
        || defined(__WIN32__) || defined(__NT__)
#define Q_DECL_EXPORT __declspec(dllexport)
#define Q_DECL_IMPORT __declspec(dllimport)
#else
#define Q_DECL_EXPORT __attribute__((visibility("default")))
#define Q_DECL_IMPORT __attribute__((visibility("default")))
#endif

#if defined(BLACKBOXVIEWER_LIBRARY)
#define BLACKBOXVIEWER_EXPORT Q_DECL_EXPORT
#else
#define BLACKBOXVIEWER_EXPORT Q_DECL_IMPORT
#endif

#endif // CANINITPARSER_GLOBAL_H
