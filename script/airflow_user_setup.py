import airflow,sys
from airflow import models, settings
from airflow.contrib.auth.backends.password_auth import PasswordUser

try:
  if len(sys.argv) != 4:
    raise ValueError('Missing required arguments for user account creation')
  
  user = PasswordUser(models.User())
  user.username = sys.argv[1]
  user.email = sys.argv[2]
  user.password = sys.argv[3]
  session = settings.Session()
  session.add(user)
  session.commit()
  session.close()
except Exception as e:
  print(e)
  raise
