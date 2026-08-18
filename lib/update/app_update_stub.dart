/// Native platforms update through their store, not through a service worker.
void watchForUpdate(void Function() onReady) {}

bool updateIsReady() => false;

void applyUpdate() {}
