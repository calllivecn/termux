

from jnius import autoclass

PythonActivity = autoclass('org.kivy.android.PythonActivity')
activity = PythonActivity.mActivity
context = activity.getApplicationContext()
pm = context.getSystemService(Context.POWER_SERVICE)
wake_lock = pm.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK | PowerManager.ACQUIRE_CAUSES_WAKEUP, "myapp:mywakelocktag")
wake_lock.acquire()
wake_lock.release()

