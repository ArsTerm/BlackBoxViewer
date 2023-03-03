#pragma once

#include <QtCore/qglobal.h>

#define BBVIEWER_BEGIN_NS namespace bbviewer {
#define BBVIEWER_END_NS }

#if defined(BLACKBOXVIEWER_LIBRARY)
#define BLACKBOXVIEWER_EXPORT Q_DECL_EXPORT
#else
#define BLACKBOXVIEWER_EXPORT Q_DECL_IMPORT
#endif
