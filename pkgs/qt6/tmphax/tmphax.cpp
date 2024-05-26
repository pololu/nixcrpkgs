// This is here to reproduce the bug Qt has where it can't connect to DBus,
// which causes all the example apps to print a warning.
//
// Ths warning is printed in QGenericUnixThemeDBusListener::init
// (in src/gui/platform/unix/qgenericunixthemes.cpp) as a result
// of QDBusConnection::sessionBus().isConnected() returning false.

#include <QtCore/QCoreApplication>
#include <QtDBus/QDBusConnection>
#include <stdio.h>

int main(int argc, char ** argv)
{
  QCoreApplication app(argc, argv);
  printf("Before dbus\n");
  fflush(stdout);
  QDBusConnection dbus = QDBusConnection::sessionBus();
  bool connected = dbus.isConnected();  // we want 'true'
  printf("dbus connected: %d\n", connected);
  fflush(stdout);
}
