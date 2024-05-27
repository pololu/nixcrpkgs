// This is here to help us reproduce bugs in Qt.

#include <QtCore/QCoreApplication>
#include <QtDBus/QDBusConnection>
#include <stdio.h>

int main(int argc, char ** argv)
{
  QCoreApplication app(argc, argv);

  // A warning is printed in QGenericUnixThemeDBusListener::init
  // (in src/gui/platform/unix/qgenericunixthemes.cpp) as a result
  // of QDBusConnection::sessionBus().isConnected() returning false.
  printf("Before dbus\n");
  fflush(stdout);
  QDBusConnection dbus = QDBusConnection::sessionBus();
  bool connected = dbus.isConnected();  // we want 'true'
  printf("dbus connected: %d\n", connected);
  fflush(stdout);
}
